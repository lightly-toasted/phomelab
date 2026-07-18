playbook := "playbooks/site.yml"
vault_file := "group_vars/all/vault.yml"

default:
  @just --list

new APP_NAME ROLE_NAME=(replace_regex(lowercase(APP_NAME), "[ -]", "_")):
  @if [ -d "roles/{{ROLE_NAME}}" ]; then \
    echo "Error: Role {{ROLE_NAME}} already exists."; \
    exit 1; \
  fi
  cp -r roles/hello roles/{{ROLE_NAME}}
  sed -i 's/hello/{{ROLE_NAME}}/g' roles/{{ROLE_NAME}}/defaults/main.yml
  sed -i -e 's/hello/{{ROLE_NAME}}/g' -e 's/Hello World/{{APP_NAME}}/g' roles/{{ROLE_NAME}}/tasks/main.yml
  sed -i 's/hello/{{ROLE_NAME}}/g' roles/{{ROLE_NAME}}/meta/argument_specs.yml
  sed -i 's/Hello World/{{APP_NAME}}/g' roles/{{ROLE_NAME}}/meta/argument_specs.yml
  @echo "Created new role {{ROLE_NAME}}"

docs:
  python3 scripts/gen-docs.py
  zensical build

serve-docs:
  python3 scripts/gen-docs.py
  zensical serve

