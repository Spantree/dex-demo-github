#!/usr/bin/env bash

set -euo pipefail

CLIENT_ID=$1
CLIENT_SECRET=$2

kubectl create secret generic github-client --from-literal=client-id="$CLIENT_ID" --from-literal=client-secret="$CLIENT_SECRET"
