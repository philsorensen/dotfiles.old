#
# Get/Upgrade node install
#


if [ "${DISTRO}" == "arch" ]; then
    if [ -z "$(command -v node)" ]; then
	echo "Please install node.js with pacman"
	exit
    fi
else
    # check 32 or 64 bit
    ARCH="x86"
    [ "$(uname -m)" == "x86_64" ] && ARCH="x64"

    # create ${HOME}/Programs
    [ ! -d "${HOME}/Programs" ] && mkdir ${HOME}/Programs

    # current node.js
    current=$(ls ${HOME}/Programs | grep node-v)

    # latest node.js
    pushd /tmp >/dev/null
    wget http://nodejs.org/dist/latest/SHASUMS.txt 2>/dev/null
    latest=$(grep "node-v.*-linux-${ARCH}.tar.gz" SHASUMS.txt |awk '{print $2}')
    rm SHASUMS.txt
    popd >/dev/null

    # update if needed
    if [ "${current}.tar.gz" != "${latest}" ]; then
        pushd ${HOME}/Programs

	wget http://nodejs.org/dist/latest/${latest}
	tar -xaf ${latest}
	rm ${latest}

        rm -rf ${current}
        rm -f node
        ln -s ${latest%.tar.gz} node;

        popd
    fi
fi
