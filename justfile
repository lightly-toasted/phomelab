playbook := "playbooks/site.yml"

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
