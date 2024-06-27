#!/bin/bash

set -e

cd $(dirname $0)

source "../azure.env"

# Extract the version number from the TENANT_VERSION env variable
VERSION=${TENANT_VERSION%.*}

# Create the cloudinit.yaml file with dynamic Kubernetes version
cat > ../config/cloudinit.yaml <<EOF
#cloud-config
package_upgrade: true
packages:
  - containerd
  - apt-transport-https
  - ca-certificates
  - curl
write_files:
  - owner: root:root
    path: /etc/modules-load.d/containerd.conf
    content: |
      overlay
      br_netfilter
  - owner: root:root
    path: /etc/sysctl.d/99-kubernetes-cri.conf
    content: |
      net.bridge.bridge-nf-call-iptables  = 1
      net.ipv4.ip_forward                 = 1
      net.bridge.bridge-nf-call-ip6tables = 1
runcmd:
  - sudo modprobe overlay
  - sudo modprobe br_netfilter
  - sudo sysctl --system
  - sudo mkdir -p /etc/containerd
  - containerd config default | sed -e 's#SystemdCgroup = false#SystemdCgroup = true#g' | sudo tee -a /etc/containerd/config.toml
  - sudo systemctl restart containerd
  - sudo systemctl enable containerd
  - sudo mkdir -p /etc/apt/keyrings
  - sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/${VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  - echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  - sudo apt update
EOF

