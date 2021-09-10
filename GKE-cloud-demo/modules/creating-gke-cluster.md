# Calico cloud workshop on GKE

<img src="img/calico.png" alt="Calico on GKE" width="30%"/>


## Workshop prerequisites

>It is recommended to follow the GKE creation step outlined in [Module 0](modules/creating-gke-cluster.md) and to keep the resources isolated from any existing deployments. If you are using a corporate GCP account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage AkS clusters and Load Balancer resources.

- [Calico Cloud trial account](https://www.calicocloud.io/home)
- GCP account and credentials to manage GKE resources
- Terminal or Command Line console to work with GCP resources and GKE cluster [Azure CLI](https://cloud.google.com/sdk/docs/install)
- `Git`
- `netcat`

## Modules

- [Module 0-1: Creating an AKS compatible cluster for Calico Cloud](modules/creating-aks-cluster.md)
- [Module 0-2: Joining AKS cluster to Calico Cloud](modules/joining-aks-to-calico-cloud.md)
- [Module 0-3: Configuring demo applications](modules/configuring-demo-apps.md)

- [Module 1-1: East-West controls-App service control](modules/app-service-control.md)
- [Module 1-2: East-West controls-Microsegmentation](modules/microsegmentation.md)
- [WIP][Module 1-3: East-West controls-Host protection](modules/host-protection.md)

- [Module 2-1: North-South Controls-Egress access controls, DNS policy and Global threadfeed ](modules/egress-access-controls.md)
- [WIP][Module 2-2: North-South Controls-Egress Gateway](modules/egress-gateway.md) 


- [Module 3-1: Observability-Dynamic Service Graph](modules/dynamic-service-graph.md)
- [Module 3-2: Observability-Kibana dashboard](modules/kibana-dashboard.md)
- [Module 3-3: Observability-Dynamic packet capture](modules/dynamic-packet-capture.md) 
- [WIP][Module 3-4: Observability-L7 visibility](modules/enable-l7-visibility.md) 

- [Module 4-1: Compliance and Security-Compliance](modules/compliance-reports.md) 
- [Module 4-2: Compliance and Security-Intrusion Detection and Prevention](modules/intrusion-detection-protection.md) 
- [WIP][Module 4-3: Compliance and Security-Encryption](modules/encryption.md) 


## Cleanup

1. Delete application stack to clean up any `loadbalancer` services.

    ```bash
    kubectl delete -f demo/dev-stack/
    kubectl delete -f demo/acme-stack/
    kubectl delete -f demo/storefront-stack
    kubectl delete -f demo/boutiqueshop/
    ```

2. Delete AKS cluster.

    ```bash
    az aks delete --name $CLUSTERNAME
    ```

3. Delete the azure resource group. 

    ```bash
    az group delete --resource-group $RGNAME
    ```



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







