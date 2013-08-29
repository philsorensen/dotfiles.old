#!/bin/bash
set -x

check_executable() {
    [[ $(command -v $1) ]] && return
    echo "command $1 needs to be in PATH"
    exit
}

copy_if_update() {
    if [ -f $2 ]; then
      if [ "$(sha1sum $1 | cut -d' ' -f1)" == "$(sha1sum $2 | cut -d' ' -f1)" ]
      then
	  return
      else
	  if [ -z "$(head -n1 $2 | grep dotfiles)" ]; then
	      echo "Backing up $2"
	      cp $2 $2.bak
	  fi
      fi
    fi
    echo "Updating $2"
    cp $1 $2
}

expand_file() {
    eval "echo \"$(cat $1)\""
}


#
# Check needed executables and configuration
#

# needed for scripts 
check_executable keychain
check_executable tmux

# source and check for config 
if [ ! -r config ]; then
    echo "Please copy config.in to config and edit settings"
    exit
fi
source config


#
# Install files
#

# create ~/Apps/
[ ! -d ${HOME}/Apps ] && mkdir ${HOME}/Apps
[ ! -d ${HOME}/Apps/bin ] && mkdir ${HOME}/Apps/bin
[ ! -f ${HOME}/Apps/apps-config ] && touch ${HOME}/Apps/apps-config

# bash
[ ! -d ${HOME}/.bash ] && mkdir ${HOME}/.bash

copy_if_update bash/bashrc ${HOME}/.bashrc
copy_if_update bash/bash_profile ${HOME}/.bash_profile
copy_if_update bash/i18n ${HOME}/.i18n
copy_if_update bash/prompt ${HOME}/.bash/prompt

# tmux
[ ! -d ${HOME}/.tmux ] &&  mkdir ${HOME}/.tmux

copy_if_update tmux/tmux.conf ${HOME}/.tmux.conf

# git
expand_file git/gitconfig >/tmp/gitconfig
copy_if_update /tmp/gitconfig ${HOME}/.gitconfig
rm /tmp/gitconfig

# SSH
[ ! -d ${HOME}/.ssh ] && (mkdir ${HOME}/.ssh; chmod 700)
copy_if_update ssh/config ${HOME}/.ssh/config
chmod 600 ${HOME}/.ssh/config


#
# Install some binaries
#

# download/install tmux-mem-cpu-load in ~/.tmux
if [ ! -x ${HOME}/.tmux/tmux-mem-cpu-load ]; then
    check_executable cmake
    check_executable g++
    check_executable git

    pushd /tmp
    git clone git://github.com/thewtex/tmux-mem-cpu-load
    if [ -d /tmp/tmux-mem-cpu-load ]; then
	cd tmux-mem-cpu-load
	cmake .
	make
	cp tmux-mem-cpu-load ${HOME}/.tmux/  
	cd ..
	rm -rf tmux-mem-cpu-load
    else
	echo "Failed to get tmux-mem-cpu-load"
	exit
    fi
    popd
fi

# download/install vcprompt in ~/.bash
if [ ! -x ${HOME}/.bash/vcprompt ]; then
    check_executable gcc

    pushd /tmp
    wget https://bitbucket.org/gward/vcprompt/downloads/vcprompt-1.1.tar.gz
    if [ -f /tmp/vcprompt-1.1.tar.gz ]; then
	tar -xzf vcprompt-1.1.tar.gz
	cd vcprompt-1.1
	make
	cp vcprompt ${HOME}/.bash/
	cd ..
	rm -rf vcprompt-1.1*
    else
	echo "Failed to get vcprompt"
	exit
    fi
    popd
fi
