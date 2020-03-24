#!/bin/bash
#
# Install python packages and upgrade existing
#

needed_pkgs=""
install_pkgs=""

current_pkgs=$(pip3 list --user --format=legacy|awk '{print $1}'|tr '\n' ' ')

for pkg in $needed_pkgs; do
    if [[ "$current_pkgs" != *$pkg* ]]; then
        install_pkgs="$install_pkgs $pkg"
    fi
done

# update existing
pip3 install -U --user $current_pkgs

# install missing
if [ -n "$install_pkgs" ]; then
    pip3 install --user $install_pkgs
fi
