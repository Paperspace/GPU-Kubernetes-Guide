#!/bin/sh

K8S_VERSION=1.15.4

# Following arguments are necessary:
# 1. -> IP:port of the master
# 2. -> token ,  e.g. "f38242.e7f3XXXXXXXXe231e"
# 3. -> certHash
master=$1
token=$2
certHash=$3
if [ "$master" == "" ] || [ "$token" == "" ] | [ "$certHash" == "" ]; then
  echo "Missing parameters, usage: ./init-worker.sh IP:port token caCertHash"
  exit 1
fi
echo "The master nodes IP:Port is: ${master}"
echo "The following token will be used: ${token}"
echo "The token ca cert hash is: ${certHash}"

# Add docker
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add k8s
sudo bash -c '
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update'
sudo apt-get install -y --allow-unauthenticated kubelet=$K8S_VERSION-00 kubeadm=$K8S_VERSION-00 kubectl=$K8S_VERSION-00 kubernetes-cni

# Install CUDA and NVIDIA driver
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"
sudo apt-get update
sudo apt-get -y install cuda

# Enable services
sudo systemctl daemon-reload
sudo systemctl enable docker && systemctl start docker
sudo systemctl enable kubelet && systemctl start kubelet

sudo kubeadm join $master --token $token --discovery-token-ca-cert-hash $certHash
