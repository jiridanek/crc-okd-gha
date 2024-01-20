#!/bin/bash
set -Eeuxo pipefail

curl -L https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/2.31.0/crc-linux-amd64.tar.xz | tar -C /usr/local/bin --strip-components=1 -xJvf -
crc config set consent-telemetry yes
crc config set preset okd
crc config set network-mode user
crc config set host-network-access true
crc setup
crc start --disable-update-check --pull-secret-file
eval "$(crc oc-env)"
oc config use-context crc-admin

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces

echo "DONE"
