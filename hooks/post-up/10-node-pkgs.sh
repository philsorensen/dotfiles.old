#!/bin/bash
#
# Install python packages and upgrade existing
#

# desired packages
PKGS="pyright typescript typescript-language-server"

# update existing
npm -g update

# install missing
for pkg in ${PKGS}; do
    if ! npm -g ls --depth=0 --parseable | grep -q "/${pkg}$"; then
        npm -g install ${pkg}
    fi
done
