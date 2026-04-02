# Enable Powerlevel10k instant prompt. Anything that may prompt for input needs
# to stay above this block.
typeset -g powerlevel=true

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="${HOME}/.oh-my-zsh"

if [[ -n "${powerlevel:-}" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME="muse_mod"
fi

plugins=(
  git
  zsh-autosuggestions
  zsh-autocomplete
  zsh-syntax-highlighting
)

source "${ZSH}/oh-my-zsh.sh"

export NVM_DIR="${HOME}/.local/lib/nvm"
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"
[ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"

local go_bin="${HOME}/go/bin"
if [[ ":${PATH}:" != *":${go_bin}:"* ]]; then
  export PATH="${PATH}:${go_bin}"
fi

for file in ~/.aliases ~/.bootscripts ~/.envars ~/.profile; do
  if [[ -f "${file}" ]]; then
    source "${file}"
  fi
done

export GPG_TTY="$(tty)"
export HISTSIZE=100000000
export SAVEHIST=100000000

setopt append_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_verify
setopt share_history

[[ -f "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"
[[ -f "${HOME}/.fzf.zsh" ]] && source "${HOME}/.fzf.zsh"

if [[ -n "${powerlevel:-}" && -f "${HOME}/.p10k.zsh" ]]; then
  source "${HOME}/.p10k.zsh"
fi

if ! command -v nix >/dev/null 2>&1 && [[ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
  source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

. "/home/michael/.deno/env"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
