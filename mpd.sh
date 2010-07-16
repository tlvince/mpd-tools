#!/bin/sh
#
# A wrapper to /usr/bin/mpd to launch mpd (and some associated programs).
#
# Author:   Tom Vincent
# Created:  2009-06-16

# Imports:
. ~/src/bash/lib/libLoader.sh
LIBS=(logging killApp notifier)
libLoader ${LIBS[@]}

LIB_PATH="$HOME/src/bash/lib/mpd"
MPD_LIBS=(locateMPDConf mpdParam)
libLoader ${MPD_LIBS[@]}

# Program meta-data:
NAME="mpd-launch"
VERSION="0.3.3"

# Global variables:
CLIENT=ncmpcpp
PIDFILE="/tmp/$NAME.pid"
PID_FLAG=

##
# Usage
#
usage()
{
    cat << EOF
Usage:
    $NAME [OPTION...] [CLIENT...]
    $NAME             Implicitly (re)launch $NAME

Options:
    start                   Launch $NAME aswell as optional [CLIENT]
    stop                    Stop $NAME

    -h, --help              Show help options
    -v, --version           Output version information and exit
EOF
}

# Version
version()
{ echo $NAME v$VERSION; }

pidCheck()
{
    case $1 in
        start)
            if [[ -f $PIDFILE ]]; then
                PID_FLAG=true
            else
                touch $PIDFILE
            fi
        ;;
        stop)
            if [[ -f $PIDFILE ]]; then
                rm $PIDFILE
            else
                echo "ERROR: Is $NAME running? PID file not found."
                exit 1
            fi
        ;;
    esac
}

##
# Check the directory containing the music exists.
#
pathExists()
{
    local path="$(mpdParam '^music_directory')"
    local notifier="$(getNotifier)"

    # Special formatting if we're using `notify send`
    if [[ "$notifier" == "notify-send" ]]; then
        notifier="notify-send -i error"
    fi

    if [[ ! -d "$path" ]]; then
        if $(echo "$path" | grep -Eq "(^/media|^/mnt)"); then
            $notifier "Please power on and mount the external drive"
        else
            $notifier "Path to music directory does not exist"
        fi
        exit 1
    fi
}

start()
{
    pathExists
    pidCheck start

    if [[ -z $PID_FLAG ]]; then
        /usr/bin/mpd
        #mpdscribble
        mpd-sima start
    fi

    if [[ ! -z $1 ]]; then
        CLIENT=${1:-CLIENT}
    fi
    if [[ ! -z $CLIENT ]]; then
        exec $CLIENT
    fi
}

stop()
{
    pidCheck stop
    mpd-sima stop
    killApp mpdscribble
    /usr/bin/mpd --kill
}

#
# Main function
#
case $1 in
    start)
        shift
        start $1
    ;;
    stop)
        stop
    ;;
    -v|--version)
        version
    ;;
    -h|--help)
        usage
    ;;
    *)
        start
    ;;
esac
