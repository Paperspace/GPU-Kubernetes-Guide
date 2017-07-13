#!/bin/sh
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

sudo systemctl enable docker && systemctl start docker
sudo systemctl enable kubelet && systemctl start kubelet

for file in /etc/systemd/system/kubelet.service.d/*-kubeadm.conf
do
    echo "Found ${file}"
    FILE_NAME=$file
done

echo "Chosen ${FILE_NAME} as kubeadm.conf"
sudo sed -i '/^ExecStart=\/usr\/bin\/kubelet/ s/$/ --feature-gates="Accelerators=true"/' ${FILE_NAME}

sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo kubeadm init --kubernetes-version v1.6.6 --apiserver-advertise-address=$1 #TODO: use private IP
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf #TODO: move this to bash profile

kubectl apply -f https://git.io/weave-kube-1.6
kubectl create -f https://git.io/kube-dashboard
