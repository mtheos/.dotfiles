#!/bin/bash

#set umask
umask 022

# Functions
command_exists() {
    command -v $@ >/dev/null 2>&1
}

do_backup() {
    echo "Backing up list of installed packages"
    apt-mark showmanual > ~/_pkgs.list
    echo "Backing up sources list"
    sudo cp -R /etc/apt/sources.list* ~/
    echo "Backing up repo keys"
    sudo apt-key exportall > ~/_repo.keys
    echo "Creating tarball"
    sudo tar -czvf "/$(whoami).home.tar.gz" ~
    echo -e "*****\nAll Done\n*****"
}

do_restore() {
    echo "unpacking tarball"
    tar -xzvf "/$(whoami).home.tar.gz"
    echo "Restoring repo keys"
    sudo apt-key add ~/_repo.keys
    echo "Restoring sources list"
    sudo cp -R ~/sources.list* /etc/apt/
    echo "Installing packages"
    sudo apt update
    xargs sudo apt install -y < ~/_pkgs.list
    echo "Don't forget to clean up\n$(ls -l ~/_repo.keys)\n$(ls -l ~/sources.list*)\n$(ls -l ~/_pkgs.list)"
}

main() {
    case "$@" in
       "backup") do_backup ;;
       "restore") do_restore ;;
    esac
}

main "$@"

