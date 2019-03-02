#!/bin/sh
#
# Install script to create rcrc file and run initial rcup.  The args are
# set as tags
#

# copy rcrc.in to rcrc and add TAGS line to end
cp rcrc.in rcrc
if [ $# -gt 0 ]; then
	echo "TAGS=\"$*\"" >> rcrc.in
fi

# run rcup -v
RCRC=./rcrc rcup -v
