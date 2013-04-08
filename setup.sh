#!/bin/bash

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

#
# Check needed executables 
#

# needed to install
check_executable curl
check_executable g++

# needed for scripts 
check_executable keychain
check_executable tmux


#
# Install files
#

# bash
copy_if_update bash/bashrc ${HOME}/.bashrc
copy_if_update bash/bash_profile ${HOME}/.bash_profile

# tmux
if [ ! -d ${HOME}/.tmux ]; then
    mkdir ${HOME}/.tmux
fi
copy_if_update tmux/tmux.conf ${HOME}/.tmux.conf


pushd /tmp
curl -O \
  https://raw.github.com/thewtex/tmux-mem-cpu-load/master/tmux-mem-cpu-load.cpp
popd
if [ -f /tmp/tmux-mem-cpu-load.cpp ]; then
    g++ -o ${HOME}/.tmux/tmux-mem-cpu-load /tmp/tmux-mem-cpu-load.cpp
else
    echo "Failed to get tmux-mem-cpu-load.cpp"
fi
