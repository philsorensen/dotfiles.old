#!/bin/sh

check_executable() {
    [[ $(command -v $1) ]] && return
    echo "command $1 needs to in PATH"
    exit
}

copy_if_update() {
  if [ -f $2 ]; then
    if [ "$(sha1sum $1 | cut -d' ' -f1)" == "$(sha1sum $2 | cut -d' ' -f1)" ]
    then
      return
    fi
  fi
  cp $1 $2
}


# Install bash startup scripts and tmux.conf
check_executable keychain
check_executable tmux

copy_if_update bash/bashrc ${HOME}/.bashrc
copy_if_update bash/bash_profile ${HOME}/.bash_profile
copy_if_update bash/tmux.conf ${HOME}/.tmux.conf



