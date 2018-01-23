#!/usr/bin/env bash

set -euo pipefail

kubectl create secret tls dex-dev-tls --cert=ssl/cert.pem --key=ssl/key.pem
