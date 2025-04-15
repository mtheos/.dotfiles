# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
powerlevel=true

if [[ -v powerlevel ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
if [[ -v powerlevel ]]; then
  ZSH_THEME="../custom/themes/powerlevel10k"
else
  ZSH_THEME="../custom/themes/muse_mod"
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
#ZSH_THEME_RANDOM_CANDIDATES=( "../custom/themes/muse_mod" )

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
zsh-autosuggestions
zsh-autocomplete
zsh-syntax-highlighting
# zsh-vi-mode
)

source $ZSH/oh-my-zsh.sh
#eval $(starship init zsh)

export NVM_DIR="$HOME/.local/lib/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion 

# User configuration

#add go to path
local go_bin="${HOME}/go/bin"
if ! echo "${PATH}" | grep -q "${go_bin}" ; then
  export PATH="${PATH}:${go_bin}"
fi


# Import aliases
if [[ -f ~/.aliases ]]; then
   source ~/.aliases
else
   echo "~/.aliases file not found"
fi

# Run Bootscripts (set path etc)
if [[ -f ~/.bootscripts ]]; then
   source ~/.bootscripts
else
   echo "~/.bootscripts file not found"
fi

if [[ -f ~/.envars ]]; then
   source ~/.envars
else
   echo "~/.envars file not found"
fi

if [[ -f ~/.profile ]]; then
   source ~/.profile
else
   echo "~/.profile file not found"
fi

export GPG_TTY=$(tty)  # needed for gpg key signing
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

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -v powerlevel ]]; then
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

[[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

