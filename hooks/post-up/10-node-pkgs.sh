#!/bin/bash
#
# Install python packages and upgrade existing
#

# needed:
#  emacs: tern
needed_pkgs="tern"

install_pkgs=""
current_pkgs=$(npm -g ls --depth=0 --parseable | awk -F/ 'NR>1 {print $NF}' \
	| tr '\n' ' ')

for pkg in $needed_pkgs; do
    if [[ "$current_pkgs" != *$pkg* ]]; then
        install_pkgs="$install_pkgs $pkg"
    fi
done

# update existing
npm -g update

# install missing
if [ -n "$install_pkgs" ]; then
    npm -g install $install_pkgs
fi
