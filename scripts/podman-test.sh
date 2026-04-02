#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_name="${IMAGE_NAME:-dotfiles-test}"
bootstrap_tz="${BOOTSTRAP_TZ:-Australia/Sydney}"

if ! command -v podman >/dev/null 2>&1; then
  echo "podman is required"
  exit 1
fi

podman build -f "${repo_root}/Containerfile.test" -t "${image_name}" "${repo_root}"

exec podman run --rm -it \
  -e TZ="${bootstrap_tz}" \
  -e BOOTSTRAP_TZ="${bootstrap_tz}" \
  -v "${repo_root}:/work/dotfiles:Z" \
  -w /work/dotfiles \
  "${image_name}" \
  /bin/bash
