# KVM / virsh administration for the HAOS VM

Context (verified Aug 2026): the user's HAOS runs as a KVM guest on Ubuntu Server (8GB
physical host, nothing else runs on it). VM RAM was 4GB → raised to 6GB to fix addon-container
OOM (the agent addon's `hermes update` npm web build, exit 137). The host user manages virsh
from the Ubuntu host.

## Resizing VM RAM (the durable OOM fix)

- `virsh setmaxmem` = `<memory>` (the CEILING) vs `virsh setmem` = `<currentMemory>` (what the
  guest actually gets at boot). Set BOTH to the same value with `--config` (persistent) while
  the VM is off:
  - only `setmaxmem` → VM boots with the old allocation (ceiling raised, currentMem unchanged)
  - only `setmem` → libvirt rejects (currentMemory > memory is invalid)
- KiB units: 6GB = 6291456.
- `virsh dominfo <vm>` shows Max vs Used memory after the change.
- Sizing rule: baseline idle usage (~3.5GB: HA Core + supervisor + 2 Hermes addons) + build
  peak (~1.5-2GB for `tsc -b && vite build`) → 6GB comfortable on an 8GB host (~2GB left for
  Ubuntu + KVM). 7GB possible but leaves the host ~1GB with no margin for snapshots/backups.

## virsh without sudo

- virsh talks to libvirtd over a Unix socket. Non-root default is the per-user SESSION daemon
  (`qemu:///session`, empty VM list — not a permission error, just a different daemon). Since
  **libvirt ≥ 9.4**, non-root users who are members of the `libvirt` group get
  `qemu:///system` by default.
- Fix: `sudo usermod -aG libvirt $USER` then re-login (new terminal / new SSH session). Group
  membership is inherited per-process at login — a stale shell keeps the old groups. In tmux,
  the SERVER holds the groups (restart the tmux server, a new pane is not enough). No OS
  reboot, no libvirtd restart needed (the daemon doesn't check client groups; the client opens
  the socket).
- Diagnose in order: `virsh uri` (system vs session — the definitive check), `id -nG`
  (libvirt present?), `grep -v '^#' /etc/libvirt/libvirt.conf` (uri_default?), `echo $LIBVIRT_DEFAULT_URI`.

## Verifying guest RAM from inside

- From ANY addon container: `grep -E 'MemTotal|MemAvailable' /proc/meminfo` — container
  meminfo reflects the GUEST kernel, so it shows the VM's RAM after a resize.
- Per-addon RAM: `docker stats --no-stream` from the HAOS host shell (SSH addon / KVM console);
  or `ps aux --sort=-rss | head` in an addon's own web terminal (that container only).
- Supervisor API per-addon stats can be **403** from addons that lack `supervisor_api: true`
  in their addon config — the webui addon is such a case; don't loop on it.

## cgroup vs host OOM — quick rules

- `cat /sys/fs/cgroup/memory.max` inside the container: `max` = no cap → the OOM is
  HOST-level → raise the VM's RAM (virsh above), NOT the addon `mem_limit`. A number = addon
  cap → raise `mem_limit` in the addon's `config.yaml` (applies at container CREATION).
- exit 137 = 128+9 = SIGKILL (OOM killer). `EBADENGINE` npm warnings (node 22 vs 24 required)
  are harmless.
