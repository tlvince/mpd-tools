#!/bin/bash
# Title:    mpd-update.sh
# Author:   Tom Vincent
# Version:  major.minor.revision (YYYY-MM-DD)
#
# Source: http://bbs.archlinux.org/viewtopic.php?pid=341957
#
# Update the MPD database, add all songs and play one at random.
mpc crop
mpc update > /dev/null
while [ $(mpc | grep Updating | wc -l) == 1 ]; do
        sleep 1
done
mpc clear
mpc ls | mpc add > /dev/null
mpc random on
mpc play
