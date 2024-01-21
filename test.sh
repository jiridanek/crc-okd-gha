#!/bin/bash
set -Eeuxo pipefail

#crc setup

#sudo sysctl -w net.ipv4.ip_forward=1
sudo virsh net-define ~/crc_net.xml
sudo virsh net-start crc
sudo ip l
#sudo ip link set crc up
sudo virsh define ~/crc.xml
chmod o+x ~/
chmod o+x ~/.crc
chmod o+x ~/.crc/cache
chmod o+x ~/.crc/machines/
chmod o+x ~/.crc/machines/crc
sudo chown libvirt-qemu:libvirt ~/.crc/machines/crc/crc.qcow2

sudo virsh list
sudo virsh net-list
sudo ip route ls

#crc start
sudo virsh start crc

sudo echo 192.168.130.11 api.crc.testing canary-openshift-ingress-canary.apps-crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing downloads-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing | sudo tee -a /etc/hosts

eval "$(crc oc-env)"
export KUBECONFIG=~/.crc/machines/crc/kubeconfig

until nc -z 192.168.130.11 6443; do
  sudo virsh domifaddr crc
  echo "trying to connect to kube API"
  sleep 7
  set +x
done
set -x

oc wait --for=condition=Ready nodes --all --timeout=300s
oc wait --for=condition=Available deployments --all --all-namespaces --timeout=120s

echo "DONE"
