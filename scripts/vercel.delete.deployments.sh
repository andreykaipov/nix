#!/bin/sh
#
# This script deletes all Vercel deployments apart from the current production
# deployment. There's no reason to delete old deployments since they don't cost
# anything, but I don't really like the clutter.
#
# TODO do the same when Cloudflare exposes the Pages API

set -eu

: "${VERCEL_TOKEN}"

curl() { command curl -sH "Authorization: Bearer $VERCEL_TOKEN" "$@"; }

api=https://api.vercel.com
prodid="$(curl "$api/now/deployments/get?url=kaipov.com" | jq -r .id)"
ids="$(curl "$api/now/deployments" | jq -r --arg prodid "$prodid" '
	.deployments[] | select(.uid != $prodid) | .uid
')"

for id in $ids; do
	curl "$api/now/deployments/$id" -XDELETE
	echo
done
