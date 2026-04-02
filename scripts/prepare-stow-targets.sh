#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stow_dir="${repo_root}/stow"
target="${STOW_TARGET:-${HOME}}"
backup_root="${HOME}/.local/state/dotfiles-pre-stow-backup/$(date +%Y%m%d%H%M%S)"

mkdir -p "${backup_root}"

while IFS= read -r src_rel; do
  package="${src_rel%%/*}"
  rel_path="${src_rel#*/}"
  target_path="${target}/${rel_path}"

  if [ ! -e "${target_path}" ] && [ ! -L "${target_path}" ]; then
    continue
  fi

  if [ -L "${target_path}" ]; then
    link_target="$(readlink "${target_path}" || true)"
    if [[ "${link_target}" == *".dotfiles/stow/${package}/"* ]]; then
      continue
    fi
  fi

  backup_path="${backup_root}/${rel_path}"
  mkdir -p "$(dirname "${backup_path}")"
  mv "${target_path}" "${backup_path}"
  echo "Moved ${target_path} -> ${backup_path}"
done < <(cd "${stow_dir}" && find . -mindepth 2 \( -type f -o -type l \) | sed 's#^\./##' | sort)
