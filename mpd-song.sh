#!/bin/sh
# Search the current MPD playlist for a song and play it.
#
# Author:   Tom Vincent
# Created:  2009-03-01

# Global variables:
BASE="$(dirname "$(readlink -f "$0")")"     # Handle symlinks
vertical="true"

# Imports:
. "$BASE/lib/dmenu.sh"
. "$BASE/lib/isRunning.sh"
. "$BASE/lib/logging.sh"

##
# Create a menu of all the artists in music directory.
#
getChoice()
{   
    dmenu="dmenu -p Song:"
    $vertical && dmenu+=" -l 10"

    mpc playlist | $dmenu
}


isRunning mpd || die "Please launch mpd"

CHOICE=$(getChoice)
if [[ $CHOICE ]]; then
    # Use sed to find the playlist number
    mpc -q play $(mpc playlist | sed -ne "/^$CHOICE$/=")
fi
