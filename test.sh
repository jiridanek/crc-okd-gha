#!/bin/bash
set -Eeuxo pipefail

crc daemon || true
crc start --disable-update-check
eval "$(crc oc-env)"
oc config use-context crc-admin

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces

echo "DONE"
