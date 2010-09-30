#!/bin/bash
#
# goodsong: maintain a list of good songs
#
# Copyright 2009, 2010 pbrisbin <http://pbrisbin.com/>
# Copyright 2010 Tom Vincent <http://www.tlvince.com/contact/>

message() {
  cat << EOF
usage: goodsong [option]

  options:

        -p, --play        play a random song from list, now

        -b, --build       build a playlist from your list, play it

        -s, --show        display a random song from list

        -f, --find regex  find a song in your list using grep 'regex'

        -S, --smart       select a song from your list; find it in
                          your current playlist or add it; when the
                          current song ends, play it

        -P, --print       print your list with music dir prepended

        -r, --report      find songs added to the list within a given
                          date range (yyyy-mm-dd). Can be partial, i.e.
                          yyyy-mm

        -h, --help        display this

        none              append playing song to list

EOF
}

# Return the mpd.conf passed as a parameter to mpd or an expected default
locateMPDConf() {
  # Don't use any command that overrides the "real" mpd binary
  local config="$(pgrep -fl $(which --skip-tilde mpd) | awk '{print $3}')"

  if [[ -z $config ]]; then
    if [[ -f "$HOME/.mpd/mpd.conf" ]]; then
      config="$HOME/.mpd/mpd.conf"
    elif [[ -f "/etc/mpd.conf" ]]; then
      config="/etc/mpd.conf"
    else
      echo 'unable to determine mpd.conf location' >&2
      exit 1
    fi
  fi

  echo $config
}

# From the given regex ($1), find the relevant mpd.conf parameter
mpdParam() {
  if [[ -z "$1" ]]; then
    echo 'mpdParam called without a parameter' >&2
    exit 1
  fi

  local paramDir="$(awk "/$1/ {print \$2}" $(locateMPDConf))"

  paramDir="${paramDir//\"/}"       # Strip quotes
  paramDir="${paramDir/\~/$HOME}"   # Fix ~

  echo $paramDir
}

# just prints your list with the music dir prepended (for easy piping, etc)
printlist() {
  local mdir="$(mpdParam '^music_directory')"
  grep -v "^#" "$list" | sed "s|^|$mdir/|g"
}

# return playlist position of a random good song
get_pos() {
  local track="$(grep -v "^#" "$list" | sort -R | head -n 1)" pos

  pos=$(mpc --format '%position% %file%' playlist | grep "[0-9]*\ $track$" | awk '{print $1}' | head -n 1)

  if [[ -z "$pos" ]]; then
    mpc add "$track"
    pos=$(mpc playlist | wc -l)
  fi

  echo $pos
}

# returns current seconds remaining
get_lag() {
  local time curm curs totm tots lag N

  time="$(mpc | awk '/playing/ {print $3}')"

  if [[ -n "$time" ]]; then
    while IFS=':' read -r curm curs totm tots; do
      cur=$((curm*60+curs))
      tot=$((totm*60+tots))

      lag=$((tot-cur))
    done <<< "${time////:}"

    # adjust lag based on crossfade
    N=$(mpc crossfade | awk '{print $2}')
    [[ -n "$N" ]] && lag=$((lag-N))

    echo $lag
  else
    echo 0
  fi
}

# build a playlist and play it
build_playlist() {
  mpc clear >/dev/null
  mpc load $(basename "$list" .m3u)     # Remove file extension
  mpc random on
  mpc play
}

# add current song to the list
add_to_list() {
  # is mpd playing?
  mpc | grep -Fq playing || exit 1

  # get song filename
  song="$(mpc --format %file% | head -n 1)"

  # add it
  grep -Fqx "$song" "$list" || {
    echo "# $(date +%F)" >> "$list"   # Timestamp for reports
    echo "$song" >> "$list"
  }
}

# queue up a good song for when the current song ends
smart_play() { (sleep $(get_lag) && mpc play $(get_pos) &>/dev/null) & }

# show one random good song
show_one() { grep -v "^#" "$list" | sort -R | head -n 1; }

# play a random good song
play_one() { mpc play $(get_pos); }

# search the list
search_list() { grep -i "$*" "$list"; }

# print songs added after given timestamp ($1 - in yyyy-mm-dd format)
report() {
  if [[ -z $1 ]]; then
    echo 'report expects a partial date parameter in the format: yyyy-mm-dd' >&2
    exit 1
  fi
  sed -n "/^#\ $1/{n;p;}" "$list"   # Print song excluding timestamp
}

list="$(mpdParam '^playlist_directory')/goodsongs.m3u"
touch "$list"

case "$1" in
  -h|--help)   message && exit 1       ;;
  -s|--show)   show_one                ;;
  -f|--find)   shift; search_list "$*" ;;
  -p|--play)   play_one                ;;
  -b|--build)  build_playlist          ;;
  -S|--smart)  smart_play              ;;
  -P|--print)  printlist               ;;
  -r|--report) shift; report "$*"      ;;
  *)           add_to_list             ;;
esac
