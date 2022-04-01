#!/bin/bash
#
# Use pipx to install global python packages.
#

# global packages 
PKGS="pipenv"


# install/update pipx
python3 -m pip install --upgrade --user pipx
hash -r

# install missing commands
for pkg in ${PKGS}; do
    if [ ! -d "${HOME}/.local/pipx/venvs/${pkg}" ]; then
        pipx install ${pkg}
    fi
done

# update existing
pipx upgrade-all
