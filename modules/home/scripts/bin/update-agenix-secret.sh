#!/bin/sh
#
# TODO: flesh this out
#
# usage:
# ❯ ./scripts/update-secret.sh smart-toaster.pem /tmp/ops.pem

set -eu

secret_name=$1
private_key=$2 # get this from 1password

export RULES=secrets/secrets.nix
agenix -e "secrets/${secret_name}.age" -i "$private_key"
