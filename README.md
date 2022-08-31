https://github.com/tigera-solutions/calicocloud-kaas-workshop-demo

# Tigera Calico Cloud Workshop

## Join the Slack Channel

[Calico User Group Slack](https://slack.projectcalico.org/) is a great resource to ask any questions about Calico. If you are not a part of this Slack group yet, we highly recommend [joining it](https://slack.projectcalico.org/) to participate in discussions or ask questions. For example, you can ask questions specific to EKS and other managed Kubernetes services in the `#eks-aks-gke-iks` channel.

## Workshop objectives

The intent of this workshop is to guide users on connecting their K8s cluster to Calico Cloud and test out its security and observability features.

## STEP 1 - Create a compatible k8s cluster 

  - [Calico Cloud system requirement](https://docs.calicocloud.io/get-started/connect/)
  - [EKS: Use cloud9 IDE to create a compatible EKS cluster](modules/creating-eks-cluster.md)
  - [AKS: Use Azure SDK to create a compatible AKS cluster](modules/creating-aks-cluster.md)
  - [GKE: Use gcloud SDK to create a compatible GKE cluster](modules/creating-gke-cluster.md)

  - [Kubeadm: Use kops to create a compatible self-managed cluster in GCP](modules/creating-kubeadm-cluster.md)
  - [RKE: Use Rancher server to create a compatible RKE cluster in GCP](modules/creating-rke-cluster.md)
  - [WIP][OCP: Use Openshift to create a compatible OCP cluster](modules/creating-ocp-cluster.md)


## STEP 2 - Sign up for Calico Cloud  

  - Use this[link to register](https://www.calicocloud.io/) for a Calico Trial account

## STEP 3 - Connect your cluster to Calico Cloud

  - [Connect your cluster to Calico Cloud](modules/joining-calico-cloud.md)

## STEP 4 - Configure demo applications

  - [Configure demo applications](modules/configuring-demo-apps.md)

## STEP 5 - Test Calico Cloud features

Use cases:

  - **Network policy for segmentation and access control**
  - **Intrusion Detection**
    - **ThreatFeeds**
    - **Honeypods**
    - **Anomaly Detection**
  - **Observability**
    - **Service Graph**
    - **Packet Captures**
    - **Kibana dashboard**
    - **L7 logging**
 
Compliance
Observability: Dynamic Service Graph & Dynamic Packet Capture & Kibana dashboard
CIS Kubernetes Benchmark
Compliance reports
Network encryption with WireguardCompliance and Security: Compliance & Intrusion Detection and Prevention & Encryption
Integration: Firewall Integration (Egress Gateway)  & log export SIEM Integration
Federation - apply network policy between clusters


- **East-West Controls: App service control & Microsegmentation & Host protection**
- **North-South Controls: DNS Egress Controls & Egress Gateway**
- **Observability: Dynamic Service Graph & Dynamic Packet Capture & Kibana dashboard**
- **Compliance and Security: Compliance & Intrusion Detection and Prevention & Encryption**
- **Integration: Firewall Integration & SIEM Integration**

## Charpter A - Beginner

- [East-West: controls-App service control](modules/app-service-control.md)
- [East-West: controls-Pod microsegmentation](modules/pod-microsegmentation.md)
- [North-South: Controls-DNS egress control](modules/dns-egress-controls.md)
- [North-South: Controls-Global threadfeed](modules/global-threadfeed.md)

- [Observability: Calico Manager UI](modules/manager-ui.md)
- [Observability: Kibana dashboard](modules/kibana-dashboard.md)
- [Observability: L7 visibility](modules/enable-l7-visibility.md) 
- [Observability: Dynamic packet capture](modules/dynamic-packet-capture.md) 

## Charpter B - Intermediate

- [Security: IDS and IPS](modules/intrusion-detection-protection.md)
- [Security: Deep packet inspection](modules/deep-packet-inspection.md) 
- [Security: Compliance reports](modules/compliance-reports.md) 
- [Security: Wireguard Encryption](modules/encryption.md) 
- [Security: Host protection](modules/host-protection.md) 

- [Change to eBPF dataplane](modules/ebpf-dataplane.md) 
- [WIP][Enable Kubernetes Audit log](modules/audit-log.md) ## Finished EKS, AKS/GKE clusters not supported


## Charpter C - Advanced
Coming soon...

## Charpter D - Integration


## STEP 6 - Clean up your test environment

- [clean up](modules/clean-up.md)