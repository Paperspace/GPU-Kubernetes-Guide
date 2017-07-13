#!/bin/sh
# Following arguments are necessary:
# 1. -> token ,  e.g. "f38242.e7f3XXXXXXXXe231e"
# 2. -> IP:port of the master
echo "The following token will be used: ${1}"
echo "The master nodes IP:Port is: ${2}"
sudo bash -c 'apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update'
sudo apt-get install -y --allow-unauthenticated docker-engine
sudo apt-get install -y --allow-unauthenticated kubelet=1.6.6-00 kubeadm=1.6.6-00 kubectl=1.6.6-00 kubernetes-cni
# sudo groupadd docker
sudo usermod -aG docker $USER

# Install CUDA and NVIDIA driver
sudo apt-get install -y linux-headers-$(uname -r)
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-get update
sudo apt-get install -y nvidia-375
sudo apt-get install -y nvidia-cuda-dev nvidia-cuda-toolkit nvidia-nsight

sudo systemctl enable docker && systemctl start docker
sudo systemctl enable kubelet && systemctl start kubelet

#put CUDA in the write place for tensorflow docker container
sudo cp /usr/lib/x86_64-linux-gnu/libcuda* /usr/lib/nvidia-375/

for file in /etc/systemd/system/kubelet.service.d/*-kubeadm.conf
do
    echo "Found ${file}"
    FILE_NAME=$file
done

sudo sed -i "/^ExecStart=\/usr\/bin\/kubelet/ s/$/ --feature-gates=\"Accelerators=true\" --hostname-override=$HOSTNAME/" ${FILE_NAME}

sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo kubeadm join --token $1 $2
