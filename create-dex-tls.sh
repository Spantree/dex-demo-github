#!/usr/bin/env bash

set -euo pipefail

kubectl create secret tls dex.example.com.tls --cert=ssl/cert.pem --key=ssl/key.pem
