#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stow_dir="${repo_root}/stow"
target="${STOW_TARGET:-${HOME}}"
mode="--restow"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists stow; then
  echo "stow is required"
  exit 1
fi

packages=()
for arg in "$@"; do
  case "$arg" in
    --simulate|-n)
      mode="--simulate"
      ;;
    *)
      packages+=("$arg")
      ;;
  esac
done

if [ "${mode}" != "--simulate" ]; then
  "${repo_root}/scripts/prepare-stow-targets.sh"
fi

if [ "${#packages[@]}" -eq 0 ]; then
  while IFS= read -r package; do
    packages+=("${package}")
  done < <(find "${stow_dir}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
fi

for package in "${packages[@]}"; do
  echo "stow ${mode} ${package}"
  stow --dir "${stow_dir}" --target "${target}" "${mode}" "${package}"
done
