#!/bin/sh

log() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }

get() {
        path=$1
        val=$(op read "op://$path")
        cached=~/.cache/op/$1
        mkdir -p "$(dirname "$cached")"
        if ! [ -r "$cached" ] || find "$cached" -mtime +1 2>/dev/null | grep .; then
                # if not readable or older than 1 day, refresh
                rm -rf "$cached"
                echo "$val" >"$cached"
        fi
        cat "$cached"
}

# cache secrets because i ran into rate limits using the op cli with a service
# account. might consider a 1password connect server but this works for now. :)
get_secret_json() {
        vault=$1
        entry=$2
        cached=~/.cache/op/$vault/$entry.json
        mkdir -p "$(dirname "$cached")"
        if [ -n "${NOCACHE-}" ] || ! [ -r "$cached" ] || find "$cached" -mtime +1 2>/dev/null | grep .; then
                log "Updating secret: $cached"
                rm -rf "$cached"
                op --vault "$vault" item get "$entry" --format json | jq '
                        [
                        .fields[]
                        | select(.section.label != null)
                        | {(.section.label): {(.label): (.value as $raw | try ($raw|fromjson) catch $raw)}}
                        ] | reduce .[] as $x ({}; .  * $x)
                ' >"$cached"
        fi
        cat "$cached"
}

main() {
        root=$(git rev-parse --show-toplevel)
        repo=$(basename "$root")
        log "Setting up $repo"

        : "${OP_SERVICE_ACCOUNT_TOKEN?needs to be set for op CLI}"

        cmd=$1
        case "$cmd" in
                infra/*) infra "$@" ;;
                *) log "Unknown command: $cmd" ;;
        esac
}

infra() {
        dir=$1
        shift
        export TERRAGRUNT_DEBUG=1
        export TERRAGRUNT_WORKING_DIR="$PWD/$dir"
        self_secrets="$(get_secret_json github self)" terragrunt "$@"
}

set -eu
main "$@"
