#!/bin/sh
# Search the current MPD playlist for a song and play it.
#
# Author:   Tom Vincent
# Created:  2009-03-01

##
# Create a menu of songs in the current mpd playlist. 
#
getChoice()
{
    BASE="$(dirname "$(readlink -f "$0")")"     # Handle symlinks
    . "$BASE/lib/dmenu.sh" 

    mpc playlist | dmenu -p "Song:"
}


# Use sed to find the playlist number
mpc play $(mpc playlist | sed -ne "/^$(getChoice)$/=")
