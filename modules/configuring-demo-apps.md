# Configuring demo applications

**Goal:** Deploy and configure demo applications.

## Steps

1. Deploy policy tiers.

    We are going to deploy some policies into policy tier to take advantage of hierarcical policy management.

    ```bash
    kubectl apply -f demo/tiers
    ```

    This will add tiers `security`, `platform` and `devops` to the Calico cluster.

2. Deploy base policy.

    In order to explicitly allow workloads to connect to the Kubernetes DNS component, we are going to implement a policy that controls such traffic.

    ```bash
    kubectl apply -f demo/101-security-controls/platform.allow-kube-dns.yaml
    ```

3. Deploy demo applications.

    ```bash
    #deploy dev app stack
    kubectl apply -f demo/dev-stack/
    
    #deploy acme app stack
    kubectl apply -f demo/acme-stack/

    #deploy storefront app stack
    kubectl apply -f demo/storefront-stack/

    #deploy hipstershop app stack
    kubectl apply -f demo/hipstershop/
    ```

   

4. Deploy compliance reports which schedule as cronjob in every 15 mins.

    >The compliance reports will be needed for one of a later lab, is cronjob in your cluster, you can change the schedule by edit it.

    ```bash
    kubectl apply -f demo/compliance-reports
    ```

5. Deploy global alerts.

    >The alerts will be explored in a later lab.

    ```bash
    kubectl apply -f demo/alerts/
   
    ```

6. Confirm the global compliance report and global alert are running.
    
    ```bash
    kubectl get globalreport

    kubectl get globalalert
   
    ``` 


    The output looks like as below:

    ```text
    NAME                      CREATED AT 
    cis-results               2021-09-30T15:42:33Z
    cluster-inventory         2021-09-30T15:42:33Z
    cluster-network-access    2021-09-30T15:42:33Z
    cluster-policy-audit      2021-09-30T15:42:33Z
    workload-inventory        2021-09-30T15:42:33Z
    workload-network-access   2021-09-30T15:42:34Z
    workload-policy-audit     2021-09-30T15:42:34Z

    NAME                      CREATED AT
    dns.unsanctioned.access   2021-09-30T15:42:40Z
    network.lateral.access    2021-09-30T15:42:40Z
    policy.globalnetworkset   2021-09-30T15:42:39Z
    ```

[Next -> App service control](../modules/app-service-control.md)

[Menu](../README.md)



