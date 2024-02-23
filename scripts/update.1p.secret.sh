#!/bin/sh
#
# Updates the 1Password secret for Action workflows

: "${OP_SERVICE_ACCOUNT_TOKEN?needs to be set}"
repo=andreykaipov/self
gh secret set OP_SERVICE_ACCOUNT_TOKEN --body "$OP_SERVICE_ACCOUNT_TOKEN" -R $repo -a actions
