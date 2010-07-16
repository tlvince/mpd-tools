#!/bin/bash
# Title:    mpd-artist.sh
# Author:   Tom Vincent
# Version:  0.1.1 (2009-08-21)
# Created:  0.1.0 (2009-03-01)
#
# Original Author:  Windowlicker
# Source:           http://bbs.archlinux.org/viewtopic.php?id=61017
#
# Search for an artist name and begin playing all songs by that artist.

CMD=`mpc ls | dmenu -i -b -nb "#000" -nf "#7af" -sb "#000" -sf "#bdf" -p "Artist:" | cut -d')' -f1`

# TODO: do this better!
if [ -z "$CMD" ]; then
    exit
fi

if [ -d /media/akasa/music/"$CMD" ]; then
  mpc clear & mpc add "$CMD"
  mpc random on
  mpc play
fi
