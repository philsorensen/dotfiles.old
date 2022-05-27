#!/bin/bash
#
# 1. Add pip-{version} links to ~/.local/bin/pip
# 2. Install required packages and update installed packages with pipx.
#

# create pip links
major=$(python3 -c 'import sys; print(sys.version_info[0])')
minor=$(python3 -c 'import sys; print(sys.version_info[1])')

(cd ~/.local/bin; ln -s pip "pip${major}"; ln -s pip "pip${major}.${minor}")


# required packages
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
