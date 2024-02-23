#!/bin/sh
#
# Pulls down all the Rancher clusters' kubeconfigs into a ~/.kube/rancher dir

set -eu

api="${1?}"
token="${2?}"

curl() {
        path="$1"
        command curl -Lsku "$token" "$api/$path" "$@"
}

main() {
        clusters="$(curl /clusters/ | jq -r '.data[] | "\(.id);\(.name)"')"
        kubedir="$HOME/.kube/rancher"
        mkdir -p "$kubedir"

        echo "$clusters" | while read -r cluster; do
                id="$(echo "$cluster" | cut -d\; -f1)"
                name="$(echo "$cluster" | cut -d\; -f2)"
                echo "Generating kubeconfig for $name"
                curl "/clusters/$id?action=generateKubeconfig" -XPOST | jq -r .config >"$kubedir/$name"
        done
}

main "$@"
