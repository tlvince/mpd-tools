#!/bin/sh
# Search the current MPD playlist for a song and play it.
#
# Author:   Tom Vincent
# Created:  2009-03-01

# Global variables:
BASE="$(dirname "$(readlink -f "$0")")"     # Handle symlinks

# Imports:
. "$BASE/lib/dmenu.sh"
. "$BASE/lib/isRunning.sh"
. "$BASE/lib/logging.sh"

##
# Create a menu of songs in the current mpd playlist. 
#
getChoice()
{
    mpc playlist | dmenu -p "Song:"
}

isRunning mpd || die "Please launch mpd"

CHOICE=$(getChoice)
if [[ $CHOICE ]]; then
    # Use sed to find the playlist number
    mpc play $(mpc playlist | sed -ne "/^$CHOICE$/=")
fi
