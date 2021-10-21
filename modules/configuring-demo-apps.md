# Configuring demo applications

**Goal:** Deploy and configure demo applications.

## Steps

1. Deploy policy tiers.

    We are going to deploy some policies into policy tier to take advantage of hierarcical policy management.

    ```bash
    kubectl apply -f demo/setup/tiers/
    ```
    This will add tiers `security`, and `platform` to the Calico cluster.
    

2. Deploy base policy.

    In order to explicitly allow workloads to connect to the Kubernetes DNS component, we are going to implement a policy that controls such traffic. We also deploy allow policy for logging and contraint for PCI compliance.

    ```bash
    kubectl apply -f demo/setup/stage0/
    ```

3. Deploy demo applications.

    ```bash
    #deploy dev app stack
    kubectl apply -f demo/setup/dev
    
    #deploy acme app stack
    kubectl apply -f demo/setup/acme

    #deploy storefront app stack
    kubectl apply -f demo/setup/storefront

    #deploy hipstershop app stack
    kubectl apply -f demo/setup/hipstershop
    ```

   

4. Deploy compliance reports which schedule as cronjob in every hour for cluster report and a daily cis benchmark report.

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

    ```bash
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



