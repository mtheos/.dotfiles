set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

bootstrap:
  ./scripts/bootstrap-prereqs.sh
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-galaxy collection install -r ansible/collections/requirements.yml
  if [ "$$(uname -s)" = "Darwin" ]; then ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml; else ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml --ask-become-pass; fi

apply:
  if [ "$$(uname -s)" = "Darwin" ]; then ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml; else ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml --ask-become-pass; fi

backup:
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/backup.yml

stow *packages:
  ./scripts/stow-restow.sh {{packages}}

check:
  ./scripts/check.sh

doctor:
  ./scripts/doctor.sh
