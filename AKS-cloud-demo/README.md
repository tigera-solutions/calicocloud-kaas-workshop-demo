# Calico cloud workshop on AKS

<img src="img/calico-on-aks.png" alt="Calicocloud on AKS" width="30%"/>

## AKS Calico Cloud Workshop

The intent of this workshop is to introduce Calico Cloud(https://www.calicocloud.io/home/) to manage AKS clusters and leverage Calico features to implement the various use cases. While there are many capabilities that the Calico product provides, this workshop focuses on a subset of those that are used most often by enterprises to derive value from the Calico Product. 


## Learning Objectives

In this workshop we are going to focus on these main use cases (with links to Calico docs for further info). Note that features for policy and visibility as outlined in this workshop are identical between Calico Cloud and Calico Enterprise. Consult the [Calico Enterprise docs](https://docs.tigera.io/) for further reading:

- **Integration:** [Integrating Calico Cloud into the AKS clusters.](https://docs.calicocloud.io/install/system-requirements)
- **East-West security:** [leveraging zero-trust security approach.](https://docs.tigera.io/security/adopt-zero-trust)
- **Egress access controls:** [using DNS policy to access external resources by their fully qualified domain names (FQDN).](https://docs.calicocloud.io/use-cases/security-controls/global-egress)
- **Observability:** [exploring various logs and application level metrics collected by Calico.](https://docs.calicocloud.io/use-cases/troubleshoot-apps)
- **Compliance:** [providing proof of security compliance.](https://docs.tigera.io/compliance/)

## Join the Slack Channel

[Calico User Group Slack](https://slack.projectcalico.org/) is a great resource to ask any questions about Calico. If you are not a part of this Slack group yet, we highly recommend [joining it](https://slack.projectcalico.org/) to participate in discussions or ask questions. For example, you can ask questions specific to EKS and other managed Kubernetes services in the `#eks-aks-gke-iks` channel.

## Who should take this workshop?
- Developers
- DevOps Engineers
- Solutions Architects
- Anyone that is interested in Security, Observability and Network policy for Kubernetes.


## Workshop prerequisites

>It is recommended to follow the AKS creation step outlined in [Module 0](modules/creating-aks-cluster.md) and to keep the resources isolated from any existing deployments. If you are using a corporate Azure account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage AkS clusters and Load Balancer resources.

- [Azure Kubernetes Service](https://github.com/Azure/kubernetes-hackfest/blob/master/labs/networking/network-policy/)
- [Calico Cloud trial account](https://www.calicocloud.io/home)
- Terminal or Command Line console to work with Azure resources and AKS cluster
 
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



