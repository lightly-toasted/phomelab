playbook := "playbooks/site.yml"
vault_file := "group_vars/all/vault.yml"

default:
  @just --list

new APP_NAME ROLE_NAME=(replace_regex(lowercase(APP_NAME), "[ -]", "_")) PACKAGE_NAME=(replace_regex(lowercase(ROLE_NAME), "_", "-")):
  @if [ -d "roles/{{ROLE_NAME}}" ]; then \
    echo "Error: Role {{ROLE_NAME}} already exists."; \
    exit 1; \
  fi
  cp -r roles/hello roles/{{ROLE_NAME}}
  @ref="$(nix-versions -1 -i '{{PACKAGE_NAME}}@latest' 2>/dev/null || true)"; \
  if [ -z "$ref" ]; then ref='""'; echo "[WARN] couldn't automatically fetch latest package reference ({{PACKAGE_NAME}}@latest) for {{ROLE_NAME}}_package" >&2; fi; \
  homepage="$(nix eval --raw "$ref.meta" --apply 'm: m.homepage or ""' 2>/dev/null || true)"; \
  if [ -z "$homepage" ]; then homepage='""'; echo "[WARN] couldn't fetch homepage for {{PACKAGE_NAME}}" >&2; fi; \
  description="$(nix eval --raw "$ref.meta" --apply 'm: m.description or ""' 2>/dev/null || true)"; \
  if [ -z "$description" ]; then description='""'; echo "[WARN] couldn't fetch description for {{PACKAGE_NAME}}" >&2; fi; \
  sed -i "s|nixpkgs/[^#]*#hello|$ref|g" roles/{{ROLE_NAME}}/defaults/main.yml roles/{{ROLE_NAME}}/meta/argument_specs.yml; \
  sed -i 's/hello/{{ROLE_NAME}}/g' roles/{{ROLE_NAME}}/defaults/main.yml; \
  sed -i -e 's/hello/{{ROLE_NAME}}/g' -e 's/GNU Hello/{{APP_NAME}}/g' roles/{{ROLE_NAME}}/tasks/main.yml roles/{{ROLE_NAME}}/meta/argument_specs.yml; \
  sed -i "/^    description:/,/^    seealso:/ s|^      - .*|      - $description|" roles/{{ROLE_NAME}}/meta/argument_specs.yml; \
  sed -i "s|^        link: .*|        link: $homepage|" roles/{{ROLE_NAME}}/meta/argument_specs.yml
  @echo "Created new role {{ROLE_NAME}}"

docs:
  python3 scripts/gen-docs.py
  zensical build

serve-docs:
  python3 scripts/gen-docs.py
  zensical serve

