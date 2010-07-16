#!/bin/sh
# Title:    mpd-playlist.sh
# Author:   Tom Vincent
# Version:  0.1.0 (2009-03-01)
# Source:   http://mpd.wikia.com/wiki/Hack:Mpc-dmenu
#
# Search the current MPD playlist for a song and play it.
#
# Original version:
# urxvtc -T "MPD-playlist" -e 'mpc playlist; echo "$line"; mpc; sleep 3'

mpc play `mpc playlist | dmenu -i -b -nb "#000" -nf "#7af" -sb "#000" -sf "#bdf" -p "Song:" | cut -d')' -f1`
