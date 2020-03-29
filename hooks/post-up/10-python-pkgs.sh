#!/bin/bash
#
# Install python packages and upgrade existing
#

# needed:
#  setup: pip setuptools wheel
PKGS="pip setuptools wheel"


# update existing

# currently there is a error if no out of date packages
#update_pkgs=$(pip3 list --user -o | awk 'NR>2 {print $1}' | tr '\n' ' ')

update_pkgs=$(pip3 list --user | awk 'NR>2 {print $1}'| tr '\n' ' ')

if [ -n "$update_pkgs" ]; then
    pip3 install -U --user $update_pkgs
fi


# install missing

install_pkgs=""
current_pkgs=$(pip3 list --user | awk 'NR>2 {print $1}'| tr '\n' ' ')

for pkg in $PKGS; do
    if [[ "$current_pkgs" != *$pkg* ]]; then
        install_pkgs="$install_pkgs $pkg"
    fi
done

if [ -n "$install_pkgs" ]; then
    pip3 install --user $install_pkgs
fi
