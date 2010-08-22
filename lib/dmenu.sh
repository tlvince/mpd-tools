##
# Override dmenu with some options to be used globally in mpd-tools.
#
dmenu()
{
    $(which dmenu) -b -nb "#000" -nf "#7af" -sb "#000" -sf "#bdf" "$@"
}
