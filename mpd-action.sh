#!/bin/bash
#
# Perform an action on `mpd` after the currently playing song is finshed.
#
# Author:  Tom Vincent
# Created: 2010-05-28

# get those fun BUSY/DONE messages
USECOLOR="YES"
. /etc/rc.d/functions

usage()
{
    echo "Usage: $0 [-s|-k]"
    exit 1
}

wait()
{
    SEC=$(mpc | awk -F"[ /:]" '/playing/ {print 60*($8-$6)+$9-$7}')
    stat_busy "Sleeping $SEC seconds until playing song is finshed..."
    sleep $SEC
}

[[ $# == 0 ]] && usage
[[ -z $(mpc | grep playing) ]] && echo "mpd probably isn't playing" && exit 1

case $1 in
    -s)
        wait
        /usr/bin/mpc -q stop
    ;;
    -k)
        wait
        kill $(pidof /usr/bin/mpd)
    ;;
    *)
        usage
    ;;
esac
stat_done
