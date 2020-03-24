#!/bin/bash

# clone / update emacs config
if [ ! -d "${HOME}/.emacs.d/.git" ]; then
	cd ${HOME}
	if [ -d "${HOME}/.emacs.d" ]; then
		rm -rf ${HOME}/.emacs.d
	fi
	git clone https://github.com/philsorensen/emacsconfig.git .emacs.d
else
	cd ${HOME}/.emacs.d
	git pull
fi
