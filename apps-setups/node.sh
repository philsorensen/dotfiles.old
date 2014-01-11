#/bin/bash
#
# Get/Upgrade node install
#

[ -f /etc/os-release ] && source /etc/os-release

if [ "${ID}" != "arch" ]; then
    ARCH="x86"
    [ "$(uname -m)" == "x86_64" ] && ARCH="x64"

    # current node.js
    current=$(ls ${HOME}/Apps | grep node-v)

    # current global modules
    if [ -d "${HOME}/Apps/node/lib/node_modules" ]; then
        npm_modules=$(ls "${HOME}/Apps/node/lib/node_modules")
	npm_modules=${npm_modules/npm/}
    fi

    # latest node.js
    pushd /tmp
    wget http://nodejs.org/dist/latest/SHASUMS.txt
    latest=$(grep "node-v.*-linux-${ARCH}.tar.gz" SHASUMS.txt |awk '{print $2}')
    rm SHASUMS.txt
    popd

    # check for update
    if [ "${current}.tar.gz" != "${latest}" ]; then
        pushd ${HOME}/Apps

	wget http://nodejs.org/dist/latest/${latest}
	tar -xaf ${latest}
	rm ${latest}

        rm -rf ${current}
        rm -f node
        ln -s ${latest%.tar.gz} node;

        PATH=${HOME}/Apps/node/bin:$PATH
	hash -r

	[ -n "${npm_modules}" ] && npm -g install ${npm_modules}
	popd
    else
        npm -g update
    fi
else
    if [ -z "$(command -v node)" ]; then
	echo "Please install node.js with pacman"
	exit
    fi
    echo "prefix = /home/phil/Apps/node" > ${HOME}/.npmrc
    npm -g update
fi

echo ""                                         >>/tmp/apps-config
echo "# add node/bin directory to PATH"         >>/tmp/apps-config
echo "export PATH=${HOME}/Apps/node/bin:\$PATH" >>/tmp/apps-config
