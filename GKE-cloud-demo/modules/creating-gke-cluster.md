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

gcloud compute instances create master \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --private-network-ip 10.142.0.11 \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet default \
    --zone us-east1-b \
    --tags kubernetes,controller



#################################

gcloud compute instances create worker  \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-2 \
    --private-network-ip 10.142.0.12
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet default \
    --zone us-east1-b \
    --tags kubernetes,worker


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







