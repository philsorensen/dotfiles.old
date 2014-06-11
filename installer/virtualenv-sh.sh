#
# Install virtualenv-sh
#

VIRTSH=virtualenv-sh-0.2.2
VIRTSH_SRC=https://pypi.python.org/packages/source/v/virtualenv-sh/${VIRTSH}.tar.gz

if [ ! -f "${HOME}/.config/bash/virtualenv-sh.bash" ]; then
    check_executable wget

    pushd /tmp
    wget ${VIRTSH_SRC}
    tar -xf ${VIRTSH}.tar.gz

    cd ${VIRTSH}/scripts
    sed -e 's/virtualenv-sh-virtualenvs/virtualenv_sh_virtualenvs/' \
        virtualenv-sh.bash > ${HOME}/.config/bash/virtualenv-sh.bash
    cd ../..

    rm -rf ${VIRTSH}
    rm ${VIRTSH}.tar.gz
    popd
fi
