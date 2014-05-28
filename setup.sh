#!/bin/bash
#set -x


# internal functions

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
	  if [ -z "$(head -n2 $2 | grep dotfiles)" ]; then
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

# source external functions
source bash/functions


#
# make should some directories exist/adjust PATH
#
[ ! -d ${HOME}/.config ] && mkdir ${HOME}/.config
[ ! -d ${HOME}/.local/bin ] && mkdir -p ${HOME}/.local/bin

alter_path remove ${HOME}/.local/bin
alter_path add ${HOME}/.local/bin


#
# Check needed executables and configuration
#

# config variables
if [ "${USER}" == "pas37" ]; then
    EMAIL="pas37@cornell.edu"
else
    EMAIL="phil.a.sorensen@gmail.com"
fi


#
# Install configuration files
#

# bash
source installer/keychain.sh
check_executable tmux

[ ! -d ${HOME}/.config/bash ] && mkdir ${HOME}/.config/bash

copy_if_update bash/bash_profile ${HOME}/.bash_profile
copy_if_update bash/bashrc ${HOME}/.bashrc
copy_if_update bash/i18n ${HOME}/.i18n

copy_if_update bash/functions ${HOME}/.config/bash/functions
copy_if_update bash/prompt ${HOME}/.config/bash/prompt


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

source installer/tmux-mem-cpu-load.sh
source installer/vcprompt.sh


#
# Install setups into Apps 
#

# clean all from apps-config after '# SETUP:'
#awk '{print} /# SETUP:/{exit}' ${HOME}/Apps/apps-config >> /tmp/apps-config

# install setups
#setups=$(grep "^# SETUP:" ${HOME}/Apps/apps-config | sed -e 's/^# SETUP://')
#for setup in $setups; do
#    ./apps-setups/${setup}.sh
#done

# copy on change
#copy_if_update /tmp/apps-config ${HOME}/Apps/apps-config
#rm /tmp/apps-config
