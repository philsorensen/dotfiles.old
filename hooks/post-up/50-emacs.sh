#!/bin/bash


# install node packages used by emacs
NODE_PACKAGES="tern"

npm install -g ${NODE_PACKAGES}


# clone / update emacs config
if [ ! -d "${HOME}/.emacs.d/.git" ]; then
	cd ${HOME}
	if [ -d "${HOME}/.emacs.d" ]; then
		rm -rf ${HOME}/.emacs.d
	fi
	git clone https://github.com/philsorensen/emacsconfig.git
else
	cd ${HOME}/.emacs.d
	git pull
fi

