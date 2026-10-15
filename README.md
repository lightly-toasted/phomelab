<div align="center">

# phomelab

**Run your homelab on phones**

Turn spare Android phones into a fleet of self-hosted services,
with the power of [Nix](https://nixos.org/) and [Ansible](https://docs.ansible.com/). 
No systemd, no Docker, and no kernel tweaks required.

- [Getting started](#quickstart)
- [Documentation](https://phomelab.toast.name)

</div>

---

## Why

Your old phones have enough hardware to serve as a homelab machine.
They are free, silent, draw only a couple of watts, and even have a built-in UPS.
The problem is that Linux on a phone, usually deployed via [Termux proot-distro](https://github.com/termux/proot-distro)
or [Linux Deploy](https://github.com/meefik/linuxdeploy), has no working systemd and no cgroups, which breaks Docker
and nearly every self-hosting guide written for a Raspberry Pi.

phomelab works *with* those constraints instead of fighting them:

| Layer | What it gives you |
|---|---|
| **Ansible** | Declarative service playbooks and options |
| **Nix** | Every service comes from nixpkgs at a pinned revision, built on-device and exposed as an atomic `/opt/<service>` symlink. Works without systemd and avoids differences of package managers between distros. |
| **s6** | Supervise services, no init system, no cgroups, no kernel features required. |

## Quickstart

> [!WARNING]
> This section is **not fully documented yet**. PRs are welcome!

### 1. Control machine

You need Nix with flakes enabled. If you don't have it, I recommend getting [Determinate Nix](https://docs.determinate.systems/determinate-nix/) as it has flakes enabled by default.

```bash
git clone https://github.com/lightly-toasted/phomelab-config
cd phomelab-config
nix develop
```

### 2. Prepare the phone
- **Non-rooted (not tested yet)**: [Termux proot-distro](https://github.com/termux/proot-distro)
- **Rooted (recommended, faster)**: [Magisk chroot-distro module](https://github.com/Magisk-Modules-Alt-Repo/chroot-distro)

Then install Determinate Nix and run an ephemeral SSHD process in order to access it from the control machine.
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
nix shell nixpkgs#openssh --command bash -c '
    set -euo pipefail
    mkdir -p /tmp/sshd_tmp
    [ -f /tmp/sshd_tmp/ssh_host_ed25519_key ] || ssh-keygen -f /tmp/sshd_tmp/ssh_host_ed25519_key -N "" -t ed25519
    touch /tmp/sshd_tmp/empty_sshd_config

    $(which sshd) \
        -D \
        -p 2222 \
        -f /tmp/sshd_tmp/empty_sshd_config \
        -h /tmp/sshd_tmp/ssh_host_ed25519_key \
        -o "PidFile=/tmp/sshd_tmp/sshd.pid" \
        -o "UsePAM=no"
'
```
You can also use SSHD from your distro's package manager (for example, apt on Debian or Ubuntu).
However, you'll likely want to manage it through phomelab alongside your other services.

**⚠️ Battery care matters**. To safely keep phones plugged in 24/7, use [ACC](https://github.com/vr-25/acc) (rooted), vendor charge
limits or a smart plug otherwise.

### 3. Configure and run
TODO
<!-- TODO: writing host_vars, keeping nix daemon and s6-svscan running, applying changes to phone via SSH, managing configurations via Git, ... -->

## Status
Early development, the core design is in place, but the documentation and quickstart are incomplete. Contributions are welcome!

- [x] Base
- [ ] Non-rooted support (proot-distro, untested yet) 
- [ ] Documentation
- [ ] Quickstart automation (script or template repository)

## License

[MIT](LICENSE)
