#!/bin/bash
#
# Update the MPD database, add all songs and play one at random.
#
# Author:   Tom Vincent
# Created:  2008-01-17

mpc -q crop 2>/dev/null     # Don't care if mpd is stopped
mpc -q update / --wait      # XXX: check it is actually updating
mpc -q clear
mpc ls | mpc -q add
mpc -q random on
mpc -q play
