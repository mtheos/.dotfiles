#!/bin/bash

# Variables
declare -a packages=(git npm vim zsh)
declare -a configs=( .bash_prompt .bashrc .gdbinit .gitconfig .npmrc .profile .term_aliases .term_bootscripts .term_manualscripts .vimrc .zshrc )
CONFIG=~/.homedir_conf/configs
TMP=~/.homedir_conf/tmp
ZSH_CUSTOM=~/.oh-my-zsh/custom
BIN_DIR=~/homedir_conf/desktop_entries/bin
DESKTOP_DIR=~/homedir_conf/desktop_entries/desktop

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
   for pkg in ${packages[@]} ; do
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
   for conf in ${configs[@]} ; do
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
   for conf in ${configs[@]} ; do
      echo -n "  * Trying $conf..."
      if [ -f $CONFIG/$conf ]; then
         if [ -f ~/$conf ]; then
            if ! [ -h ~/$conf ]; then
               mv ~/$conf $TMP/$conf.bup
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
   if ! [ -d $ZSH ]; then
      echo Installing oh-my-zsh
      sh -c $(curl -fsSL $OHMYZSH)
   else
      echo .oh-my-zsh exists, skipping installation
   fi
}

install_zsh_addons() {
   install_zsh_auto_complete
   install_zsh_syntax_highlighting
}

install_zsh_auto_complete() {
   if ! [ -d $ZSH_AUTO_COMPLETE_LOC ]; then
      echo Installing ZSH Auto Complete
      mkdir -p $ZSH_AUTO_COMPLETE_LOC
      git clone $ZSH_AUTO_COMPLETE $ZSH_AUTO_COMPLETE_LOC
   else
      echo ZSH Auto Complete exists, skipping installation
   fi
}

install_zsh_syntax_highlighting() {
   if ! [ -d $ZSH_SYNTAX_HIGHLIGHTING_LOC ]; then
      echo Installing ZSH Syntax Highlighting
      mkdir -p $ZSH_SYNTAX_HIGHLIGHTING_LOC
      git clone $ZSH_SYNTAX_HIGHLIGHTING $ZSH_SYNTAX_HIGHLIGHTING_LOC
   else
      echo ZSH Syntax Highlighting exists, skipping installation
   fi
}

install_vundle() {
   if ! [ -d $VUNDLE_LOC ]; then
      echo Installing Vundle
      mkdir -p $VUNDLE_LOC
      git clone $VUNDLE $VUNDLE_LOC
   else
      echo Vundle exists, skipping installation
   fi
}


install_pwndbg() {
   if ! [ -d $ZSH ]; then
      echo Installing pwndbg
      mkdir -p $PWNDBG_LOC
      git clone $PWNDBG $PWNDBG_LOC
      sh -c $(cd $PWNDBG_LOC; ./setup.sh)
   else
      echo Pwndbg exists, skipping installation
   fi
}

create_desktop_links() {
   for file in $BIN_DIR ; do
      if ! [ -f /usr/bin/$file ] ; then
         echo Creating /usr/bin/$file
         cp $BIN_DIR/$file /usr/bin/$file
      else
         echo File /usr/bin/$file exists
      fi
   done

   for file in $DESKTOP_DIR ; do
      if ! [ -f /usr/bin/$file ] ; then
         echo Creating /usr/bin/$file
         cp $DESKTOP_DIR/$file /usr/share/applications/$file
      else
         echo File /usr/share/applications/$file exists
      fi
   done
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
      echo Updating pacakge definitions...
      sudo apt update
   else
      echo Running without updating apt, use --update to change this behaviour
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
   create_desktop_links
   # Notify if any config files don't exist
   check_configs_exist
   # Link all config files that do exist
   link_configs

}

# Too big
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
