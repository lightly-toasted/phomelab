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

