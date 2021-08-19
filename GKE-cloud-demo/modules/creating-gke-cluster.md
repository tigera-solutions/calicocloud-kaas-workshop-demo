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