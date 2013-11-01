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


#
# Python setup
#

# check for virtual environment
if [ -n "${VIRTUAL_ENV}" ]; then
    echo "In virtual environment: Can't proceed"
    exit 1
fi

# check default python
check_executable python

default_python=$(basename $(realpath $(which python)) | sed -e 's/python//')
default_major=${default_python//.*/}

if [ -z "$(ls /usr/include/python${default_python}*/Python.h 2>/dev/null)" ]
then
    echo "Need Python.h: can't proceed"
    exit
fi

# check for the other python version
other="23"
other=${other//${default_major}/}

if [ -n "$(command -v python${other})" -a \
     -n "$(ls /usr/include/python${other}*/Python.h 2>/dev/null)" ]; then
    major="${other}"
    ver=$(basename $(realpath $(which python${other})) | sed -e 's/python//')

    versions="${major}:${ver}"
fi
versions="${versions} ${default_major}:${default_python}"


# install select python packages
export PATH=${HOME}/.python/bin:$PATH
export PYTHONUSERBASE=${HOME}/.python

[ ! -d ${HOME}/.python ] && mkdir ${HOME}/.python

for vers in ${versions}; do
    ver=( ${vers/:/ } )

    if [ ! -f "${PYTHONUSERBASE}/bin/easy_install-${ver[1]}" ]; then
	pushd /tmp
	wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py
	python${ver[0]} ez_setup.py --user
	rm ez_setup.py setuptools-*

	wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
	python${ver[0]} get-pip.py --user
	rm get-pip.py
	popd
	hash -r
    fi
    pip-${ver[1]} install -U --user setuptools
    pip-${ver[1]} install -U --user virtualenv
    pip-${ver[1]} install -U --user ipython[all]
done

if ! pip install -U --user virtualenv-sh; then
    check_executable make

    pip install --no-install virtualenv-sh

    pushd /tmp/pip_build_phil/virtualenv-sh

    cd functions/bash
    sed -ie 's/virtualenv-sh-virtualenvs/virtualenv_sh_virtualenvs/' \
	_virtualenv_sh_complete_virtualenvs
    cd ../..
    make

    pip install --user .
    popd
fi

# install iPython config
if command -v ipython >/dev/null; then
    IPYTHON=ipython
elif command -v >/dev/null; then
    IPYTHON=ipython3
else
    echo "Can't find ipython or ipython3"
    exit
fi

ipy_config_path=$(ipython locate)/profile_default/startup

[ ! -d ${ipy_config_path} ] && ${IPYTHON} profile create
copy_if_update ipy-config/00-virtualenv.py ${ipy_config_path}/00-virtualenv.py
