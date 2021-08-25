# Calicocloud workshop on GKE

<img src="img/calico.png" alt="Calico on EKS" width="30%"/>


## Workshop prerequisites

>It is recommended to use your personal AWS account which would have full access to AWS resources. If using a corporate AWS account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage EKS clusters and Load Balancer resources.

- [Calico Cloud trial account](https://www.tigera.io/tigera-products/calico-cloud/)
  - for instructor-led workshop use instructions in the email you receive to request a Calico Trial account
  - for self-paced workshop follow the [link to register](https://www.tigera.io/tigera-products/calico-cloud/) for a Calico Trial account
- Terminal or Command Line console to work with [gcloud SDK ](https://cloud.google.com/sdk/docs/install)
  
- `Git`
- `netcat`


## Modules

- [Module 0-1: Creating an AKS compatible cluster for Calico Cloud](modules/creating-gke-cluster.md)
- [Module 0-2: Joining AKS cluster to Calico Cloud](modules/joining-gke-to-calico-cloud.md)
- [Module 0-3: Configuring demo applications](modules/configuring-demo-apps.md)

- [Module 1-1: East-West controls-App service control](modules/app-service-control.md)
- [Module 1-2: East-West controls-Microsegmentation](modules/microsegmentation.md)
- [WIP][Module 1-3: East-West controls-Host protection](modules/host-protection.md)

- [Module 2-1: North-South Controls-Egress access controls, DNS policy and Global threadfeed ](modules/egress-access-controls.md)
- [WIP][Module 2-2: North-South Controls-Egress Gateway](modules/egress-gateway.md) 


- [Module 3-1: Observability-Dynamic Service Graph](modules/dynamic-service-graph.md)
- [Module 3-2: Observability-Kibana dashboard](modules/kibana-dashboard.md)
- [Module 3-3: Observability-Dynamic packet capture](modules/dynamic-packet-capture.md) 
- [Module 3-4: Observability-L7 visibility](modules/enable-l7-visibility.md) 

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

2. Delete GKE cluster.

    ```bash
    
    ```

3. Delete the GKE resource. 

    ```bash
    
    ```


