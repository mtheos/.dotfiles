# Dotfiles Rework Plan

## Purpose

This document captures the desired future state for this repo and a concrete plan
to migrate from the current shell-script-based bootstrap flow to a more robust
setup based on Ansible, GNU Stow, and supporting tooling.

The goal is to make the repo:

- more maintainable
- more idempotent
- more portable across machines and operating systems
- easier to audit and evolve over time
- less dependent on one-off imperative shell scripts

## Desired State

### Core responsibilities

- Use `stow` for user-owned files under `$HOME`.
- Use `ansible` for package installation, OS-specific logic, service setup,
  privileged file placement, and one-time/bootstrap operations.
- Use `just` as the human-facing command interface for common workflows.
- Use linting and validation tools to keep the repo healthy over time.

### Ownership boundary

#### Stow should manage

- shell dotfiles such as `.zshrc`, `.p10k.zsh`, `.aliases`
- Git config and related dotfiles
- Vim config and similar editor dotfiles
- user-local scripts under `~/.local/bin`
- app config under `~/.config` where practical
- exported user-level assets that belong in the home directory

#### Ansible should manage

- package installation
- OS detection and per-platform branching
- Docker repository and package setup
- `oh-my-zsh` installation and plugin/theme bootstrap
- desktop entry installation to system locations
- Guake or other app preference import flows
- fonts, services, and system packages
- backup and restore workflows
- validation and machine bootstrap steps

#### Stow should not manage

- `/usr/bin`
- `/usr/share/applications`
- package manager repositories
- service definitions
- any privileged system path

### Operator workflow

The repo should converge on a small set of predictable commands:

- `just bootstrap` to install local prerequisites such as `ansible` and `stow`
- `just apply` to apply the full workstation configuration
- `just stow` to restow user dotfiles
- `just check` to run linting and validation
- `just backup` to run the defined backup flow
- `just doctor` to verify the local environment and detect drift

### Proposed repo layout

```text
dotfiles/
  ansible/
    inventories/
      localhost.yml
    group_vars/
      all.yml
    playbooks/
      bootstrap.yml
      workstation.yml
      backup.yml
    roles/
      base/
      shell/
      git/
      editors/
      desktop/
      docker/
      fonts/
      macos/
      linux/
      backup/
  stow/
    zsh/
      .zshrc
      .p10k.zsh
      .aliases
      .bootscripts
      .manualscripts
    git/
      .gitconfig
      .gitattributes
    vim/
      .vimrc
    gdb/
      .gdbinit
    local-bin/
      .local/bin/...
    config/
      .config/...
  files/
    guake/
    iterm2/
    desktop_entries/
  templates/
    gitconfig.j2
    zshrc.j2
  justfile
  .ansible-lint
  .yamllint.yml
  .stowrc
  README.md
```

### Supporting tools

Recommended supporting tools:

- `ansible-lint`
- `yamllint`
- `pre-commit`
- `just`
- `shellcheck`
- `age` or `sops` later if secrets need to be managed

Optional:

- `mise` if reproducible local tool versions become useful for maintaining the
  repo itself

## Migration Plan

### 1. Freeze and document current behavior

Before moving anything, document what the current repo actually does:

- installed packages
- shell plugins and themes
- desktop entries and wrapper scripts
- Guake preferences
- Docker setup
- backup and restore behavior
- any OS-specific assumptions

This reduces the risk of accidentally dropping behavior during migration.

### 2. Define the ownership boundary

Separate the current repo contents into three classes:

- home-directory dotfiles suitable for Stow
- machine bootstrap and privileged operations suitable for Ansible
- legacy or obsolete content that should be removed instead of migrated

This step should happen before implementing new automation so the new structure
does not inherit the current ambiguity.

### 3. Add the Ansible skeleton

Create the initial Ansible structure:

- localhost inventory
- shared variables
- `bootstrap.yml`
- `workstation.yml`
- `backup.yml`
- baseline roles for `base`, `shell`, `git`, `desktop`, and `docker`

At this stage the playbooks can be minimal. The important part is creating a
clear structure that future changes fit into cleanly.

### 4. Add the Stow skeleton

Create a `stow/` directory and begin with the lowest-risk packages:

