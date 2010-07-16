#!/bin/sh
#
# Load the recently added songs as an mpd playlist.
#
# Author:   Tom Vincent
# Created:  2010-05-22 13:08
#
# TODO:
# * Alternative methods:
#     * `grep "May 22\ .*added" var/log/mpd/mpd.log | sed s/.*added\ //g`
#     * Check in the db directly
#
# Exit codes:
#   1   - bad argument
#   2   - file not found

# Imports:
source ~/src/bash/lib/libLoader.sh
STD_LIBS=(logging)
libLoader ${STD_LIBS[@]}

LIB_PATH="$HOME/src/bash/lib/mpd"
MPD_LIBS=(locateMPDConf mpdParam)
libLoader ${MPD_LIBS[@]}

# Program meta-data:
NAME="mpd-recent"
VERSION="0.1.0"

# Global variables:
LOG="$HOME/var/log/mpd-recent.log"
quiet=false
verbose=false

##
# Print the recently added songs.
#
# param $1 int      Search for files added from today and $1 days (defaults 7).
#
printRecent()
{
    [[ -z $1 ]] && set 7
    local mdir="$(mpdParam '^music_directory')"
    find "$mdir" -type f -ctime +0 -a -ctime -$1 | sed "s|$mdir/||g"
}

##
# Create a playlist of recently added songs.
#
# param $1 int      Play files added from today and $1 days.
playRecent()
{
    local list="$(printRecent $1 | sort)"
    if [[ -z $list ]]; then
        info "no songs added within that timeframe"
    else
        mpc -q clear
        mpc add $list
        mpc -q play
    fi
}

##
# Show help options.
#
usage()
{
    cat << END_USAGE
Usage:
  $NAME             Play files added from today and $1 days (defaults 7)
  $NAME [OPTION...] [ARGUMENTS...]

Options:
  -h, --help              Show help options
  -q, --quiet             Suppress all normal output
  -v, --version           Output version information and exit
  -V, --verbose           Output processing information
END_USAGE
}

##
# Output program version information.
#
version()
{
    cat << END_VERSION
$NAME v$VERSION
Copyright 2010 Tom Vincent <tlvince@gmail.com>
END_VERSION
}

##
# Parse the runtime options and arguments.
#
parseOpts()
{
    case "$1" in
        -h|--help)
            usage
        ;;
        -q|--quiet)
            quiet=true
            shift
            parseOpts "$@"
        ;;
        -v|--version)
            version
        ;;
        -V|--verbose)
            verbose=true
            shift
            parseOpts "$@"
        ;;
        *)
            playRecent $1
        ;;
    esac
}

# Main
parseOpts "$@"
