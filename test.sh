#!/bin/bash
set -Eeuxo pipefail

crc setup

#sudo virsh net-define ~/crc_net.xml
sudo virsh define ~/crc.xml
sudo chown libvirt-qemu:libvirt ~/.crc/machines/crc/crc.qcow2
sudo virsh start crc

eval "$(crc oc-env)"
export KUBECONFIG=~/.crc/machines/crc/kubeconfig

oc wait --for=condition=Ready nodes --all
oc wait --for=condition=Available deployments --all --all-namespaces --timeout=120s

echo "DONE"
