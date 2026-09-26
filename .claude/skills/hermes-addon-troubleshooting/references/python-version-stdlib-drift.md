# Python-version/stdlib drift breaks tool execution (CPython 3.14 + Hermes daemon pool)

## Signature
- Every model tool fails identically: `AttributeError: 'DaemonThreadPoolExecutor' object has no attribute '_initializer'`, ~0s, all tool types (web_search, terminal, execute_code, search_files, ...).
- Repeats after every restart — NOT transient executor state; "restart the addon" fixes nothing.
- One surface dead while another (agent gateway on the SAME checkout) works fine.

## Mechanism (verified against CPython source)
- Hermes `tools/daemon_pool.py` `DaemonThreadPoolExecutor(ThreadPoolExecutor)` overrides `_adjust_thread_count()` as a mirror of CPython 3.8–3.13 internals: spawn `threading.Thread(target=_worker, args=(weakref.ref(self, cb), self._work_queue, self._initializer, self._initargs), daemon=True)`, no `_threads_queues` registration. The override exists because stdlib workers are non-daemon AND registered in `_threads_queues`, whose atexit hook joins every worker — one wedged worker hangs interpreter exit.
- CPython 3.14 refactored `concurrent/futures/thread.py`: `__init__` no longer stores `self._initializer`/`self._initargs` — it builds per-instance `_create_worker_context`/`_resolve_work_item_task` via `prepare_context(initializer, initargs)`; `_worker` is now `_worker(executor_reference, ctx, work_queue)` and `_adjust_thread_count` spawns with `self._create_worker_context()`.
- On 3.14+: `submit()` → stdlib `submit` → overridden `_adjust_thread_count` → reads the missing `self._initializer` → AttributeError. All tool execution funnels through this executor (`agent/tool_executor.py`), hence total uniformity.
- The override is STILL needed on 3.14 (stdlib threads stay non-daemon + registered); a 3.14-compatible override must mirror the 3.14 spawn signature while keeping `daemon=True` and skipping registration. `submit()`'s contextvars wrapper is harmless-but-redundant on 3.14 (stdlib propagates context itself).

## Finding the failing interpreter (read-only)
1. `grep -n "DaemonThreadPoolExecutor' object has no attribute" $HERMES_HOME/logs/errors.log` — count occurrences and find the last one (log may rotate; don't conclude from a short file).
2. Read a traceback's frames: the stdlib path names the interpreter, the code paths name the install:
   - `.../.local/share/uv/python/cpython-3.14.7-.../lib/python3.14/...` → NEW uv layout, CPython >= 3.14 (the crasher).
   - `.../.hermes/hermes-agent/.hermes-runtime/python/generation-*/cpython-3.11...` → the agent's pinned older uv runtime.
3. Agent and WebUI containers write to the SAME `$HERMES_HOME/logs` (shared data): attribute the session id in the log to its surface (source=webui sessions = WebUI container) before assuming which container crashed.
4. In the healthy surface: `ps -eo args | grep -iE "hermes|gateway"` and `readlink -f <venv>/bin/python3` to learn the working interpreter.

## Fixes (each needs explicit user approval; shared-checkout writes are gated)
- Repin/rebuild the affected venv onto the CPython the agent's venv uses (Hermes stdlib mirrors validated 3.11–3.13). Find where the container's init picks the python (run.sh / `uv venv --python` pin) first — otherwise a rebuild just re-pulls the newest CPython again.
- Version-gate `_adjust_thread_count` in the shared checkout (`sys.version_info >= (3, 14)` → 3.14 mirror, else the current one). It is a checkout edit: agent updates stomp it unless carried by the same re-applied patch machinery as the HA-ADDON markers.
- Upstream PR to `NousResearch/hermes-agent`.

## Before claiming "an update fixes it"
Fetch `https://raw.githubusercontent.com/NousResearch/hermes-agent/main/tools/daemon_pool.py` and diff against the local copy — upstream can still carry the identical 3.8–3.13-only mirror. Only a code change or a venv repin unblocks.
