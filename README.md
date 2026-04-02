# dotfiles

This repo now uses:

- `ansible` for machine bootstrap, package management, and system-level setup
- `stow` for user-owned dotfiles under `$HOME`
- `just` as the main command interface

The long-term migration plan lives in [docs/ansible-stow-rework-plan.md](docs/ansible-stow-rework-plan.md).

## Repo layout

```text
ansible/   Playbooks, inventories, roles, and collections
stow/      Home-directory dotfiles managed with GNU Stow
files/     Supporting assets installed by Ansible
scripts/   Helper scripts for bootstrap, validation, and Stow operations
docs/      Project planning and reference docs
```

## Prerequisites

If `ansible` and `stow` are not installed yet, run:

```bash
./scripts/bootstrap.sh
```

That script:

- installs bootstrap prerequisites such as `ansible` and `stow`
- installs the required Ansible collection
- applies the full workstation playbook, including packages and Stow-managed dotfiles

## Podman test container

For a disposable Ubuntu test container, use:

```bash
./scripts/podman-test.sh
```

That script:

- builds [Containerfile.test](/Users/mtheos/work/dotfiles/Containerfile.test)
- starts a plain Ubuntu container with the repo mounted at `/work/dotfiles`
- runs `./scripts/bootstrap.sh` inside the container

The container is intentionally minimal. The bootstrap entrypoint is responsible for
installing prerequisites and applying the repo.

## Main commands

```bash
just bootstrap
just apply
just stow
just check
just doctor
just backup
```

### What they do

- `just bootstrap`
  - installs local prerequisites needed to run Ansible
  - installs required Ansible collections
  - applies the full workstation playbook

- `just apply`
  - applies the workstation playbook
  - installs packages
  - installs shell tooling
  - installs desktop assets
  - applies Stow-managed dotfiles

- `just stow`
  - reapplies the Stow packages under `stow/`

- `just check`
  - runs shell syntax checks
  - runs Ansible syntax checks
  - runs Stow in simulate mode
  - runs lint tools when installed locally

- `just doctor`
  - checks for required commands
  - prints broken symlinks under `$HOME`

- `just backup`
  - exports a machine manifest and package lists to `~/.local/state/dotfiles-backup`

## Current migration status

The new layout is in place and is the preferred path going forward.

Migrated into Stow:

- `.zshrc`
- `.aliases`
- `.bootscripts`
- `.manualscripts`
- `.p10k.zsh`
- `.gitconfig`
- `.gitattributes`
- `.vimrc`
- `.gdbinit`

Migrated into Ansible-managed assets:

- `oh-my-zsh`
- zsh plugins
- `powerlevel10k`
- custom `muse_mod` theme
- iTerm2 custom preferences via `~/.dotfiles/files/iterm2`
- Guake preferences
- Docker setup for Debian/Ubuntu

## Notes

- iTerm2 is configured on macOS by pointing it at the static preferences folder
  [files/iterm2](/Users/mtheos/work/dotfiles/files/iterm2) through the path
  `~/.dotfiles/files/iterm2`.
- The old shell installer, backup script, config tree, desktop-entry tree, zsh theme
  tree, and duplicate iTerm export tree have been removed from the canonical repo layout.
