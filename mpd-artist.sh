#!/bin/bash
#
# Search for an artist name and begin playing all songs by that artist.
#
# Author:   Tom Vincent
# Created:  0.1.0 (2009-03-01)

# Global variables:
BASE="$(dirname "$(readlink -f "$0")")"     # Handle symlinks
vertical="false"

# Imports:
. "$BASE/lib/dmenu.sh"
. "$BASE/lib/isRunning.sh"
. "$BASE/lib/logging.sh"

##
# Create a menu of all the artists in music directory.
#
getChoice()
{
    dmenu="dmenu -p Artist:"
    $vertical && dmenu+=" -l 10"

    mpc ls | $dmenu
}

isRunning mpd || die "Please launch mpd"

CHOICE=$(getChoice) || exit 2
mpc -q clear && mpc -q add "$CHOICE"
mpc -q play
