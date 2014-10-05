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
# Bash setup
#

# keychain
source installer/keychain.sh

# tmux
check_executable tmux
copy_if_update tmux/tmux.conf ${HOME}/.tmux.conf
source installer/tmux-mem-cpu-load.sh

# vcprompt
source installer/vcprompt.sh

# bash configs
[ ! -d ${HOME}/.config/bash ] && mkdir ${HOME}/.config/bash

copy_if_update bash/bash_profile ${HOME}/.bash_profile
copy_if_update bash/bashrc ${HOME}/.bashrc
copy_if_update bash/i18n ${HOME}/.i18n

copy_if_update bash/functions ${HOME}/.config/bash/functions
copy_if_update bash/prompt ${HOME}/.config/bash/prompt


#
# GIT
#

# set email
if [ "${USER}" == "pas37" ]; then
    EMAIL="pas37@cornell.edu"
else
    EMAIL="phil.a.sorensen@gmail.com"
fi

# build config file
expand_file git/gitconfig >/tmp/gitconfig
copy_if_update /tmp/gitconfig ${HOME}/.gitconfig
rm /tmp/gitconfig
copy_if_update git/gitconfig ${HOME}/.gitignore

#
# SSH
#

# set ControlPersist if availible
PERSIST="    ControlPersist 300
"
[ "${DISTRO}" == "sl6" ] && PERSIST=""

# install config
[ ! -d ${HOME}/.ssh ] && mkdir ${HOME}/.ssh
chmod 700 ${HOME}/.ssh

expand_file ssh/config >/tmp/config
copy_if_update /tmp/config ${HOME}/.ssh/config
rm /tmp/config

chmod 600 ${HOME}/.ssh/config


#
# node.js
#

source installer/node.sh

if [ "${DISTRO}" != "arch" ]; then
    [ ! -L "${HOME}/.local/bin/node" ] && \
        ln -s ${HOME}/Programs/node/bin/node ${HOME}/.local/bin/node
    [ ! -L "${HOME}/.local/bin/npm" ] && \
        ln -s ${HOME}/Programs/node/lib/node_modules/npm/bin/npm-cli.js \
        ${HOME}/.local/bin/npm
    hash -r
fi

echo "# maintained by dotfiles - changes will be overwritten"  > /tmp/npmrc
echo "prefix=\${HOME}/.local/"                                >> /tmp/npmrc
if [ -n "${HAS_QUOTA}" ]; then
    echo "cache=/dev/shm/npm-cache"                           >> /tmp/npmrc
fi
copy_if_update /tmp/npmrc ${HOME}/.npmrc
rm /tmp/npmrc


#
# python setup
#

# install pip and virtualenv
if [ -z "$(command -v pip)" ]; then
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py --user
    rm get-pip.py
    hash -r
fi
if [ -z "$(command -v virtualenv)" ]; then
    pip install --user virtualenv
    hash -r
fi

# virtualenv-sh
source installer/virtualenv-sh.sh
