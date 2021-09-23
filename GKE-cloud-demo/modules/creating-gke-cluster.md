# Module 0-1: Creating GKE cluster

**Goal:** Create GKE cluster.

> This workshop uses GKE cluster with most of the default configuration settings. To create an GKE cluster with a regional cluster with a multi-zone node pool, please refer to [GKE doc](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-regional-cluster#create-regional-multi-zone-nodepool) 


## Prerequisite Tasks

- Ensure that you have enabled the Google Kubernetes Engine API.

 ![api engine](../img/gke_api.png)

https://cloud.google.com/kubernetes-engine/docs/quickstart

- Ensure you have installed the [Cloud SDK](https://cloud.google.com/sdk/docs/install)

- Ensure you set up default gcloud settings using one of the following methods:

   Using gcloud init, if you want to be walked through setting defaults.
   Using gcloud config, to individually set your project ID, zone, and region.

   ```bash
   gcloud init                                                                    
   Welcome! This command will take you through the configuration of gcloud.
   ```

- Export your gcloud settings for next steps: 
   ```bash
   REGION=us-east1
   # Persist for Later Sessions in Case of Timeout
   echo export REGION=us-east1 >> ~/.bashrc

   LOCATION=us-east1-b
   # Persist for Later Sessions in Case of Timeout
   echo export LOCATION=us-east1-b >> ~/.bashrc

   CLUSTERNAME=gke-jessie-workshop
   # Persist for Later Sessions in Case of Timeout
   echo export CLUSTERNAME=gke-jessie-workshop >> ~/.bashrc
   ```

## Steps 
    
1.  Create a GKE cluster for this workshop.
   ```bash
   gcloud container clusters create $CLUSTERNAME \
   --region $REGION \
   --node-locations $LOCATION \
   --addons HorizontalPodAutoscaling,HttpLoadBalancing \
   --num-nodes 2 \
   --enable-intra-node-visibility 
   ``` 

2. Getting credentials for your new cluster.
   ```bash
   gcloud container clusters get-credentials $CLUSTERNAME --zone $REGION 


3. Confirm nodes are ready status in your cluster.
   ```bash
   kubectl get nodes
   ``` 
   
## Next steps

You should now have a Kubernetes cluster running with 2 nodes. You do not see the master servers for the cluster because these are managed by GCP. The Control Plane services which manage the Kubernetes cluster such as scheduling, API access, configuration data store and object controllers are all provided as services to the nodes.
<br>    

    
[Next -> Module 1](../modules/joining-gke-to-calico-cloud.md)



