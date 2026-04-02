#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

main() {
  "${repo_root}/scripts/bootstrap-prereqs.sh"

  if ! command_exists ansible-playbook; then
    echo "ansible-playbook is still unavailable after dependency bootstrap."
    exit 1
  fi

  if command_exists just && [ "$(id -u)" -ne 0 ]; then
    cd "${repo_root}"
    exec just bootstrap
  fi

  echo "Running direct Ansible apply."
  cd "${repo_root}"
  ANSIBLE_CONFIG=ansible/ansible.cfg ansible-galaxy collection install -r ansible/collections/requirements.yml
  if [ "$(id -u)" -eq 0 ]; then
    exec env ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml
  fi
  if [ "$(uname -s)" = "Darwin" ]; then
    exec env ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml
  fi
  exec env ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook ansible/playbooks/workstation.yml --ask-become-pass
}

main "$@"
