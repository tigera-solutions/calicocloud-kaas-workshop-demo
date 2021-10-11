# Security: Wireguard Encryption

**Goal:** Enable wireguard as node to node encryption for data in transit 

>Wireguard enable layer 3 encryption, you can enable it with one command setting, we do everything else (interface, peer configuration, sharing public keys, route tables, ip rules, etc), Wireguard could be disabled/enabled on the entire cluster, or specific nodes, for specific nodes configuration, please refer to [doc] (https://docs.tigera.io/compliance/encrypt-cluster-pod-traffic)


## Steps

1. Enable WireGuard encryption across all the nodes using the following command.
    
   ```bash
   #Install WireGuard on the default AMI for each node, you can skip this step if you are using AKS cluster.
   sudo yum install kernel-devel-`uname -r` -y
   sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
   sudo curl -o /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
   sudo yum install wireguard-dkms wireguard-tools -y
   ```

   ```bash
   #Enable wireguard in your cluster
   kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'
   ```

   Output will be like this:
   ```bash
   felixconfiguration.projectcalico.org/default patched
   ```


2. Verify that the nodes are configured for WireGuard encryption. 
   
   ```bash
   NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="Hostname")].address}'| awk '{print $1;}')
   
   kubectl get node $NODE_NAME -o yaml

   ```

   Output will be like:
   ```bash
    annotations:
      projectcalico.org/WireguardPublicKey: jlkV-####-####-ez5eWh44
   ```

3. You can also verify it in one of the nodes, Calico will generate a wireguard interface as `wireguard.cali` 

   a. For `AKS` 

   ```bash
   ##This command starts a privileged container on your node and connects to it over SSH.
   kubectl debug node/$NODE_NAME -it --image=mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
   ```
   Output will be like:
   ```bash
   Creating debugging pod node-debugger-aks-nodepool1-41939440-vmss000001-c9bjq with container debugger on node aks-nodepool1-41939440-vmss000001.
   If you don't see a command prompt, try pressing enter.
   ```

   ```bash
   ifconfig | grep wireguard
   ```
   
   Output will be like:
   ```bash
   root@aks-nodepool1-41939440-vmss000001:/# ifconfig | grep wireguard
   wireguard.cali: flags=209<UP,POINTOPOINT,RUNNING,NOARP>  mtu 1440
   root@aks-nodepool1-41939440-vmss000001:/#
   ```

   b. For `EKS`

   ```bash   
   #install net-tools
   sudo apt install net-tools

   # View Wireguard tunnel interfaces:
   ifconfig

   # wg command will show more detail
   sudo wg show


4. Enable WireGuard statistics

   > To access wireguard statistics, prometheus stats should be turned on. 

   ```bash
   kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"nodeMetricsPort":9091}}'

   kubectl apply -f demo/encryption/wireguard-statistics.yaml
   ```





[Next -> eBPF dataplane](../modules/ebpf-dataplane.md)

[Menu](../README.md)