#!/bin/bash
#set -x

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
# Install files
#

# create ~/Apps/
[ ! -d ${HOME}/Apps ] && mkdir ${HOME}/Apps
[ ! -d ${HOME}/Apps/bin ] && mkdir ${HOME}/Apps/bin
[ ! -f ${HOME}/Apps/apps-config ] && touch ${HOME}/Apps/apps-config

# bash
check_executable keychain
check_executable tmux

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
    check_executable make

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
    check_executable wget
    check_executable gcc
    check_executable make

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

# python virtualenv and virtualenv-sh
if [ -n "${VIRTUAL_ENV}" ]; then
    echo "In virtual environment: Can't proceed"
    exit 1
fi
py_ver=$(basename $(realpath $(which python)))

check_executable python
if [ -z "$(find /usr/include -name Python.h)" ]; then
    echo "Need python-devel: Can't proceed"
    exit
fi

export PATH=${HOME}/.python/bin:$PATH
export PYTHONUSERBASE=${HOME}/.python

[ ! -d ${HOME}/.python ] && mkdir ${HOME}/.python

if [ ! -f "${HOME}/.python/bin/easy_install" ]; then 
    pushd /tmp
    wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
    python ez_setup.py --user
    rm ez_setup.py
    popd
    hash -r
fi
easy_install -U --user setuptools

easy_install -U --user virtualenv

if ! easy_install -U --user virtualenv-sh; then
    check_executable make

    easy_install -U -eb /tmp virtualenv-sh
    pushd /tmp/virtualenv-sh

    cd functions/bash
    sed -ie 's/virtualenv-sh-virtualenvs/virtualenv_sh_virtualenvs/' \
	_virtualenv_sh_complete_virtualenvs
    cd ../..

    make
    popd
    easy_install --user /tmp/virtualenv-sh
    rm -rf /tmp/virtualenv-sh
fi

# install iPython 
easy_install -U --user ipython[all]

if ! command -v ipython >/dev/null; then
    [ -f ${HOME}/.python/bin/ipython3 ] && \
	(cd ${HOME}/.python/bin/; ln -s ipython3 ipython)
fi

ipython profile create
ipy_config_path=$(ipython locate)/profile_default/startup

copy_if_update ipy-config/00-virtualenv.py ${ipy_config_path}/00-virtualenv.py
