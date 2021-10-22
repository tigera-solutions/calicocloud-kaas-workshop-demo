# Change to eBPF dataplane

**Goal:** Swap your kube-proxy from standard Linux dataplane to eBPF dataplane for preserving the source IP of traffic from outside

>While the standard dataplane focuses on compatibility by inter-working with kube-proxy, and your own iptables rules, the eBPF dataplane focuses on performance, latency and improving user experience with features that aren’t possible in the standard dataplane. As part of that, the eBPF dataplane replaces kube-proxy with an eBPF implementation. Please refer to [doc] (https://docs.tigera.io/maintenance/ebpf/about-ebpf#calico-enterprises-ebpf-dataplane)


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
   > Confirm 3 nodes are ready before moving to next step.

2. Scale dowm your default node group `nix-t3-large` to 0 as we don't support hybrid mode for eBPF nodes and standard dataplane nodes.
   
   ```bash
   eksctl scale nodegroup --cluster=$EKS_CLUSTER --nodes=0 --name=nix-t3-large
   ```

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




5. Configure Calico to connect directly to the API server. 

   ```bash
   ##Extract API server address
   kubectl get cm -n kube-system kube-proxy -o yaml | grep server
   ```

   > Output is similar:

   ```bash
   # "66dxxxxxxyyyyyyyzzzzzz.yl4.us-east-2.eks.amazonaws.com" is your api server host
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
   > Now that Calico can communicate directly with the eBPF endpoint, we can enable eBPF mode to replace kube-proxy. To do this, we can patch kube-proxy to use a non-calico node selector. By doing so, we’re telling kube-proxy not to run on any nodes (because they’re all running Calico):

kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'
Verify kube-proxy is no longer running

kubectl get pods -n kube-system







### For AKS cluster

1. Verify that your cluster is ready for eBPF mode



### For GEK cluster
>Not supported. This is because of an incompatibility with the GKE CNI plugin. A fix for the issue has already been accepted upstream but at the time of writing it is not publicly available.

### For Kubeadm cluster

### For RKE cluster 



## <Option> - Reverse to standard Linux dataplane from eBPF dataplane 


[Next -> Non K8S node segmentation](../modules/non-k8s-node-segmentation.md)

[Menu](../README.md)