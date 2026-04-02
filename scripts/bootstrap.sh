#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_TZ="${BOOTSTRAP_TZ:-Australia/Sydney}"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_privileged() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

run_apt_noninteractive() {
  if [ "$(id -u)" -eq 0 ]; then
    DEBIAN_FRONTEND=noninteractive TZ="${BOOTSTRAP_TZ}" "$@"
  else
    sudo DEBIAN_FRONTEND=noninteractive TZ="${BOOTSTRAP_TZ}" "$@"
  fi
}

configure_debian_timezone() {
  if [ ! -e "/usr/share/zoneinfo/${BOOTSTRAP_TZ}" ]; then
    echo "Timezone data for ${BOOTSTRAP_TZ} is unavailable; skipping timezone preseed."
    return
  fi

  run_privileged ln -snf "/usr/share/zoneinfo/${BOOTSTRAP_TZ}" /etc/localtime
  run_privileged sh -c "printf '%s\n' '${BOOTSTRAP_TZ}' > /etc/timezone"

  if command_exists dpkg-reconfigure; then
    run_apt_noninteractive dpkg-reconfigure -f noninteractive tzdata
  fi
}

install_with_brew() {
  brew install ansible stow just
}

install_with_apt() {
  configure_debian_timezone
  run_apt_noninteractive apt update
  run_apt_noninteractive apt install -y ansible stow git curl
  if apt-cache show just >/dev/null 2>&1; then
    run_apt_noninteractive apt install -y just
  else
    echo "Package 'just' is not available via apt on this system. Install it manually if needed."
  fi
}

install_with_pacman() {
  run_privileged pacman -Syu --noconfirm ansible stow just git curl
}

main() {
  if command_exists ansible-playbook && command_exists stow && command_exists just; then
    echo "Bootstrap dependencies already installed."
    exit 0
  fi

  if command_exists brew; then
    install_with_brew
    exit 0
  fi

  if command_exists apt; then
    install_with_apt
    exit 0
  fi

  if command_exists pacman; then
    install_with_pacman
    exit 0
  fi

  echo "Unsupported package manager. Install ansible, stow, just, git, and curl manually."
  exit 1
}

main "$@"
