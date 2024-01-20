#!/bin/bash
set -Eeuxo pipefail

sudo apt-get update
sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager
sudo usermod -a -G libvirt $USER
newgrp libvirt
newgrp -

curl -L https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/2.31.0/crc-linux-amd64.tar.xz | tar -C /usr/local/bin --strip-components=1 -xJvf -
crc config set consent-telemetry yes
crc config set preset okd
crc config set skip-check-user-in-libvirt-group true
crc setup
crc start
eval "$(crc oc-env)"
oc config use-context crc-admin

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces
oc wait --for=condition=Ready pods --all --all-namespaces

echo "DONE"
