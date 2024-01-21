#!/bin/bash
set -Eeuxo pipefail

crc setup

sudo virsh net-define ~/crc_net.xml
sudo virsh define ~/crc.xml
chmod o+x ~/
chmod o+x ~/.crc
chmod o+x ~/.crc/cache
chmod o+x ~/.crc/machines/
chmod o+x ~/.crc/machines/crc
sudo chown libvirt-qemu:libvirt ~/.crc/machines/crc/crc.qcow2

#crc start
sudo virsh start crc

sudo echo 192.168.130.11 api.crc.testing canary-openshift-ingress-canary.apps-crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing downloads-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing | sudo tee -a /etc/hosts

eval "$(crc oc-env)"
export KUBECONFIG=~/.crc/machines/crc/kubeconfig

until nc -z 192.168.130.11 6443; do
  echo "trying to connect to kube API"
  sleep 7
  set +x
done
set -x

oc wait --for=condition=Ready nodes --all --timeout=300s
oc wait --for=condition=Available deployments --all --all-namespaces --timeout=120s

echo "DONE"
