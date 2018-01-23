#!/usr/bin/env bash

set -euo pipefail

kubectl create secret generic dex-dev-github --from-literal=client-id="$1" --from-literal=client-secret="$2"
