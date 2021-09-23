# Module 0-1: Creating GKE cluster

**Goal:** Create GKE cluster.

> This workshop uses GKE cluster with most of the default configuration settings. To create an GKE cluster with a regional cluster with a multi-zone node pool, please refer to [GKE doc](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-regional-cluster#create-regional-multi-zone-nodepool) 


## Prerequisite Tasks

- Ensure that you have enabled the Google Kubernetes Engine API.

 ![api engine](../img/gke_api.png)
https://cloud.google.com/kubernetes-engine/docs/quickstart

- Ensure you .
   





gcloud compute firewall-rules create default-allow-all --allow="tcp,4,udp,icmp"

enable Kubernetes Enginer API for your IAM

ubuntu@client:~/calico$ cat 1_create_k8s_on_gce.sh 
gcloud container clusters create calico --num-nodes 1 --machine-type n1-standard-2  \
        --cluster-version latest \
        --metadata disable-legacy-endpoints=true \
        --cluster-version  1.16.9-gke.6 \
        --addons HorizontalPodAutoscaling,HttpLoadBalancing \
        --image-type UBUNTU_CONTAINERD \
        --enable-intra-node-visibility \



        #################################




########

sudo apt update
sudo apt install -y docker.io 
sudo systemctl enable docker.service
sudo apt install -y apt-transport-https curl


########
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl    


########master#######
sudo kubeadm init --pod-network-cidr 192.168.0.0/16



## Next steps

You should now have a Kubernetes cluster running with 3 nodes. You do not see the master servers for the cluster because these are managed by GCP. The Control Plane services which manage the Kubernetes cluster such as scheduling, API access, configuration data store and object controllers are all provided as services to the nodes.
<br>    

    
[Next -> Module 1](../modules/joining-gke-to-calico-cloud.md)



