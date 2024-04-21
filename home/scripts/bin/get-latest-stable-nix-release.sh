#!/bin/sh
curl -s 'https://prometheus.nixos.org/api/v1/query?query=channel_revision' |
        jq -r '
                .data.result[].metric
                | select(.status == "stable" and .variant == "primary")
                | .channel
        '
