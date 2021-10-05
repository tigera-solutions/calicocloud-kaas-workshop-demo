# Creating Kubeadm cluster

The following guide is based upon the doc from Calico OSS [self-managed GCE k8s installation](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-public-cloud/gce) for provisioning compute resources.

**Goal:** Create self-managed cluster.

> This workshop uses GCE and other resources in GCP as default configuration settings. To create an self-managed cluster with other cloud providers such as AAWS & Azure, please refer to [self-managed installation](hhttps://docs.projectcalico.org/getting-started/kubernetes/self-managed-public-cloud/) 


## Prerequisite Tasks

### Utility 

- Ensure you have installed the [Cloud SDK](https://cloud.google.com/sdk/docs/install)

- Ensure you set up default gcloud settings using one of the following methods:
   
   Using gcloud init, if you want to be walked through setting defaults.
   Using gcloud config, to individually set your project ID, zone, and region.

   ```bash
   gcloud init                                                                    
   Welcome! This command will take you through the configuration of gcloud.
   ```

   Then be sure to authorize gcloud to access the Cloud Platform with your Google user credentials:

   ```bash
   gcloud auth login
   ```

   Next set a default compute region and compute zone:

   ```bash
   gcloud config set compute/region us-east1
   ```

   Set a default compute zone:

   ```bash
   gcloud config set compute/zone us-east1-b
   ```


### Provisioning networking

1. Create the VPC

   In this section a dedicated [Virtual Private Cloud](https://cloud.google.com/compute/docs/networks-and-firewalls#networks) (VPC) network will be setup to host the Kubernetes cluster.

   Create the `calicocloud-vpc` custom VPC network:

   ```bash
   gcloud compute networks create calicocloud-vpc --subnet-mode custom
   ```


2. Create the subnet

   A [subnet](https://cloud.google.com/compute/docs/vpc/#vpc_networks_and_subnets) must be provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.

   Create the `k8s-nodes` subnet in the `calicocloud-vpc` VPC network:

   ```bash
   gcloud compute networks subnets create k8s-nodes \
   --network calicocloud-vpc \
   --range 10.240.0.0/24
   ```

   > The `10.240.0.0/24` IP address range can host up to 254 compute instances.


3. Create the firewall rules

   a. Create a firewall rule that allows internal communication across all protocols:

   ```bash
   gcloud compute firewall-rules create calicocloud-vpc-allow-internal \
   --allow tcp,udp,icmp \
   --network calicocloud-vpc \
   --source-ranges 10.240.0.0/24,192.168.0.0/16
   ```
   > Calico overlay also require the 'ipip' protocol, which is out of scope for this workshop.

   b. Create a firewall rule that allows external SSH, ICMP, and HTTPS:

   ```bash
   gcloud compute firewall-rules create calicocloud-vpc-allow-external \
   --allow tcp:22,tcp:6443,tcp:8080,tcp:5443,icmp \
   --network calicocloud-vpc \
   --source-ranges 0.0.0.0/0
   ```

   > An [external load balancer](https://cloud.google.com/compute/docs/load-balancing/network/) will be used to expose the Kubernetes API Servers to remote clients.

   c. List the firewall rules in the `calicocloud-vpc` VPC network:

   ```bash
   gcloud compute firewall-rules list --filter="network:calicocloud-vpc"
   ```

   > output

   ```bash
   NAME                            NETWORK          DIRECTION  PRIORITY  ALLOW                                       DENY  DISABLED
   calicocloud-vpc-allow-external  calicocloud-vpc  INGRESS    1000      tcp:22,tcp:6443,tcp:8080,tcp:5443,udp,icmp        False
   calicocloud-vpc-allow-internal  calicocloud-vpc  INGRESS    1000      tcp,udp,icmp                                      False
   ```

4. Create a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:

   ```bash
   gcloud compute addresses create calicocloud-vpc \
   --region $(gcloud config get-value compute/region)

   sleep 5

   #Verify the calicocloud-vpc static IP address was created in your default compute region
   gcloud compute addresses list --filter="name=('calicocloud-vpc')"
   ```

   > output
   ```bash
   NAME             ADDRESS/RANGE  TYPE      PURPOSE  NETWORK  REGION    SUBNET  STATUS
   calicocloud-vpc  XX.XX.XX.XX    EXTERNAL                    us-east1          RESERVED
   ```


### Provisioning compute instances

The compute instances in this lab will be provisioned using [Ubuntu Server](https://www.ubuntu.com/server) 20.04. We will have 1 master node + 2 worker node.

1. Create one controller node

   ```bash
   gcloud compute instances create master-node \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-4 \
    --private-network-ip 10.240.0.11 \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet k8s-nodes \
    --zone us-east1-b \
    --tags calicocloud,master

   ```

2. Create three compute instances which will host the Kubernetes worker nodes:   

   ```bash
   for i in 0 1; do
   gcloud compute instances create worker-node${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-2004-lts \
    --image-project ubuntu-os-cloud \
    --machine-type e2-standard-4 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet k8s-nodes \
    --zone us-east1-b \
    --tags calicocloud,worker
   done
   ```

3. Verify the instances are running as desired. 

   ```bash
   gcloud compute instances list --filter="tags.items=calicocloud"
   ```

   > Output 
   ```bash
   NAME          ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
   master-node   us-east1-b  e2-standard-4               10.240.0.11  XX.XX.XX.XX    RUNNING
   worker-node0  us-east1-b  e2-standard-4               10.240.0.20  XX.XX.XX.XX    RUNNING
   worker-node1  us-east1-b  e2-standard-4               10.240.0.21  XX.XX.XX.XX    RUNNING
   ```

4. Configuring SSH access to each instance.

   SSH will be used to configure the master and worker instances. When connecting to compute instances for the first time SSH keys will be generated for you and stored in the project or instance metadata as described in the [connecting to instances](https://cloud.google.com/compute/docs/instances/connecting-to-instance) documentation.

   Test SSH access to the `master-node` compute instances as example:

   ```bash
   gcloud compute ssh master-node
   ```

   If this is your first time connecting to a compute instance SSH keys will be generated for you. Enter a passphrase at the prompt to continue:

   
   > Output 
   ```bash
   WARNING: The public SSH key file for gcloud does not exist.
   WARNING: The private SSH key file for gcloud does not exist.
   WARNING: You do not have an SSH key for gcloud.
   WARNING: SSH keygen will be executed to generate a key.
   Generating public/private rsa key pair.
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   ```

   At this point the generated SSH keys will be uploaded and stored in your project:

   ```bash
   Updating project ssh metadata...-Updated [https://www.googleapis.com/compute/v1/projects/$PROJECT_ID].
   Updating project ssh metadata...done.
   Waiting for SSH key to propagate.
   ```

   After the SSH keys have been updated you'll be logged into the `master-node` instance:

   ```bash
   Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 5.4.0-1053-gcp x86_64)
   ```

   > Type `exit` at the prompt to exit the `master-node` compute instance, and you should be able to ssh other nodes with same key.   


## Steps

1. Install Docker & K8S components on the master VM and each worker VM. On each VM run:

   ```bash
   sudo swapoff -a
  
   sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y docker.io
   
   sudo systemctl enable docker.service && sudo apt install -y apt-transport-https curl
   
   sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"
  
   sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
   
   sudo apt-get update && sudo apt-get install -y kubeadm=1.21.1-00 kubelet=1.21.1-00 kubectl=1.21.1-00
   
   sudo apt-mark hold kubelet kubeadm kubectl
   ```
 
2. Initiate the master node with pod CIDR config. On master node run: 
 
   ```bash
   sudo kubeadm init --kubernetes-version 1.21.1 --pod-network-cidr 192.168.0.0/16
   ```

   > output include the token for worker node to join to the cluster, you can save them in txt if you want to use it later.  

   ```bash
   Then you can join any number of worker nodes by running the following on each as root:

   ##below is the token for worker node.
   kubeadm join 10.240.0.11:6443 --token XXXXXXXXXXX \
	--discovery-token-ca-cert-hash sha256:2a459afXXXXXXXXXXXa30a9cacb42XXXXXXXXXXXa761c1fbXXXXXXXXXXX
   ```

3.  set up kubectl for the ubuntu user. On master node run:

   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```

4. The final step is joining your worker node to master node. Run this on each worker, prepending sudo to run it as root. It will look something like this:
   
   ```bash
   sudo kubeadm join 10.240.0.11:6443 --token XXXXXXXXXXX \
   --discovery-token-ca-cert-hash sha256:2a459afXXXXXXXXXXXa30a9cacb42XXXXXXXXXXXa761c1fbXXXXXXXXXXX
   ```

5. On the controller, verify that all nodes have joined.

   ```bash
   kubectl get nodes
   ```

   >Output is 
   ```bash
   NAME           STATUS     ROLES                  AGE     VERSION
   master-node    NotReady   control-plane,master   15m     v1.21.1
   worker-node0   NotReady   <none>                 5m35s   v1.21.1
   worker-node1   NotReady   <none>                 24s     v1.21.1
   ```

6. On the controller, install calico OSS and then we can join this cluster to calico cloud as managed cluster. 

   ```bash
   kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
   ```


--- 
## Next steps

You should now have a Kubernetes cluster running with 3 nodes. The Control Plane services which manage the Kubernetes cluster such as scheduling, API access, configuration data store and object controllers are all provided as services to the nodes.
<br>    


[Next ->Joining cluster to Calico Cloud](../modules/joining-calico-cloud.md)

[Menu](../README.md)