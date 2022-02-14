# Change to eBPF dataplane

**Goal:** Swap your kube-proxy from standard Linux dataplane to eBPF dataplane for preserving the source IP of traffic from outside

> While the standard dataplane focuses on compatibility by inter-working with kube-proxy, and your own iptables rules, the eBPF dataplane focuses on performance, latency and improving user experience with features that aren’t possible in the standard dataplane. As part of that, the eBPF dataplane replaces kube-proxy with an eBPF implementation. Please refer to [doc](https://docs.tigera.io/maintenance/ebpf/about-ebpf#calico-enterprises-ebpf-dataplane)

**Supported:**
  x86-64

**Not supported:**
  GKE, EKS using the default Ubuntu or Amazon Linux images.

## Steps

### For EKS cluster

1. Add another nodegroup in your EKS cluster with AMI which support eBPF. We will use `Bottlerocket` family. 

   ```bash

   cat > configs/nodegroup.yaml << EOF
   apiVersion: eksctl.io/v1alpha5
   kind: ClusterConfig
   metadata:
     name: "${EKS_CLUSTER}"
     region: "${AWS_REGION}"
     version: "${EKS_VERSION}"
   managedNodeGroups:
     - name: ebpf-pool # Customizable. The name of the node pool.
       amiFamily: Bottlerocket
       minSize: 0
       maxSize: 3
       instanceType: t3.xlarge # Customizable. The instance type for the node pool.
       desiredCapacity: 3 # Customizable. The initial amount of nodes to have live.

       ssh:
         # uncomment lines below to allow SSH access to the nodes using existing EC2 key pair
         publicKeyName: ${KEYPAIR_NAME}
         allow: true
   EOF
   ```

   ```bash
   eksctl create nodegroup --config-file=configs/nodegroup.yaml
   ```  
   > Confirm 6 nodes are ready before moving to next step.

2. Scale dowm your default node group `nix-t3-large` to 0 as we don't support hybrid mode for eBPF nodes and standard dataplane nodes.
   
   ```bash
   eksctl scale nodegroup --cluster=$EKS_CLUSTER --nodes=0 --name=nix-t3-large
   ```

   > Confirm only new 3 nodes are ready before moving to next step.

3. Patch the flexVolumePath in Installation resource, which is required for Bottlerocket compatibility.
   ```bash
   kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"flexVolumePath":"/var/lib/kubelet/plugins"}}'
   ```


4. Deploy the demo app `yaobank`, and run a quick test to trace the source IP address before changing to eBPF dataplane.

   a. Deloy demo application `yaobank`
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/tigera/ccol2aws/main/yaobank.yaml
   ```

   b. Deploy NLB for Frontend Customer Pod.
   ```bash
   kubectl apply -f - <<EOF
   apiVersion: v1
   kind: Service
   metadata:
     name: yaobank-customer
     namespace: yaobank
     annotations:
       service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
   spec:
     selector:
       app: customer
     ports:
       - port: 80
         targetPort: 80
     type: LoadBalancer
   EOF
   ```

   c. Check the source IP when curl customer svc 

    ```bash
    SVC_HOST=$(kubectl -n yaobank get svc yaobank-customer -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
    #Curl the svc host from your cloud9 or local shell
    curl $SVC_HOST
    ```
    
    ```bash
    #check the source IP fromm pod log
    export CUSTOMER_POD=$(kubectl get pods -n yaobank -l app=customer -o name)
    kubectl logs -n yaobank $CUSTOMER_POD
    ```
 
    > Output should be similar as below, the node private IP will show up as source IP.
    ```text
    192.168.15.251 - - [22/Oct/2021 17:16:34] "GET / HTTP/1.1" 200 -
    192.168.46.34 - - [22/Oct/2021 17:17:08] "GET / HTTP/1.1" 200 -
    192.168.90.180 - - [22/Oct/2021 17:17:11] "GET / HTTP/1.1" 200 -
    ```

5. Configure Calico to connect directly to the API server. 

   ```bash
   ##Extract API server address
   kubectl get cm -n kube-system kube-proxy -o yaml | grep server
   ```

   > Output is similar:

   ```bash
   # "66dxxxxxxyyyyyyyzzzzzz.yl4.us-east-2.eks.amazonaws.com" is your api server host for configmap
   server: https://66dxxxxxxyyyyyyyzzzzzz.yl4.us-east-2.eks.amazonaws.com
   ```

   Create configmap for calico-node to know how to contact Kubernetes API server.
   ```bash
   ##use above server host to create configmap. 
   kubectl apply -f - <<EOF
   kind: ConfigMap
   apiVersion: v1
   metadata:
     name: kubernetes-services-endpoint
     namespace: tigera-operator
   data:
     KUBERNETES_SERVICE_HOST: "<API server host>" 
     KUBERNETES_SERVICE_PORT: "443"
   EOF
   ```

6. The operator will pick up the change to the config map automatically and do a rolling update to pass on the change. Confirm that pods restart and then reach the Running state with the following command:
   ```bash
   kubectl get pods -n calico-system -w
   ```
   > If you do not see the pods restart then it’s possible that the ConfigMap wasn’t picked up (sometimes Kubernetes is slow to propagate ConfigMaps (see Kubernetes issue #30189)). You can try restarting the operator.
   ```bash
   kubectl delete pods -n calico-system --all
   #Verify all pods restart successfully
   kubectl get pods -n calico-system 
   ```

7. Replace kube-proxy
   > In eBPF mode, Calico replaces kube-proxy so it wastes resources to run both. To disable kube-proxy reversibly, we recommend adding a node selector to kube-proxy’s DaemonSet that matches no nodes. By doing so, we’re telling kube-proxy not to run on any nodes (because they’re all running Calico):

   ```bash
   kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'
   ```
   
   ```bash
   #Confirm kube-proxy is no longer running
   kubectl get pods -n kube-system
   ```

8. Enable eBPF mode
   > To enable eBPF mode, change the spec.calicoNetwork.linuxDataplane parameter in the operator’s Installation resource to "BPF"; you must also clear the hostPorts setting because host ports are not supported in BPF mode.

   ```bash
   kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'
   ```

9. Restart kube-dns and yaobank pod.

   > When the dataplane changes, it disrupts any existing connections, and as a result it’s a good idea to replace the pods that are running. In our specific case, deleting the kube-dns pods will ensure that connectivity for these pods is running fully on the eBPF dataplane, as these pods are integral to Kubernetes functionality.

   ```bash
   kubectl delete pod -n kube-system -l k8s-app=kube-dns
   kubectl delete pods -n yaobank --all
   ```

10. Curl the `yaobank-customer` service again and confirm the public IP address of `cloud9` or your local shell show up as source IP in pod logs.

   ```bash
   SVC_HOST=$(kubectl -n yaobank get svc yaobank-customer -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
   #Curl the svc host from your cloud9 or local shell
   curl $SVC_HOST
   ```
    
   ```bash
   #check the source IP fromm pod log
   export CUSTOMER_POD=$(kubectl get pods -n yaobank -l app=customer -o name)
   kubectl logs -n yaobank $CUSTOMER_POD
   ```
 
   > Output should be similar as below, the public IP will show up as source IP.
   ```text
   173.178.61.xxx - - [22/Oct/2021 17:38:11] "GET / HTTP/1.1" 200 -
   18.223.133.xxx - - [22/Oct/2021 17:38:22] "GET / HTTP/1.1" 200 -
   18.223.133.xxx - - [22/Oct/2021 17:38:58] "GET / HTTP/1.1" 200 -
   ```

### For AKS cluster
> The default AKS cluster Linux node support eBPF, however eBPF doesn't support windows node. If you have windows nodepool, please scale windows pool to 0.

1. Deploy the demo app `yaobank`, and run a quick test to trace the source IP address before changing to eBPF dataplane.

   a. Deloy demo application `yaobank`
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/tigera/ccol2aws/main/yaobank.yaml
   ```

   b. Deploy LB for Frontend Customer Pod.
   ```bash
   kubectl apply -f - <<EOF
   apiVersion: v1
   kind: Service
   metadata:
     name: yaobank-customer
     namespace: yaobank
   spec:
     selector:
       app: customer
     ports:
       - port: 80
         targetPort: 80
     type: LoadBalancer
   EOF
   ```

   c. Check the source IP when curl customer svc 

    ```bash
    SVC_HOST=$(kubectl -n yaobank get svc yaobank-customer -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
    #Curl the svc ip from your cloud shell/local shell or open in your browser to generate logs.
    curl $SVC_HOST
    ```
    
    ```bash
    #check the source IP fromm pod log
    export CUSTOMER_POD=$(kubectl get pods -n yaobank -l app=customer -o name)
    kubectl logs -n yaobank $CUSTOMER_POD
    ```
 
    > Output should be similar as below, the node private IP will show up as source IP.
    ```text
    10.240.0.35 - - [26/Oct/2021 19:20:52] "GET / HTTP/1.1" 200 -
    10.240.0.35 - - [26/Oct/2021 19:21:16] "GET / HTTP/1.1" 200 -
    10.240.0.35 - - [26/Oct/2021 19:21:58] "GET / HTTP/1.1" 200 -
    ```

2. Configure Calico to connect directly to the API server. 

   ```bash
   ##Extract API server address
   kubectl cluster-info | grep Kubernetes
   ```

   > Output is similar:

   ```bash
   # "aks-oss-je-aks-rg-xxxxxxxyyyyyyzzzzzz.hcp.eastus.azmk8s.io" is your api server host
   Kubernetes control plane is running at https://aks-oss-je-aks-rg-xxxxxxxyyyyyyzzzzzz.hcp.eastus.azmk8s.io:443
   ```

   Create configmap for calico-node to know how to contact Kubernetes API server.
   ```bash
   ##use above server host to create configmap. 
   cat > cm.yaml <<EOF
   kind: ConfigMap
   apiVersion: v1
   metadata:
     name: kubernetes-services-endpoint
     namespace: tigera-operator
   data:
     KUBERNETES_SERVICE_HOST: "<API server host>"  
     KUBERNETES_SERVICE_PORT: "443"
   EOF
   ```

   ```bash
   #edit the cm yaml file by replacing the API server host address before apply it 
   kubectl apply -f cm.yaml
   ```


3. The operator will pick up the change to the config map automatically and do a rolling update to pass on the change. Confirm that pods restart and then reach the Running state with the following command:
   ```bash
   kubectl get pods -n calico-system -w
   ```
   > If you do not see the pods restart then it’s possible that the ConfigMap wasn’t picked up (sometimes Kubernetes is slow to propagate ConfigMaps (see Kubernetes issue #30189)). You can try restarting the operator.
   ```bash
   kubectl delete pods -n calico-system --all
   #Verify all pods restart successfully
   kubectl get pods -n calico-system 
   ```

4. Replace kube-proxy
   > In eBPF mode, Calico replaces kube-proxy so it wastes resources to run both. To disable kube-proxy reversibly, we recommend adding a node selector to kube-proxy’s DaemonSet that matches no nodes. By doing so, we’re telling kube-proxy not to run on any nodes (because they’re all running Calico):

   ```bash
   kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'
   ```
   
   ```bash
   #Confirm kube-proxy is no longer running
   kubectl get pods -n kube-system
   ```

5. Enable eBPF mode
   > To enable eBPF mode, change the spec.calicoNetwork.linuxDataplane parameter in the operator’s Installation resource to "BPF"; you must also clear the hostPorts setting because host ports are not supported in BPF mode.

   ```bash
   kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"BPF", "hostPorts":null}}}'
   ```

6. Restart kube-dns and yaobank pod.

   > When the dataplane changes, it disrupts any existing connections, and as a result it’s a good idea to replace the pods that are running. In our specific case, deleting the kube-dns pods will ensure that connectivity for these pods is running fully on the eBPF dataplane, as these pods are integral to Kubernetes functionality.

   ```bash
   kubectl delete pod -n kube-system -l k8s-app=kube-dns
   kubectl delete pods -n yaobank --all
   ```

7. Curl the `yaobank-customer` service again and confirm the public IP address of cloudshell or your local shell show up as source IP in pod logs.

   ```bash
   SVC_HOST=$(kubectl -n yaobank get svc yaobank-customer -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
   #Curl the svc ip from your cloud shell/local shell or open in your browser to generate logs.
   curl $SVC_HOST
   ```
    
   ```bash
   #check the source IP fromm pod log
   export CUSTOMER_POD=$(kubectl get pods -n yaobank -l app=customer -o name)
   kubectl logs -n yaobank $CUSTOMER_POD
   ```
 
   > Output should be similar as below, the public IP will show up as source IP.
   ```text
   40.114.1.180 - - [26/Oct/2021 19:54:13] "GET / HTTP/1.1" 200 -
   173.178.61.132 - - [26/Oct/2021 19:55:37] "GET / HTTP/1.1" 200 -
   ```


### For Kubeadm cluster

### For RKE cluster 



## <Option> - Reverse to standard Linux dataplane from eBPF dataplane 

1. Reverse the changes to the operator’s Installation

   ```bash
   kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"Iptables"}}}'
   ```
2. Re-enable kube-proxy by removing the node selector added above

   ```bash
   kubectl patch ds -n kube-system kube-proxy --type merge -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": null}}}}}'
   ```

3. Restart kube-dns and yaobank pod.

   ```bash
   kubectl delete pod -n kube-system -l k8s-app=kube-dns
   kubectl delete pods -n yaobank --all
   ```

4. Delete the configmap which created for calico-node as we don't need connect to api server directly anymore.

   ```bash
   kubectl delete cm -n tigera-operator kubernetes-services-endpoint 
   ```

   ```bash
   #confirm calico-node restart again, if not, restart them.
   kubectl get pods -n calico-system
   ```

5. Confirm the source IP in yaobank-customer pod been reversed to node private IP.   

   ```bash
   #check the source IP fromm pod log
   export CUSTOMER_POD=$(kubectl get pods -n yaobank -l app=customer -o name)
   curl $SVC_HOST
   kubectl logs -n yaobank $CUSTOMER_POD
   ```
 
6. For EKS cluster, you can scale up your orginal nodegroup and delete the ebpf nodegroup after reverse the dataplane. 

   ```bash
   eksctl scale nodegroup --cluster=$EKS_CLUSTER --nodes=3 --name=nix-t3-large
   eksctl scale nodegroup --cluster=$EKS_CLUSTER --nodes=0 --name=ebpf-pool
   eksctl delete nodegroup --cluster=$EKS_CLUSTER --name=ebpf-pool
   ```


[Next -> Adding windows workload](../modules/windows-workload.md)

[Menu](../README.md)