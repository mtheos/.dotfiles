#!/usr/bin/env bash

#set umask
umask 022

# Variables
declare -a PACKAGES=(git guake vim curl wget zsh)
declare -a CONFIGS=(.gdbinit .gitconfig .aliases .bootscripts .manualscripts .vimrc .zshrc .p10k.zsh)
GUAKE_PREFERENCES=guake.dconf
DOTFILES_REPO=https://github.com/mtheos/.dotfiles.git
ROOT=~/.dotfiles
CONFIG=$ROOT/configs
TMP=$ROOT/tmp
ZSH_DIR=~/.oh-my-zsh
ZSH_CUSTOM=$ZSH_DIR/custom
BIN_DIR=$ROOT/desktop_entries/bin
DESKTOP_DIR=$ROOT/desktop_entries/desktop

ZSH_THEME_MUSE_FROM=$ROOT/zsh_themes/muse_mod.zsh-theme
ZSH_THEME_MUSE_TO=$ZSH_CUSTOM/themes/muse_mod.zsh-theme
ZSH_THEME_POWERLEVEL_FROM=$ROOT/zsh_themes/powerlevel10k/powerlevel10k.zsh-theme
ZSH_THEME_POWERLEVEL_TO=$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme

# Repo path locations
VUNDLE_LOC=~/.vim/bundle/Vundle.vim
PWNDBG_LOC=~/.local/lib/pwndbg

# Repo github URLs
OH_MY_ZSH=https://github.com/ohmyzsh/ohmyzsh.git
declare -a ZSH_PLUGINS=(
  https://github.com/marlonrichert/zsh-autocomplete.git
  https://github.com/zsh-users/zsh-autosuggestions.git
  https://github.com/zsh-users/zsh-syntax-highlighting.git
  https://github.com/jeffreytse/zsh-vi-mode.git
)
VUNDLE=https://github.com/VundleVim/Vundle.vim.git
PWNDBG=https://github.com/pwndbg/pwndbg

# Powerpill AUR package
POWERPILL=https://xyne.archlinux.ca/projects/powerpill/pkgbuild.tar.gz
POWERPILL_NAME=pkgbuild.tar.gz
POWERPILL_LOC=pkgbuild
XYNE_PGP_SIG=1D1F0DC78F173680

# Functions
command_exists() {
  command -v $@ >/dev/null 2>&1
}

identify_package_manager() {
  declare -A pkm
  pkm[emerge]="emerge -a"
  pkm[apt]="apt install -y"
  pkm[yum]="yum install -y"
  pkm[zypp]="zypp install -y"
  pkm[pacman]="pacman -S --noconfirm"
  pkm[brew]="brew install"

  if [ -z $PACMAN ]; then
    echo Package manager not set... Trying to identify
  else
    echo "PACMAN set in shell. Using => $PACMAN"
    return
  fi

  for cmd in ${!pkm[@]}; do
    echo checking $cmd
    if command_exists $cmd; then
      echo "Using => ${pkm[$cmd]}"
      PACMAN=${pkm[$cmd]}
      echo Set manually if not correct
      return
    fi
  done

  echo Package manager not identified. Set PACMAN with install command \"sudo apt install...\"
  exit 1
}

update_package_definitions() {
  while [ $# -gt 0 ]; do
    case $1 in
    --update) UPDATE=yes ;;
    esac
    shift
  done
  if [ -z $UPDATE ]; then
    echo Running without updating, use --update to change this behaviour
  else
    echo Updating package definitions...
    sudo apt update
  fi
}

install_package() {
  sudo $PACMAN $@
}

install_packages() {
  echo
  echo Installing packages
  for pkg in ${PACKAGES[@]}; do
    echo -n "  * Trying $pkg..."
    if command_exists $pkg; then
      echo "${pkg} already installed :)"
    else
      install_package $pkg
      echo Done!
    fi
  done
}

powerpill_arch_only() {
  # If not arch do nothing
  if [ ! -f /etc/arch-release ]; then
    echo "Powerpill is an AUR package"
    echo "Ignored as current OS is non-Arch (bad code if wrong)"
    return
  else
    echo "Installing AUR dependencies + Powerpill"
  fi

  # hacky
  sudo pacman -S --noconfirm binutils base-devel

  wget $POWERPILL -O $POWERPILL_NAME
  tar -xf $POWERPILL_NAME
  cd $POWERPILL_LOC

  pacman-key --export $XYNE_PGP_SIG >xyne.asc
  gpg --import xyne.asc
  rm xyne.asc
  makepkg -si
  cd ..
  rm -rf $POWERPILL_LOC
  rm $POWERPILL_NAME
}

