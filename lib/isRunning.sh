##
# @return 0 if $1 is running, otherwise 1.
#
isRunning()
{
    pgrep ^$1$ > /dev/null
}
