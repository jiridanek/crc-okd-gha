#!/bin/bash
set -Eeuxo pipefail

crc config set consent-telemetry yes
crc config set preset openshift
crc config set network-mode user
crc config set host-network-access true
crc delete
crc setup
crc start --disable-update-check --pull-secret-file pull-secret.txt
eval "$(crc oc-env)"
oc config use-context crc-admin

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces

crc stop

echo "DONE"
