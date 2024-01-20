#!/bin/bash
set -Eeuo pipefail

sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager

curl -L https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/2.31.0/crc-linux-amd64.tar.xz | tar -C /usr/local/bin --strip-components=1 -xJvf -
crc config set consent-telemetry yes
crc config set preset okd
crc setup
crc start
eval "$(crc oc-env)"
oc config use-context crc-admin

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces
oc wait --for=condition=Ready pods --all --all-namespaces

echo "DONE"
