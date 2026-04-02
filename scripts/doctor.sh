#!/usr/bin/env bash
set -euo pipefail

missing=()
for cmd in git stow ansible-playbook just; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    missing+=("${cmd}")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing commands: ${missing[*]}"
else
  echo "Required commands are installed."
fi

echo "Broken symlinks under \$HOME:"
find "${HOME}" -maxdepth 3 -type l ! -exec test -e {} \; -print || true