check_configs_exist() {
  echo
  echo Checking configs
  for conf in ${CONFIGS[@]}; do
    echo -n "  * Trying $conf..."
    if [ -f $CONFIG/$conf ]; then
      echo Exists!
    else
      echo Error! $conf not found!
    fi
  done
}

link_configs() {
  echo
  echo Linking configs
  for conf in ${CONFIGS[@]}; do
    echo -n "  * Trying $conf..."
    if [ -f $CONFIG/$conf ]; then
      if [ -f ~/$conf ]; then
        if ! [ -h ~/$conf ]; then
          mv ~/$conf $TMP/$conf.bup
        fi
      fi
      ln -s $CONFIG/$conf ~/$conf
      echo "Linked configs/$conf ===> ~/$conf"
    else
      echo Skipping! $conf not found!
    fi
  done
}

guake_preferences() {
  echo
  echo Setting up Guake preferences
  echo -n "  * Trying $GUAKE_PREFERENCES..."
  if [ -f $CONFIG/$GUAKE_PREFERENCES ]; then
    dconf load /apps/guake/ <$CONFIG/$GUAKE_PREFERENCES
    echo "imported $GUAKE_PREFERENCES"
  else
    echo Skipping! $GUAKE_PREFERENCES not found!
  fi
}

install_ohmyzsh() {
  if [ -d $ZSH_DIR ]; then
    echo oh-my-zsh exists, skipping installation
  else
    echo Cloning oh-my-zsh
    git clone $OH_MY_ZSH $ZSH_DIR
  fi
}

dir_name_from_git_url() {
  local url="$1"
  local name=$(basename "$url")
  name="${name%.*}"
  echo "$name"
}

install_zsh_plugins() {
  for plugin in ${ZSH_PLUGINS[@]}; do
    install_zsh_plugin $ZSH_CUSTOM/plugins $plugin
  done
}

install_zsh_plugin() {
  local plugin_dir=$1
  local url=$2
  local plugin=$(dir_name_from_git_url $url)
  local dst="${plugin_dir}/${plugin}"
  if [ -d $dst ]; then
    echo $plugin exists, skipping installation
    return
  fi
  echo Installing $plugin
  mkdir -p $dst
  git clone $url $dst
}

install_zsh_themes() {
  install_zsh_theme $ZSH_THEME_MUSE_FROM $ZSH_THEME_MUSE_TO
  install_zsh_theme $ZSH_THEME_POWERLEVEL_FROM $ZSH_THEME_POWERLEVEL_TO
}

install_zsh_theme() {
  local from=$1
  local to=$2
  if [ -f $to ]; then
    echo $(basename $to) exists, skipping installation
    return
  fi
  echo Installing $to
  ln -s $from $to
}

install_vundle() {
  if [ -d $VUNDLE_LOC ]; then
    echo Vundle exists, skipping installation
    return
  fi
  echo Installing Vundle
  mkdir -p $VUNDLE_LOC
  git clone $VUNDLE $VUNDLE_LOC
}

install_pwndbg() {
  if [ -d $PWNDBG_LOC ]; then
    echo Pwndbg exists, skipping installation
    return
  fi
  echo Installing pwndbg
  mkdir -p $PWNDBG_LOC
  git clone $PWNDBG $PWNDBG_LOC
  sh -c $(
    cd $PWNDBG_LOC
    ./setup.sh
  )
}

create_desktop_links() {
  for file in $(ls $BIN_DIR); do
    if [ -f /usr/bin/$file ]; then
      echo File /usr/bin/$file exists
    else
      sudo cp $BIN_DIR/$file /usr/bin/$file && echo Creating /usr/bin/$file
    fi
  done

  for file in $(ls $DESKTOP_DIR); do
    if [ -f /usr/share/applications/$file ]; then
      echo File /usr/share/applications/$file exists
    else
      sudo cp $DESKTOP_DIR/$file /usr/share/applications/$file && echo Creating /usr/share/applications/$file
    fi
  done
}

clone_repo_if_missing() {
  if ! [ -d $ROOT ]; then
    git clone $DOTFILES_REPO $ROOT
  fi
}

init_submodules() {
  local cwd=$(pwd)
  cd $ROOT
  git submodule init
  git submodule update
  cd $cwd
}

