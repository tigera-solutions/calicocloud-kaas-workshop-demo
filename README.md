# workshop-demo-master-folder
This is the master folder for Calicocloud demo for managed K8S clusters in different cloud platform. Every platform will have a separate folder with similar content, yet different installation steps for initizing the cluster. 

## Join the Slack Channel

[Calico User Group Slack](https://slack.projectcalico.org/) is a great resource to ask any questions about Calico. If you are not a part of this Slack group yet, we highly recommend [joining it](https://slack.projectcalico.org/) to participate in discussions or ask questions. For example, you can ask questions specific to EKS and other managed Kubernetes services in the `#eks-aks-gke-iks` channel.

## Workshop objectives

The intent of this workshop is to educate any person working with K8S cluster in one way or another about Calico features and how to use them. While there are many capabilities that Calico provides, this workshop focuses on a subset of those that are used most often by different types of technical users.


## STEP 1 - Create a compatible k8s cluster 

  - [Calico Cloud system requirement](https://docs.calicocloud.io/install/system-requirements)
  - [EKS: using cloud9 IDE as workstation to create an compatible EKS cluster](modules/creating-eks-cluster.md)
  - [AKS: using Azure SDK to create an compatible AKS cluster](modules/creating-aks-cluster.md)
  - [GKE: using gcloud SDK to create an compatible GKE cluster](modules/creating-gke-cluster.md)

## STEP 2 - Sign up in Calicocloud  

  - [Calico Cloud trial account](https://www.calicocloud.io/home/)
  - for instructor-led workshop use instructions in the email you receive to request a Calico Trial account
  - for self-paced workshop follow the [link to register](https://www.calicocloud.io/home) for a Calico Trial account

## STEP 3 - Joining your cluster to Calico Cloud

  - [Joining cluster to Calico Cloud](modules/joining-calico-cloud.md)

## STEP 4 - Download this repo 

  ```bash
  git clone https://github.com/tigera-solutions/calicocloud-kaas-workshop-demo.git

  cd calicocloud-kaas-workshop-demo
  ```

## STEP 5 - Configure demo applications

  - [Configuring demo applications](modules/configuring-demo-apps.md)

## STEP 6 - Try out some use cases

In this workshop we are going to focus on these main use cases:

- **North-South Controls: Egress access controls and DNS policies & Egress Gateway**
- **East-West Controls: App service control & Microsegmentation & Host protection**

- **Observability: Dynamic Service Graph & Dynamic Packet Capture & Kibana dashboard**
- **Compliance and Security: Compliance & Intrusion Detection and Prevention & Encryption**
- **Integration: Firewall Integration & SIEM Integration**

## Charpter One - Beginner

- [North-South Controls-DNS policy](modules/egress-access-controls.md)
- [North-South Controls-Global threadfeed](modules/egress-access-controls.md)
- [East-West controls-App service control](modules/app-service-control.md)
- [East-West controls-Microsegmentation](modules/microsegmentation.md)

- [Observability-Dynamic packet capture](modules/dynamic-packet-capture.md) 
- [Observability-Dynamic Service Graph](modules/dynamic-service-graph.md)
- [Observability-L7 visibility](modules/enable-l7-visibility.md) 
- [Observability-Kibana dashboard](modules/kibana-dashboard.md)


## Charpter Two - Intermediate

- [IDS/IPS](modules/intrusion-detection-protection.md)
- [Host protection](modules/host-protection.md)
- [Compliance](modules/compliance-reports.md) 
- [Encryption](modules/encryption.md) 


## Charpter Two - Advanced

- [WIP][Egress Gateway](modules/egress-gateway.md) 
- [WIP][SIEM Integration](modules/siem-integration.md) 
- [WIP][Firewall Integration](modules/firewall-integration.md) 
- [WIP][Performance Hotspots](modules/performance-hotspots.md) 