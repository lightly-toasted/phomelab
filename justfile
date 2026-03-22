playbook := "playbooks/site.yml"
vault_file := "group_vars/all/vault.yml"

default:
  @just --list

apply:
  ansible-playbook {{playbook}}

apply-tags TAGS:
  ansible-playbook {{playbook}} --tags {{TAGS}}

apply-limit LIMIT:
  ansible-playbook {{playbook}} --limit {{LIMIT}}

check:
  ansible-playbook {{playbook}} --check --diff

ping:
  ansible all -m ping

vault-edit FILE=vault_file:
  ansible-vault edit {{FILE}}

vault-view FILE=vault_file:
  ansible-vault view {{FILE}}

vault-encrypt FILE=vault_file:
  ansible-vault encrypt {{FILE}}

vault-decrypt FILE=vault_file:
  ansible-vault decrypt {{FILE}}

new APP_NAME ROLE_NAME=(replace_regex(lowercase(APP_NAME), "[ -]", "_")):
  @if [ -d "roles/{{ROLE_NAME}}" ]; then \
    echo "Error: Role {{ROLE_NAME}} already exists."; \
    exit 1; \
  fi
  cp -r roles/hello roles/{{ROLE_NAME}}
  sed -i 's/hello/{{ROLE_NAME}}/g' roles/{{ROLE_NAME}}/defaults/main.yml
  sed -i -e 's/hello/{{ROLE_NAME}}/g' -e 's/Hello World/{{APP_NAME}}/g' roles/{{ROLE_NAME}}/tasks/main.yml
  @echo "Created new role {{ROLE_NAME}}"

