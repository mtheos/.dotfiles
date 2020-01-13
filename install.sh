#!/bin/bash

# Variables
declare -a packages=(git npm vim zsh)
declare -a configs=( .bash_prompt .bashrc .gdbinit .gitconfig .npmrc .profile .term_aliases .term_bootscripts .term_manualscripts .vimrc .zshrc )
CONFIG=~/.homedir_conf/configs
TMP=~/.homedir_conf/tmp
ZSH_CUSTOM=~/.oh-my-zsh/custom

# Repo clone locations
#OHMYZSH_LOC=~/.oh-my-zsh
ZSH_AUTO_COMPLETE_LOC=$ZSH_CUSTOM/plugins/zsh-autosuggestions
ZSH_SYNTAX_HIGHLIGHTING_LOC=$ZSH_CUSTOM/plugins/zsh-syntax-highlighting
VUNDLE_LOC=~/.vim/bundle/Vundle.vim
PWNDBG_LOC=~/.local/lib/pwndbg

# Repos
#OHMYZSH=https://github.com/ohmyzsh/ohmyzsh.git
ZSH_AUTO_COMPLETE=https://github.com/zsh-users/zsh-autosuggestions.git
ZSH_SYNTAX_HIGHLIGHTING=https://github.com/zsh-users/zsh-syntax-highlighting.git
VUNDLE=https://github.com/VundleVim/Vundle.vim.git
PWNDBG=https://github.com/pwndbg/pwndbg

# Scripts
OHMYZSH=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

# Functions
command_exists() {
   command -v $@ >/dev/null 2>&1
}

install_package() {
   sudo apt install $@ -y
}

install_packages() {
   echo; echo Installing packages
   for pkg in ${packages[@]}
   do
      echo -n "  * Trying $pkg..."
      if ! command_exists $pkg; then
         install_package $pkg
         echo Done!
      else 
         echo "Already installed :)"
      fi
   done
}

check_configs_exist() {
   echo; echo Checking configs
   for conf in ${configs[@]}
   do
      echo -n "  * Trying $conf..."
      if [ -f $CONFIG/$conf ]; then
         echo Exists!
      else 
         echo Error! $conf not found!
      fi
   done
}

link_configs() {
   echo; echo Linking configs
   for conf in ${configs[@]}
   do
      echo -n "  * Trying $conf..."
      if [ -f $CONFIG/$conf ]; then
         if [ -f ~/$conf ]; then
            if ! [ -h ~/$conf ]; then
               mv ~/$conf "$TMP/$conf.bup"
            fi
         fi
         ln -s $CONFIG/$conf ~/$conf
         echo "Linking configs/$conf ===> ~/$conf"
      else 
         echo Skipping! $conf not found!
      fi
   done
}

# run oh-my-zsh install script
install_ohmyzsh() {
   if [ -d "$ZSH" ]; then
      echo ".oh-my-zsh already exists, skipping installation"
   else
      echo "Installing oh-my-zsh"
      sh -c "$(curl -fsSL $OHMYZSH)"
   fi
}

install_zsh_addons() {
   git clone $ZSH_AUTO_COMPLETE $ZSH_AUTO_COMPLETE_LOC
   git clone $ZSH_SYNTAX_HIGHLIGHTING $ZSH_SYNTAX_HIGHLIGHTING_LOC
}

install_vundle() {
   git clone $VUNDLE $VUNDLE_LOC
}


install_pwndbg() {
   mkdir -p $PWNDBG_LOC
   git clone $PWNDBG $PWNDBG_LOC
   sh -c "$(cd $PWNDBG_LOC; ./setup.sh)"
}

main() {
   title_script
   while [ $# -gt 0 ]; do
      case $1 in
         --update) APT_UPDATE=yes;
      esac
      shift
   done
   if ! [ -z $APT_UPDATE ]; then
      echo "Updating pacakge definitions..."
      sudo apt update
   else
      echo "Running without updating apt, use --update to change this behaviour"
   fi

   # Install basic packages
   install_packages
   # Install oh-my-zsh
   install_ohmyzsh
   # Install oh-my-zsh addons
   install_zsh_addons
   # Install Vundle
   install_vundle
   # Install pwndbg
   install_pwndbg
   # Notify if any config files don't exist
   check_configs_exist
   # Link all config files that do exist
   link_configs

}

# Tooooo big
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
