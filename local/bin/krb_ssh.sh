#
# Create functions for dealing with Kerberos principales and wrapper for
# SSH to use them
#

# base username
KUSER=${1:-$USER}


# kerberos

set_upn() {
    user=${1:-$KUSER}
    upn=${user}@CLASSE.CORNELL.EDU

    kswitch -p ${upn} 2>/dev/null || kinit -f ${upn}
    ret=$?

    UPN=$(klist -l | awk 'NR==3 {print $1}')
    return ${ret}
}

ccache_cleanup() {
    for ccache in $(klist -A 2>&1 | grep "not found" | cut -d\' -f2); do
        kdestroy -c KEYRING:${ccache}
    done
}


# ssh

ksu_wrapper() {
    if [ $# -gt 0 ]; then ksu -q "$@"; else ksu -q -e /bin/su -; fi
}

ssh_wrapper() {
    host=${1} ; shift ; ssh ${host} "$@"
}

root_wrapper() {
    if [ $# -eq 0 -o "$1" == "-e" ]; then
        ksu_wrapper "$@"
    else
        host=${1} ; shift
        ssh_wrapper root@${host} "$@"
    fi
}

remote() {
    set_upn ${KUSER} && ssh_wrapper "$@"
}

root() {
    set_upn admin-${KUSER} && root_wrapper "$@"
}

rootdo() {
    set_upn admindo-${KUSER} && root_wrapper "$@"
}


export KUSER
export UPN
