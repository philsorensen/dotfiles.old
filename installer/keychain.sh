#
# Install keychain
#

KEYCHAIN=keychain-2.7.1
KEYCHAIN_SRC=http://www.funtoo.org/archive/keychain/${KEYCHAIN}.tar.bz2

if [ ! -x ${HOME}/.local/bin/keychain ]; then
    check_executable wget

    pushd /tmp
    wget ${KEYCHAIN_SRC}
    tar -xf ${KEYCHAIN}.tar.bz2

    cd ${KEYCHAIN}
    cp keychain ${HOME}/.local/bin/
    cd ..

    rm -rf ${KEYCHAIN}
    rm ${KEYCHAIN}.tar.bz2
    popd
    hash -r
fi
