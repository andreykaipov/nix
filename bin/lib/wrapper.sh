#!/bin/sh

wrapper() {
        #parseargs "$@"
        trap exit INT TERM
        trap __cleanup EXIT
        main "$@"
        wait
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

# shellcheck disable=SC2154
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

__cleanup() {
        cleanup 2>/dev/null
        echo
        kill -- -$$
}

fullpath() {
        echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
}

# sourced from the silly exec'd shell below
# shellcheck disable=SC2154
if [ -n "$__lmao" ]; then
        # echo 5: $$
        # echo 6: $PPID
        return
fi

# sourced from running our parent script
if (return 2>/dev/null); then
        # echo 1: $$
        # echo 2: $PPID

        f="$(ps -o cmd= "$$" | awk '{print $2}')" # or maybe just use $0?
        fdir="$(dirname "$f")"
        name="$(basename "$f")"

        # fullf="$(fullpath "$f")"
        # name="$(basename "$fullf")"
        # this="$(dirname "$fullf")/lib/wrapper.sh"
        # argscontent="$(awk '/^args\(\) {$/ {f=1; next} /^}$/ {f=0} f' "$sourcedby")"
        # usage="$(awk '/^usage "$/ {f=1; next} /^"$/ {f=0} f' "$sourcedby")"
        # '"$(awk '!/\/lib\/wrapper.sh/' "$sourcedby")"'
        # '"$(awk '1; /^# lmao$/ {exit}' "$this")"'

        # modify original script contents
        scriptmod="$(
                2>/dev/null awk '
                        /^argr/ { $3="\"\$@\"; shift"; print; next }
                        /^argo/ { $3="\"\$@\"; shift 2>/dev/null"; print; next }
                        1
                ' "$f"
        )"

        cd "$fdir" || return
        __lmao=1 exec sh -c '
                '"$scriptmod"'
                wrapper "$@"
        ' "$name" "$@"
else
        echo "This script isn't executable"
        exit 1
fi
