#!/bin/bash
set -Eeuxo pipefail

CRC_PRESET=okd

crc config set consent-telemetry yes
crc config set preset $CRC_PRESET
crc config set skip-check-systemd-networkd-running true
crc config set pull-secret-file pull-secret.txt
crc setup
crc start --disable-update-check
eval "$(crc oc-env)"

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces --timeout=120s

sudo virsh list

sudo virsh shutdown crc
until sudo virsh domstate crc | grep shut; do
    echo "crc vm is still alive"
    sleep 11
    set +x
done
set -x

sudo virsh dumpxml crc > ~/crc.xml
sudo virsh net-dumpxml crc > ~/crc_net.xml

# clean what we don't need
rm -rf ~/.crc/cache/*.crcbundle

echo "DONE"
