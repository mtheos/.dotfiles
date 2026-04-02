#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

run_if_present() {
  local cmd="$1"
  shift
  if command -v "${cmd}" >/dev/null 2>&1; then
    "$cmd" "$@"
  else
    echo "Skipping ${cmd}; not installed."
  fi
}

bash -n scripts/bootstrap.sh
bash -n scripts/bootstrap-repo.sh
bash -n scripts/check.sh
bash -n scripts/doctor.sh
bash -n scripts/podman-test.sh
bash -n scripts/prepare-stow-targets.sh
bash -n scripts/stow-restow.sh
zsh -n stow/zsh/.zshrc
zsh -n stow/zsh/.aliases
zsh -n stow/zsh/.bootscripts
zsh -n stow/zsh/.p10k.zsh

ANSIBLE_CONFIG="${repo_root}/ansible/ansible.cfg" ansible-playbook --syntax-check ansible/playbooks/bootstrap.yml
ANSIBLE_CONFIG="${repo_root}/ansible/ansible.cfg" ansible-playbook --syntax-check ansible/playbooks/workstation.yml
ANSIBLE_CONFIG="${repo_root}/ansible/ansible.cfg" ansible-playbook --syntax-check ansible/playbooks/backup.yml

run_if_present ansible-lint ansible
run_if_present yamllint ansible .yamllint.yml
tmp_target="$(mktemp -d)"
trap 'rm -rf "${tmp_target}"' EXIT
STOW_TARGET="${tmp_target}" ./scripts/stow-restow.sh --simulate
