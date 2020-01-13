#!/bin/bash

# Variables
declare -a packages=(git vim zsh)
declare -a configs=( .bash_prompt .bashrc .gdbinit .gitconfig .npmrc .profile .term_aliases .term_bootscripts .term_manualscripts .vimrc .zshrc )
ROOT=~/.homedir_conf
CONFIG=$ROOT/configs
TMP=$ROOT/tmp
ZSH_DIR=~/.oh-my-zsh
ZSH_CUSTOM=$ZSH_DIR/custom
BIN_DIR=$ROOT/desktop_entries/bin
DESKTOP_DIR=$ROOT/desktop_entries/desktop

ZSH_THEME_FROM=$ROOT/zsh_themes/muse_mod.zsh-theme
ZSH_THEME_TO=$ZSH_CUSTOM/themes/muse_mod.zsh-theme


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

pause() {
   read -p Pausing...
}

command_exists() {
   command -v $@ >/dev/null 2>&1
}

identify_package_manager() {
   declare -A osInfo;
   osInfo[/etc/redhat-release]="yum install -y"
   osInfo[/etc/arch-release]="pacman -S --noconfirm"
   osInfo[/etc/gentoo-release]="emerge -a"
   osInfo[/etc/SuSE-release]="zypp install -y"
   osInfo[/etc/debian_version]="apt install -y"

   if ! [ -z $PACMAN ] ; then
      echo "PACMAN set in shell. Using => $PACMAN"
      return
   else
      echo Package manager not set... Trying to identify
   fi
   for f in ${!osInfo[@]} ; do
      if [[ -f $f ]];then
         echo Setting PACMAN to ${osInfo[$f]}
         PACMAN=${osInfo[$f]}
	 echo Set manually if not correct
	 return
      fi
   done
   echo Package manager not identified. Set PACMAN with package manager
   exit 1
}

install_package() {
   sudo $PACMAN $@
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
   if ! [ -d $ZSH_DIR ]; then
      echo Installing oh-my-zsh
      sh -c "$(curl -fsSL $OHMYZSH)"
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

install_zsh_themes() {
	cp $ZSH_THEME_FROM $ZSH_THEME_TO
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
   if ! [ -d $PWNDBG_LOC ]; then
      echo Installing pwndbg
      mkdir -p $PWNDBG_LOC
      git clone $PWNDBG $PWNDBG_LOC
      sh -c $(cd $PWNDBG_LOC; ./setup.sh)
   else
      echo Pwndbg exists, skipping installation
   fi
}

create_desktop_links() {
      for file in $(ls $BIN_DIR) ; do
      if ! [ -f /usr/bin/$file ] ; then
         sudo cp $BIN_DIR/$file /usr/bin/$file && echo Creating /usr/bin/$file
      else
         echo File /usr/bin/$file exists
      fi
   done

   for file in $(ls $DESKTOP_DIR) ; do
      if ! [ -f /usr/share/applications/$file ] ; then
         sudo cp $DESKTOP_DIR/$file /usr/share/applications/$file && echo Creating /usr/share/applications/$file
      else
         echo File /usr/share/applications/$file exists
      fi
   done
}

main() {
   title_script
   identify_package_manager
   while [ $# -gt 0 ]; do
      case $1 in
         --update) UPDATE=yes;
      esac
      shift
   done
   if ! [ -z $UPDATE ]; then
      echo Updating pacakge definitions...
      sudo apt update
   else
      echo Running without updating, use --update to change this behaviour
   fi

   # Install basic packages
   install_packages
   # Install oh-my-zsh
   install_ohmyzsh
   # Install oh-my-zsh addons
   install_zsh_addons
pause
   install_zsh_themes
pause
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