install_docker() {
  echo
  echo Installing docker
  if command_exists docker; then
    echo "Docker already installed :)"
    return
  fi
  install_docker_apt
  install_docker_cli
  echo "Docker installed"
}

install_docker_apt() {
  echo
  if ! command_exists apt; then
    echo "can't find apt, this probably isn't a Debian OS."
    echo "Docker installation will continue, but may fail if docker signing keys need to be manually added."
    return
  fi

  echo Adding docker to apt sources
  if grep -r "download.docker.com" /etc/apt/sources.list /etc/apt/sources.list.d/ > /dev/null; then
    echo "Docker repo exists in apt sources"
  fi
  echo "Adding docker repo to apt sources"
  # Add Docker's official GPG key:
  sudo apt update
  sudo apt install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  # refresh apt
  sudo apt update
}

install_docker_cli() {
  echo
  echo Installing docker
  if command_exists docker; then
    echo "Already installed :)"
  fi
  install_package docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

clean_up() {
  directory=$(cd $(dirname $0) && pwd)
  file=$(basename $0)
  if ! [ $directory = $ROOT ]; then
    echo Clearing script
    echo Script can be run from $ROOT/install.sh
    rm $directory/$file
  fi
}

main() {
  title_script
  identify_package_manager
  # only works for debian atm (yum/pacman don't need this??)
  update_package_definitions "$@"
  # Install basic packages
  install_packages
  # Before this point we may not have git
  clone_repo_if_missing
  # poewrlevel 10k is a submodule
  init_submodules
  # Install oh-my-zsh
  install_ohmyzsh
  # Install oh-my-zsh plugins
  install_zsh_plugins
  # Install oh-my-zsh theme(s)
  install_zsh_themes
  # Install Vundle
  install_vundle
  # Install pwndbg
  # install_pwndbg # skip pwndbg install
  create_desktop_links
  # Notify if any config files don't exist
  check_configs_exist
  # Link all config files that do exist
  link_configs
  guake_preferences
  powerpill_arch_only
  install_docker
  # Delete script if not in home_conf dir
  clean_up
  # Drop into the ZSH shell... Don't exec so we can jump back if necessary
  zsh
}

# Nice but too big
title_caligraphy() {
  cat <<-'EOF'

     ***** *    **   ***              ***                                                              *****    **
  ******  *  *****    ***              ***                                                          ******  *  **** *
 **   *  *     *****   ***              **                                                         **   *  *   *****
*    *  **     * **      **             **                                                        *    *  *    * *
    *  ***     *         **             **                  ****                                      *  *     *         ****
   **   **     *         **    ***      **       ****      * ***  * *** **** ****       ***          ** **     *        * ***  * *** **** ****       ***
   **   **     *         **   * ***     **      * ***  *  *   ****   *** **** ***  *   * ***         ** **     *       *   ****   *** **** ***  *   * ***
   **   **     *         **  *   ***    **     *   ****  **    **     **  **** ****   *   ***        ** ********      **    **     **  **** ****   *   ***
   **   **     *         ** **    ***   **    **         **    **     **   **   **   **    ***       ** **     *      **    **     **   **   **   **    ***
   **   **     *         ** ********    **    **         **    **     **   **   **   ********        ** **     **     **    **     **   **   **   ********
    **  **     *         ** *******     **    **         **    **     **   **   **   *******         *  **     **     **    **     **   **   **   *******
     ** *      *         *  **          **    **         **    **     **   **   **   **                 *       **    **    **     **   **   **   **
      ***      ***      *   ****    *   **    ***     *   ******      **   **   **   ****    *      ****        **     ******      **   **   **   ****    *
       ******** ********     *******    *** *  *******     ****       ***  ***  ***   *******      *  *****      **     ****       ***  ***  ***   *******
         ****     ****        *****      ***    *****                  ***  ***  ***   *****      *     **                          ***  ***  ***   *****
                                                                                                  *
                                                                                                   **

Configuring home directory
EOF
}

title_script() {
  cat <<-'EOF'
 _              _                              ,
(_|   |   |_/  | |                            /|   |
  |   |   | _  | |  __   __   _  _  _    _     |___|  __   _  _  _    _
  |   |   ||/  |/  /    /  \_/ |/ |/ |  |/     |   |\/  \_/ |/ |/ |  |/
   \_/ \_/ |__/|__/\___/\__/   |  |  |_/|__/   |   |/\__/   |  |  |_/|__

Configuring home directory
EOF
}

main "$@"
