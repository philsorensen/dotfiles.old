#
# Install vcprompt
#

VCPROMPT=vcprompt-1.2.1
VCPROMPT_SRC=https://bitbucket.org/gward/vcprompt/downloads/${VCPROMPT}.tar.gz

# download/install vcprompt in ~/.local/bin
if [ ! -x ${HOME}/.local/bin/vcprompt ]; then
    check_executable wget
    check_executable gcc
    check_executable make

    pushd /tmp
    wget ${VCPROMPT_SRC}
    tar -xzf ${VCPROMPT}.tar.gz
    cd ${VCPROMPT}

    ./configure
    make
    cp vcprompt ${HOME}/.local/bin/

    cd ..
    rm -rf ${VCPROMPT}*
    popd
fi