- `git`
- `zsh`
- `vim`
- `gdb`

Migrate these package-by-package and verify each one independently.

Prefer XDG-compatible paths for any newly introduced config rather than adding
more top-level dotfiles.

### 5. Replace install.sh incrementally

Port `install.sh` behavior into Ansible roles in small slices:

- base package installation
- shell framework and plugin install
- theme and prompt setup
- desktop entry installation
- Docker repository and package setup
- application preference imports

Do not attempt a big-bang rewrite. Keep each slice separately testable.

### 6. Move package management into Ansible

Use Ansible modules and OS-specific vars instead of ad hoc shell logic.

Examples:

- `apt` on Debian/Ubuntu
- `community.general.homebrew` or equivalent on macOS
- `pacman` on Arch
- distro-specific repository setup where needed

This should eliminate the fragile package-manager detection in the current shell
scripts and make the supported platforms explicit.

### 7. Move user dotfiles into Stow

Convert the existing `configs/` contents into Stow packages.

Initial candidates:

- `.zshrc`
- `.p10k.zsh`
- `.aliases`
- `.bootscripts`
- `.manualscripts`
- `.gitconfig`
- `.gitattributes`
- `.vimrc`
- `.gdbinit`

Where dynamic values are required, prefer templating with Ansible rather than
embedding machine-specific values directly into tracked files.

### 8. Rework desktop entries and wrappers

The current repo copies wrappers and `.desktop` files into system paths.

The new approach should:

- treat desktop launchers as Ansible-managed assets
- install them with correct permissions and absolute paths
- avoid shell-script copying logic
- normalize icons and launcher metadata

Any system-level file should be installed by Ansible, not by Stow.

### 9. Rework shell bootstrap

The shell environment should be split into:

- static user config managed by Stow
- installed dependencies and plugins managed by Ansible
- templated config only where machine-specific settings are required

This should also be the point where legacy Bash-era references and stale aliases
are cleaned up instead of carried forward blindly.

### 10. Rework backup and restore

The current backup flow should not be carried over as-is.

Decide whether backups are meant to support:

- dotfiles-only recovery
- machine rebuild bootstrap
- full personal workstation backup

If machine bootstrap is the goal, implement it as a documented Ansible-backed
workflow, not as a tarball script that mixes package state and home-directory
data.

### 11. Add validation and quality gates

Introduce validation early:

- `ansible-lint`
- `yamllint`
- `shellcheck`
- `stow --simulate`
- shell syntax checks where applicable
- optional `pre-commit` hooks

This should be wired into `just check`.

### 12. Document supported platforms explicitly

The rewritten repo should define exactly what is supported.

At minimum, document:

- supported Linux distributions
- macOS support scope
- optional tools and roles
- unsupported legacy paths or assumptions

The repo should stop pretending to be generic where it is not actually generic.

### 13. Remove legacy scripts after parity is reached

Only after the new Ansible and Stow workflows have feature parity:

- archive or remove `install.sh`
- archive or remove `backup.sh`
- update the `README.md` to point to the new workflow

The final repo should have one primary setup path rather than multiple competing
entrypoints.

## Suggested Execution Order

1. Add `just`, lint config, and the initial Ansible skeleton.
2. Add the `stow/` layout and migrate `git`, `zsh`, `vim`, and `gdb`.
3. Port package-install and Docker logic into Ansible roles.
4. Port desktop entries, wrappers, and app preference imports.
5. Rework backup and restore into a documented workflow.
6. Remove or archive legacy shell installers once the new path is stable.
7. Simplify the `README.md` to describe the new canonical setup flow.

## Success Criteria

The migration should be considered complete when:

- dotfiles are applied through Stow without manual symlink logic
- machine configuration is applied through Ansible playbooks
- rerunning setup is idempotent
- supported operating systems are explicit
- no critical setup step depends on undocumented shell behavior
- the repo has a single documented bootstrap and apply workflow
- validation can be run locally with a single command

## Notes for Future Work

- Secrets management should be deferred until the basic structure is stable.
- XDG migration is worth doing where practical, but it should not block the
  first Ansible/Stow transition.
- Legacy personal aliases and machine-specific hacks should be reviewed
  critically during migration instead of copied over by default.
