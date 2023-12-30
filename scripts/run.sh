#!/bin/sh
# shellcheck disable=SC2155

log() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }
get() { op read "op://github/$1"; }

main() {
        root=$(git rev-parse --show-toplevel)
        repo=$(basename "$root")
        log "Setting up $repo"

        : "${OP_SERVICE_ACCOUNT_TOKEN?needs to be set for op CLI}"
        op user get --me >&2

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
        export TERRAGRUNT_WORKING_DIR="$dir"
        export TF_BACKEND_USERNAME="$(get setup.self/tf_backend_username)"
        export TF_BACKEND_PASSWORD="$(get setup.self/tf_backend_password)"
        terragrunt "$@"
}

set -eu
main "$@"
