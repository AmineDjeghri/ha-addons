# HAOS on KVM — host & virsh admin notes (verified Aug 2026)

## Environment
- HAOS runs as a KVM VM on a dedicated **8 GB Ubuntu Server** host. Nothing else runs on the host.
- VM RAM was 4 GB → raised to **6 GB** (6291456 KiB) so the Hermes agent update's web build fits (baseline ~3.5 GB + ~2 GB peak). See `hermes-update-oom-npm-build.md` for why.

## virsh: empty list without sudo (session vs system)
Non-root `virsh list` shows an EMPTY list (not a permission error): since libvirt 5.6, non-root defaults to `qemu:///session` (per-user daemon, no VMs); root defaults to `qemu:///system` (the real daemon that owns HAOS).

Diagnose why a given invocation sees the VM:
```bash
virsh uri                    # qemu:///system → correct daemon; qemu:///session → wrong one
id -nG                       # libvirt group membership?
grep -v '^#' /etc/libvirt/libvirt.conf   # uri_default = "qemu:///system" set?
echo "$LIBVIRT_DEFAULT_URI"  # env override
ls -l /var/run/libvirt/libvirt-sock*     # socket perms (root:libvirt 0770 typical)
```

Fix for sudo-less management:
```bash
sudo usermod -aG libvirt $USER          # + relogin (or newgrp libvirt)
echo 'uri_default = "qemu:///system"' | sudo tee -a /etc/libvirt/libvirt.conf
```
`virsh list` = running VMs only; `virsh list --all` includes stopped ones. `virsh` commands on the wrong connection fail harmlessly with "Domain not found" — no risk to the VM.

## Resize VM RAM (persistent)
```bash
virsh list --all
virsh shutdown haos
virsh setmaxmem haos 6291456 --config     # 6 GB in KiB; setmaxmem before setmem
virsh setmem   haos 6291456 --config
virsh start haos
```
(or virt-manager → Hardware → Memory.) Consequences: one VM reboot (~1–2 min HA downtime); NO data risk (RAM is not persistent); swap drains afterward. Verify in the agent addon Terminal: `free -m` → Mem total ≈ 5914 MB.

## Sizing rule of thumb (this deployment)
Baseline (HA Core + supervisor + 2 Hermes addons) ≈ 3.5 GB idle; hermes web build peaks ~1.5–2 GB above baseline → VM ≥ 6 GB; leave ~2 GB for Ubuntu + KVM on an 8 GB host. Raising `mem_limit` on an addon is pointless when its cgroup is already `max` — the constraint is host RAM.
