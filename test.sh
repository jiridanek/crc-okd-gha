#!/bin/bash
set -Eeuxo pipefail

#crc setup
# https://github.com/crc-org/crc/blob/8456f7444ecdebf785199e7f90879e8f26f54e22/pkg/crc/preflight/preflight_ubuntu_linux.go#L32
sudo cat /etc/apparmor.d/libvirt/TEMPLATE.qemu
sudo sed -i "/^profile LIBVIRT_TEMPLATE flags=(attach_disconnected) {$/a$HOME/.crc/cache/*/crc.qcow2 rk," /etc/apparmor.d/libvirt/TEMPLATE.qemu
sudo cat /etc/apparmor.d/libvirt/TEMPLATE.qemu
sudo chmod 0644 /etc/apparmor.d/libvirt/TEMPLATE.qemu
#sudo systemctl reload apparmor

sudo ufw disable

sudo sysctl -w net.ipv4.ip_forward=1
sudo virsh net-define ~/crc_net.xml
sudo virsh net-start crc
sudo ip l
#sudo ip link set crc up
sudo virsh define ~/crc.xml

sudo setfacl -m u:libvirt-qemu:rx ~/


chmod o+x ~/
chmod o+x ~/.crc
chmod o+x ~/.crc/machines/
chmod o+x ~/.crc/machines/crc
sudo chown libvirt-qemu:kvm ~/.crc/machines/crc/crc.qcow2

chmod o+x ~/.crc/cache
chmod o+x ~/.crc/cache/crc_microshift_libvirt_4.14.7_amd64
sudo chown libvirt-qemu:kvm ~/.crc/cache/crc_microshift_libvirt_4.14.7_amd64/crc.qcow2

sudo virsh list
sudo virsh net-list
sudo ip route ls

#crc start
sudo virsh start crc

#sudo systemd-resolve --interface crc --set-dns 192.168.130.11 --set-domain ~testing
sudo echo 192.168.130.11 api.crc.testing canary-openshift-ingress-canary.apps-crc.testing console-openshift-console.apps-crc.testing default-route-openshift-image-registry.apps-crc.testing downloads-openshift-console.apps-crc.testing oauth-openshift.apps-crc.testing | sudo tee -a /etc/hosts

eval "$(crc oc-env)"
export KUBECONFIG=~/.crc/machines/crc/kubeconfig

until nc -zv 192.168.130.11 6443; do
  sudo virsh domifaddr crc
  sudo virsh dominfo crc
  echo "trying to connect to kube API"
  sleep 7
  oc wait --for=condition=Ready nodes --all || true
  ip a l
  ping -c4 192.168.130.11 || true
  set +x
done
set -x

oc wait --for=condition=Ready nodes --all --timeout=300s
oc wait --for=condition=Available deployments --all --all-namespaces --timeout=120s

echo "DONE"
