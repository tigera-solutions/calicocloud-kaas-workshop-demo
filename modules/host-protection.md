# Security: Host protection

**Goal:** Secure hosts ports with network policies.

Calico network policies not only can secure pod to pod communications but also can be applied to Kubernetes hosts to protect host based services and ports. For more details refer to [Protect Kubernetes nodes](https://docs.tigera.io/security/kubernetes-nodes) documentaiton.

## Steps

1. Enable automatic host endpoints
   ```bash
   # check whether auto-creation for HEPs is enabled. Default: Disabled
   kubectl get kubecontrollersconfiguration.p default -ojsonpath='{.status.runningConfig.controllers.node.hostEndpoint.autoCreate}'
   ```

   ```bash
   kubectl patch kubecontrollersconfiguration default --patch='{"spec": {"controllers": {"node": {"hostEndpoint": {"autoCreate": "Enabled"}}}}}'

   ```

   ```bash
   kubectl get heps -o wide
   ```
   >Output is similar as 

   ```bash
   NAME                                                    CREATED AT
   ip-192-168-28-80.us-east-2.compute.internal-auto-hep    2021-10-11T17:11:08Z
   ip-192-168-60-203.us-east-2.compute.internal-auto-hep   2021-10-11T17:11:08Z
   ip-192-168-86-192.us-east-2.compute.internal-auto-hep   2021-10-11T17:11:09Z
   ```

2. Enable automatic host endpoints flow logs.   
   
   ```bash
   kubectl patch felixconfiguration default -p '{"spec":{"flowLogsEnableHostEndpoint":true}}'
   ```  

3.  Expose the frontend service via the NodePort service type, we use `30080` port as example.
   ```bash
    kubectl -n hipstershop expose deployment frontend --type=NodePort --name=frontend-nodeport --overrides='{"apiVersion":"v1","spec":{"ports":[{"nodePort":30080,"port":80,"targetPort":8080}]}}'
   ```

4. Get public IP of node and test the exposed port of `30080` from your shell.
   ```bash
   PUB_IP=$(kubectl get nodes --selector=kubernetes.io/role!=master -o jsonpath={.items[*].status.addresses[?\(@.type==\"ExternalIP\"\)].address} | awk '{ print $1 }')
   ```

5. Label the node for HEP testing.
   ```bash
   NODE_NAME=$(kubectl get nodes -o wide | grep $PUB_IP | awk '{print $1}')

   kubectl label nodes $NODE_NAME  host-end-point=test
   ```

> The rest steps are depends on your enviroment. 


### For EKS cluster 

1. Open a port of NodePort service for public access on EKS node.

    ```bash
    # open access to the port in AWS security group
    EKS_CLUSTER='calicocloud-workshop' # adjust the name if you used a different name for your EKS cluster
    AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
    # pick one EKS node and use it's ID to get securigy group
    SG_ID=$(aws ec2 describe-instances --region $AWS_REGION --filters "Name=tag:Name,Values=$EKS_CLUSTER*" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[*].NetworkInterfaces[0].Groups[0].GroupId' --output text --output text)

    # open 30080 port in the security group for public access
    aws ec2 authorize-security-group-ingress --region $AWS_REGION --group-id $SG_ID --protocol tcp --port 30080 --cidr 0.0.0.0/0
    ```

    >It can take a moment for the node port to become accessible.

    If the frontend service port was configured correctly, the `nc` command should show you that the port is open.
    ```bash
    #test connection to frontend 30080 port from your local shell, the expected result is 30080 open. 
    nc -zv $PUB_IP 30080
    ```

2. Implement a Calico policy to control access to the service of NodePort type, which only allow `VM_IP` with port `30080` to frontend service.

    get public IP of Cloud9 instance in the Cloud9 shell
    ```bash
    VM_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
    
    # deploy HEP policy
    sed -i "s/\${VM_IP}/${VM_IP}\/32/g" ./demo/host-end-point/frontend-nodeport-access.yaml | kubectl apply -f -     
    
    # test access from Cloud9 shell, the expected result is 30080 open
    nc -zv $PUB_IP 30080 

    # test access from local shell, the expected result is 30080 Operation timed out
    nc -zv $PUB_IP 30080 
    ```

3. Confirm you are able to see the `VM_IP` as source IP and the host name in your flow log.

   ![source ip](../img/source-ip.png)

   ![host name](../img/host-name.png)


4. *[Optional]* Test another node in your node group. 

   > Once you label another node with `host-end-point=test`, you should not be able to access the frontend service i.e the node port `30080` from your local shell, but you should be able to access it from the Cloud9 shell i.e the `VM_IP`
   ```bash
   nc -zv <public ip of second node> 30080 
   ```
   > Note that in order to control access to the NodePort service, you need to enable `preDNAT` and `applyOnForward` policy settings.



### For AKS cluster 

### For GEK cluster

### For Kubeadm cluster

### For RKE cluster 


[Next -> eBPF dataplane](../modules/ebpf-dataplane.md)

[Menu](../README.md)