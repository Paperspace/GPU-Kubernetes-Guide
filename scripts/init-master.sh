#!/bin/sh

K8S_VERSION=1.15.4

# install docker
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker

# install kubernetes
sudo bash -c 'apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update'
sudo apt-get install -y --allow-downgrades --allow-unauthenticated kubelet=$K8S_VERSION-00 kubeadm=$K8S_VERSION-00 kubectl=$K8S_VERSION-00 kubernetes-cni

meta=$(curl http://metadata.paperspace.com/meta-data/machine)
privateIP=$(echo "$meta" | jq -r .privateIpAddress)
publicIP=$(echo "$meta" | jq -r .publicIpAddress)
sudo kubeadm init --kubernetes-version v$K8S_VERSION --apiserver-advertise-address "$privateIP" --apiserver-cert-extra-sans "$publicIP"
if [ ! -f $HOME/.kube/config ]; then
  mkdir $HOME/.kube
  sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
fi
sudo chown $(id -u):$(id -g) $HOME/.kube/config
