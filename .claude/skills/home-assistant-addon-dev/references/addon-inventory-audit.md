# Installed add-on inventory, provenance & delete-vs-export audit

Verified 2026-09-26 against the live instance (22 installed / 12 registered repos).

## Steps

1. **Installed set + usage:** `ha_get_app(source='installed', include_stats=True)`. `state` (`started`/`stopped`), `update_available`, and `stats.cpu_percent` / `stats.memory_usage` (`stats: null` = stopped) separate active from idle add-ons. There is no usage counter — CPU + integration state is the whole evidence base.
2. **Map add-on → repo:** `ha_get_app(source='available')` returns `repositories[]` (slug, name, **source URL**, maintainer) and every store add-on tagged with its `repository` slug. Count store add-ons per repo slug to see which of the registered repos are actually in use.
3. **Ownership comes from `source`, never the slug prefix** — prefixes like `ffaaaf16` are opaque hashes. Read the `source` URL to separate the user's repo (`github.com/<user>/ha-addons`) from third-party ones, then confirm the add-on's packaging (`config.yaml`, `run.sh`/`bootstrap.js`, `Dockerfile`, `build.json`) is committed in that repo's tree.
4. **Local / unversioned add-ons:** a filesystem add-on appears with `repository: 'local'` (store section "Local apps"). Zero entries there = nothing unversioned **on the add-on side**. The host's `/addons` directory is NOT readable from any container, so report "none registered" — never "none exist".
5. **Integration evidence:** `ha_get_integration` entries with `source: 'hassio'` correspond to add-ons (mqtt→Mosquitto, adguard, otbr→Silicon Labs Multiprotocol, motioneye). A `setup_error` / `setup_retry` state makes the add-on a fix-or-remove candidate. Add-ons with no HA integration (Navidrome, AIOStreams, Octo-Fiesta, MediaFlow, Beets, Hermes add-ons) cannot be judged from entities — say so instead of guessing.

## Verdict rules

- **Delete:** `stopped` one-shot installers/flashers (Get HACS, SONOFF Dongle Flasher) — reinstallable from the store on demand. Also anything whose HA integration is broken, once the user confirms it is unused.
- **Keep:** everything backing a loaded integration, a live client (Stremio/Nuvio/Subsonic), or an active service; core infrastructure (Mosquitto, Zigbee2MQTT, Cloudflared, Matter Server).
- **Export (move into the user's own repo):** only add-ons whose packaging he authors. Third-party add-ons are image-wrapped (`build.json` → upstream `ghcr.io/...`), so local patches are impossible and lost at update — upstream a PR instead of forking (his standing rule for services he uses remotely, e.g. Navidrome).
- **Report shape:** counts (installed / running / stopped / updates pending), the per-repo split, then three short lists (delete / fix-or-remove / keep) with the one-line evidence for each non-obvious call, plus what could not be verified from the container.

## Related unversioned-artifact check (Hermes/Claude side)

When the question is "what is not in a repo?", the add-on list is only half: also audit the agent's own store — live `~/.hermes/skills` vs the git trees (chezmoi `dot_hermes`/`dot_claude` sources), skills shipped by the Hermes install with local edits (`hermes skills diff <name>`), curator markers (`hermes curator list-unmanaged` — a git-tracked skill still needs `hermes curator pin`), Track-2 plugins (`~/.claude/plugins/installed_plugins.json`, intentionally NOT in git), and loose files in the persistent home (probe scripts, research tarballs, ad-hoc reports).
