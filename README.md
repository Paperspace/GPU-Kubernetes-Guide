# How to setup a production-grade Kubernetes GPU cluster on Paperspace in 10 minutes. 🌈
*note: this guide accompanies a blog post here: and is heavily derived from the fantastic guide [here](https://github.com/azlyth/Kubernetes-GPU-Guide)* 
## Table of Contents
  * [Why Kubernetes](#quick-kubernetes-revive)
  * [Cluster Overview](#rough-overview-on-the-structure-of-the-cluster)
  * [Step 1: Create a Paperspace Account](#Step-1:-Create-a-Paperspace-Account)
  * [Step 2: Create a private network]()
  * [Step 3: Prepare master node (CPU)]()
  * [Step 4: Install Kubernetes on the master node (CPU)]()
  * [Step 5: Prepare GPU worker node]()
  * [Step 6: Deploy a Jupyter-notebook with GPU-support]()
  * [Step 7: Assign a public IP to Worker node]()
  * [Acknowledgements](#acknowledgements)
  * [Authors](#authors)
  * [License](#license)
#### Why Kubernetes
If you are a startup or individual interested in getting a production-grade ML/Datascience pipeline going, Kubernetes can be extremely valuable. It is without a doubt one of the best 
### Step 1: Create a Paperspace Account
![screenshot_6](https://user-images.githubusercontent.com/585865/28176312-e96fb4aa-67c4-11e7-990e-e8a258cbaddc.png)

### Step 2: Create a private network
![screenshot_2](https://user-images.githubusercontent.com/585865/28176354-0bd715b0-67c5-11e7-8477-378f507d780c.png)

### Step 3: Prepare master node (CPU)
 ![screenshot_1](https://user-images.githubusercontent.com/585865/28176369-16481aa8-67c5-11e7-82d6-b43ef4f3881a.png)

 Create a [Paperspace C2 instance](https://paperspace.zendesk.com/hc/en-us/articles/236361368-What-types-of-machines-does-Paperspace-offer-) running Ubuntu 16.04 and make sure it is on your private network.
 
 * Disable UFW firewall (*note: we do this for testing only, you will want to reenable it later for security. That said, on Paperspace before you add a public IP your machines are fully isolated*)
 
![screenshot_3](https://user-images.githubusercontent.com/585865/28176455-79486fea-67c5-11e7-8c63-dc5ec464e552.png)



 ```
sudo ufw disable
```
 
### Step 4: Install Kubernetes on the master node (CPU)
Execute the [initialization script](scripts/init-master.sh) and remember the token 😉 <br>
The token will look like this: ```--token f38242.e7f3XXXXXXXXe231e```. It is very helpful to go through this short script. Basically, it downloads Kubernetes, Docker, and a few required packages, installs them, and initiates the Kubernetes process using the `kubeadm` tool. 
*Note: because we are building our cluster on an isolated private network we can safely assume that all nodes can talk to one another but are not yet publicly addressable*
```
chmod +x init-master.sh
sudo ./init-master.sh <IP-of-master>
```
This will return a  token in the format ```--token f38242.e7f3XXXXXXXXe231e```. This token, combined with the private IP of this host (i.e. `10.18.19.12`) will be used by the worker node to discover and join the Kubernetes cluster.

### Step 5: Prepare GPU worker node
Create a Paperspace GPU+ instance running Ubuntu 16.04 and make sure it is on your private network. We could use the ML-in-a-box template for this, but really we only need the NVIDIA driver and CUDA installed. This worker node will be used to run GPU-backed docker containers that are assigned to it by the Kubernetes master node.
Execute the [initialization script](scripts/init-worker.sh) with the correct token and private IP of your master.<br/>
The port is usually ```6443```.
```
chmod +x init-worker.sh
sudo ./init-worker.sh <Token-of-Master> <IP-of-master>:<Port>
```
 
 
### Step 6: Deploy a Jupyter-notebook with GPU-support
 
The deployment defines which docker container is used and what its features/specs are and the Service is responsible for assigning an addressable port to it. We are using the Kubernetes `NodePort` service type which will choose a port to assign to the container and make it available on all worker nodes. For now, all you need to know is that Kubernetes will find our GPU-backed worker node and send the Jupyter notebook to it.
Download the yaml file from this github repo (you could also copy/paste it using Vim, Nano, Emacs, etc)<br>
```
wget https://raw.githubusercontent.com/Paperspace/Kubernetes-GPU-Guide/master/deployments/example-gpu-deployment.yaml
```
Have kubernetes deploy it:<br>
```
kubectl apply -f jupyterGPU.yaml
```
### Step 7: Assign a public IP to Worker node
Ok, so this is not a best practice, but it will quickly let us see if everything is working. 
#### Step 8: All done! Woooo!
That's it. You have done what very few people have accomplished -- a GPU-backed Kubernetes cluster. 

![screen shot 2017-07-13 at 12 22 56 pm](https://user-images.githubusercontent.com/585865/28176617-201ae10e-67c6-11e7-8601-a840fc4c867e.png)

Now, in [Part 2]() we will cover adding storage, and building out a real pipeline. 
