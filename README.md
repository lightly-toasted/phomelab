# homelab-ansible
Declarative configuration for my homelab using Ansible.

## Inventory
- `y2q` — Spare Galaxy S20+ phone, repurposed as a Ubuntu server using [chroot-distro](https://github.com/Magisk-Modules-Alt-Repo/chroot-distro).

## Playbook


## Usage
```sh
nix develop

just ping
just apply # run full Ansible playbook
just check # dry-run
just apply-tags TAGS # run playbook with specific tags

```
