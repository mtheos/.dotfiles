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

export ANSIBLE_LOCAL_TEMP="${ANSIBLE_LOCAL_TEMP:-${TMPDIR:-/tmp}}"
export ANSIBLE_CONFIG="${repo_root}/ansible/ansible.cfg"
repo_collection_paths="${repo_root}/ansible/collections:${repo_root}/.ansible/collections"
export ANSIBLE_COLLECTIONS_PATH="${repo_collection_paths}${ANSIBLE_COLLECTIONS_PATH:+:${ANSIBLE_COLLECTIONS_PATH}}"

if command -v ansible-galaxy >/dev/null 2>&1; then
  collection_root="$(
    ansible-galaxy collection list community.general --format json 2>/dev/null |
      sed -n 's/^{"\([^"]*\/ansible_collections\)".*/\1/p'
  )" || collection_root=""
  if [ -n "${collection_root}" ]; then
    collection_parent="${collection_root%/ansible_collections}"
    export ANSIBLE_COLLECTIONS_PATH="${collection_parent}:${ANSIBLE_COLLECTIONS_PATH}"
  fi
fi

bash -n scripts/bootstrap.sh
bash -n scripts/bootstrap-prereqs.sh
bash -n scripts/check.sh
bash -n scripts/doctor.sh
bash -n scripts/podman-test.sh
bash -n scripts/prepare-stow-targets.sh
bash -n scripts/stow-restow.sh
zsh -n stow/zsh/.zshrc
zsh -n stow/zsh/.aliases
zsh -n stow/zsh/.bootscripts
zsh -n stow/zsh/.p10k.zsh

run_if_present ansible-playbook --syntax-check ansible/playbooks/bootstrap.yml
run_if_present ansible-playbook --syntax-check ansible/playbooks/workstation.yml
run_if_present ansible-playbook --syntax-check ansible/playbooks/backup.yml

run_if_present ansible-lint ansible
run_if_present yamllint ansible .yamllint.yml
tmp_target="$(mktemp -d)"
trap 'rm -rf "${tmp_target}"' EXIT
STOW_TARGET="${tmp_target}" ./scripts/stow-restow.sh --simulate
