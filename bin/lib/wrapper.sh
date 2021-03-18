#!/bin/sh
#
# This script has two halves, and they're separated by a large turd.
#
# The first time this script is sourced, only the second half is relevant. It
# preprocesses the script that sourced this file, and then exec's it in a new
# shell, adding in the `__wrapper "$@"` invocation.
#
# The second time this script is sourced, the first half is relevant. It defines
# functions that could be used in our original script (e.g. argr and argo).
#
#     - Technically these functions are also available during the first source,
#       since well... it comes first, but they're not really relevant. Overhead
#       is minimal since it's mostly just function definitions, apart from the
#       conditional logic to stop the second source from bleeding into the
#       second half.

debug() {
        if [ -z "$DEBUG" ]; then return; fi
        if [ -n "$shitval" ]; then name="*$f*"; fi
        # current pid, parent pid
        >&2 echo "| ${name-$f} [$$,$PPID] | $*"
}

usage() {
        positionalargs="$(
                awk -vORS=' ' '
                        /^argr/ { print "<" $2 ">" }
                        /^argo/ { print "[" $2 "]" }
                ' "$0"
        )"

        cat <<EOF
Usage: $0 $positionalargs
EOF
}

argr() {
        name="$1"; shift
        if [ -z "$1" ]; then
                >&2 usage
                >&2 echo
                >&2 echo "Missing required positional argument: $name"
                exit 1
        fi
        eval "$name=\"\$1\""
}

# TODO combine argr and argo into arg -[ro]
argo() {
        name="$1"; shift
        eval "$name=\"\$1\""
}

fullpath() {
        echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
}

__wrapper() {
        #parseargs "$@"
        trap exit INT TERM
        trap __cleanup EXIT
        main "$@"
        wait
}

__cleanup() {
        echo
        debug "running provided cleanup, if any"
        cleanup 2>/dev/null

        pgid="$(ps -o pgid= $$ | tr -d ' ')"
        debug "killing pgid '$pgid'"
        kill -- -"$pgid"
}


# The variable we use to check if our script has been shittified depends on the
# script name, in case our shit script ever calls more shit scripts. We can't
# carelessly mix up our shit!

f="$0"
fname="$(basename "$f")"
fslug="$(printf "%s" "$fname" | tr -c -- 'a-zA-Z0-9_' _)"
shitvar="__shittified_$fslug"
shitval="$(eval "echo \"\$$shitvar\"")"

debug "sourced this lib"

if [ -n "$shitval" ]; then
        debug "but it was already shit"
        return
fi

################################################################################
######################################turd######################################
################################################################################

# fullf="$(fullpath "$f")"
# name="$(basename "$fullf")"
# this="$(dirname "$fullf")/lib/wrapper.sh"
# argscontent="$(awk '/^args\(\) {$/ {f=1; next} /^}$/ {f=0} f' "$sourcedby")"
# usage="$(awk '/^usage "$/ {f=1; next} /^"$/ {f=0} f' "$sourcedby")"
# '"$(awk '!/\/lib\/wrapper.sh/' "$sourcedby")"'
# '"$(awk '1; /^# shit$/ {exit}' "$this")"'

# modify original script contents
scriptmod="$(
        2>/dev/null awk '
                /^argr/ { $3="\"\$@\"; shift"; print; next }
                /^argo/ { $3="\"\$@\"; shift 2>/dev/null"; print; next }
                1
        ' "$f"
)"

fdir="$(dirname "$f")"

debug "modified contents of '$f'"
debug "changing into '$fdir' and exec'ing wrapper"

# so that our (modified) script can properly source this lib
cd "$fdir" || return

# shellcheck disable=SC2016
exec env "$shitvar=1" sh -c '
        if [ -n "$DEBUG" ]; then
                >&2 echo "| *$0* [$$,$PPID] | running modified script inside exec'\''ed shell"
        fi

        '"$scriptmod"'

        __wrapper "$@"
' "$fname" "$@"
