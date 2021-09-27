# Calico cloud workshop on AKS

<img src="img/calico.png" alt="Calico on AKS" width="30%"/>


## Workshop prerequisites

>It is recommended to follow the AKS creation step outlined in [Module 0](modules/creating-aks-cluster.md) and to keep the resources isolated from any existing deployments. If you are using a corporate Azure account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage AkS clusters and Load Balancer resources.

- [Calico Cloud trial account](https://www.calicocloud.io/home)
- Azure account and credentials to manage AKS resources
- Terminal or Command Line console to work with Azure resources and AKS cluster [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- `Git`
- `netcat`

## Module

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
    kubectl delete -f demo/hipstershop/
    ```

2. Remove calicocloud components from your cluster.
   - Download the script 
   ```bash
   curl -O https://installer.calicocloud.io/manifests/v3.9.0-3/downgrade.sh
   ```

   - Make the script executable 
   ```bash
   chmod +x downgrade.sh
   ```

   - Run the script and read the help to determine if you need to specify any flags 
   ```bash
   ./downgrade.sh --help.
   ```

   - Run the script with any needed flags, for example: 
   ```bash
   ./downgrade.sh --remove-prometheus.
   
   ```   

3. Delete AKS cluster.

    ```bash
    az aks delete -n $CLUSTERNAME -g $RGNAME
    ```

4. Delete the azure resource group. 

    ```bash
    az group delete -g $RGNAME
    ```


