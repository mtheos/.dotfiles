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

The new workflow expects:

- `git`
- `ansible`
- `stow`
- `just`

If these are not installed yet, run:

```bash
./scripts/bootstrap-repo.sh
```

That script:

- installs `ansible`, `stow`, and `just` when needed
- installs the required Ansible collection
- runs the repo bootstrap playbook

If you want the manual version, install the collection and run:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-galaxy collection install -r ansible/collections/requirements.yml
```

## Podman test container

For a disposable Ubuntu test container, use:

```bash
./scripts/podman-test.sh
```

That script:

- builds [Containerfile.test](/Users/mtheos/work/dotfiles/Containerfile.test)
- starts a plain Ubuntu container with the repo mounted at `/work/dotfiles`
- runs `./scripts/bootstrap-repo.sh` inside the container

The container is intentionally minimal. The bootstrap script is responsible for
installing `ansible`, `stow`, and `just` when needed.

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
  - installs local prerequisites
  - installs required Ansible collections
  - runs the base bootstrap playbook

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
- Linux desktop wrapper scripts and desktop entries
- Guake preferences
- Docker setup for Debian/Ubuntu

## Notes

- iTerm2 is configured on macOS by pointing it at the static preferences folder
  [files/iterm2](/Users/mtheos/work/dotfiles/files/iterm2) through the path
  `~/.dotfiles/files/iterm2`.
- The old shell installer, backup script, config tree, desktop-entry tree, zsh theme
  tree, and duplicate iTerm export tree have been removed from the canonical repo layout.
