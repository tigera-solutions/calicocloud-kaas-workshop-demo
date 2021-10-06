# Observability: Dynamic packet capture

**Goal:** Configure packet capture for specific pods and review captured payload. 

Calico enterprise/cloud provide enhanced packet capture feature for DevOps troubleshooting.
For more details refer to [Packet Capture](https://docs.tigera.io/v3.10/visibility/packetcapture) documentaiton.

# Steps

## step 1. Capture all packet for nginx pods.

  1. Configure packet capture. Navigate to `demo/packet-capture` and review YAML manifests that represent packet capture definition. Each packet capture is configured by deploing a `PacketCapture` resource that targets endpoints using `selector` and `labels`.

  Deploy packet capture definition to capture packets for `dev/nginx` pods.

   ```bash
   kubectl apply -f demo/packet-capture/dev-nginx-pcap.yaml
   ```

  >Once the `PacketCapture` resource is deployed, Calico starts capturing packets for all endpoints configured in the `selector` field.


  2. Fetch and review captured payload.

  >The captured `*.pcap` files are stored on the hosts where pods are running at the time the `PacketCapture` resource is active.

  Retrieve captured `*.pcap` files and review the content.

   ```bash
   # get pcap files
   ./calicoctl captured-packets copy dev-capture-nginx --namespace dev

   ls dev-nginx*
   # view *.pcap content
   tcpdump -Xr dev-nginx-XXXXXX.pcap
   ```

  3. Stop packet capture

  Stop packet capture by removing the `PacketCapture` resource.

   ```bash
   kubectl delete -f demo/packet-capture/dev-nginx-pcap.yaml
   ```

## step 2. Capture packet per protocol for example `TCP` and port `3550`.

  1. Deploy packet capture definition to capture packets between `hipstershop/frontend` pod and `dev/netshoot` pod.

   ```bash
   kubectl apply -f demo/packet-capture/hipstershop-productcatalogservice-pcap.yaml
   ```

  2. Generate packet by running command:
  
   ```bash
   for i in {1..20}; do kubectl -n dev exec netshoot -- nc -zv productcatalogservice.hipstershop 3550; sleep 2; done
   ```

  3. Fetch and review captured payload.

  Retrieve captured `*.pcap` files and review the content.

   ```bash
   # get pcap files
   ./calicoctl captured-packets copy hipstershop-capture-productcatalogservice --namespace hipstershop

   ls productcatalog*.pcap
   # view *.pcap content
   tcpdump -Xr productcatalogservice-XXXXXX.pcap
   ```
    
  4. Stop packet capture

  Stop packet capture by removing the `PacketCapture` resource.

   ```bash
   kubectl delete -f demo/packet-capture/hipstershop-productcatalogservice-pcap.yaml
   ```


## step 3. Define different RBAC role for capture and fetch the payload.

>Packet Capture permissions are enforced using the standard Kubernetes RBAC based on Role and RoleBindings within a namespace. For demo purpose, we will create user tester with create/delete/get/list/update/watch packet captures for '`dev` namespace:

1. Create sa as `tester` in namespace `dev`
   ```bash
   kubectl create sa tester -n dev
   ```
2. 



[Next -> IDS/IPS](../modules/intrusion-detection-protection.md)

[Menu](../README.md)