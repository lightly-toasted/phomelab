# phomelab

Run your homelab on phones.

## Role Conventions

All service roles (tagged `service` in `playbooks/site.yml`) follow a standard
interface for variable naming and structure.

### Naming

All role variables are prefixed with the role name followed by an underscore:

- `redis_enabled`, `redis_user`, `redis_port`
- `navidrome_enabled`, `navidrome_user`, `navidrome_port`

### Standard Variables

Variables that serve the same purpose have the same name across roles:

| Variable suffix | Type | Purpose |
|---|---|---|
| `_enabled` | `bool` | Enable or disable the service |
| `_user` | `str` | System user for the service |
| `_group` | `str` | System group for the service |
| `_package` | `str` | Nix package attribute (e.g. `nixpkgs#redis`) |
| `_package_path` | `str` | Nix build output path (e.g. `/opt/redis`) |
| `_port` | `str` | TCP port the service listens on |
| `_data_dir` | `str` | Service data directory |
| `_config_dir` | `str` | Service configuration directory |
| `_env` | `dict` | Environment variables passed to the s6 service |
| `_config` | `str` | Raw configuration file content |

Not every role declares every variable. The table above shows the naming
convention, and each role's page lists which variables it actually exposes.

### Variable Definitions

Each role's variables are defined in `meta/argument_specs.yml` with full type
and description metadata. This file is the single source of truth and also
enables Ansible's built-in role argument validation at runtime.
