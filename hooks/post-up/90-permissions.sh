#!/bin/sh

# ssh directory and files
chmod 0700 ${HOME}/.ssh
chmod 0600 ${HOME}/.ssh/config
chmod 0644 ${HOME}/.ssh/id_*.pub
ls ${HOME}/.ssh/id_* | grep -v pub | xargs chmod 0600

