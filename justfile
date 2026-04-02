set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

bootstrap:
  ./scripts/bootstrap.sh
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-galaxy collection install -r ansible/collections/requirements.yml
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/bootstrap.yml --ask-become-pass

apply:
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml --ask-become-pass

backup:
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/backup.yml

stow *packages:
  ./scripts/stow-restow.sh {{packages}}

check:
  ./scripts/check.sh

doctor:
  ./scripts/doctor.sh
