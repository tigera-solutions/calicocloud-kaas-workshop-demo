# Module 0-4: Configuring demo applications

**Goal:** Deploy and configure demo applications.

## Steps

1. Deploy policy tiers.

    We are going to deploy some policies into policy tier to take advantage of hierarcical policy management.

    ```bash
    kubectl apply -f demo/tiers
    ```

    This will add tiers `devops-team``security-team` and `platform-team` to the Calico cluster.

2. Deploy base policy.

    In order to explicitly allow workloads to connect to the Kubernetes DNS component, we are going to implement a policy that controls such traffic.

    ```bash
    kubectl apply -f demo/101-security-controls/platform-team.allow-kube-dns.yaml
    ```

3. Deploy demo applications.

    ```bash
    # deploy dev app stack
    kubectl apply -f demo/dev-stack/
    
    # deploy acme app stack
    kubectl apply -f demo/acme-stack/

    # deploy hipstershop app stack
    kubectl apply -f demo/hipstershop/

    # deploy storefront app stack
    kubectl apply -f demo/storefront-stack/



    ```

4. Deploy compliance reports.

    >The compliance reports will be needed for one of a later lab, is cronjob in your cluster, you can change the schedule by edit it.

    ```bash
    kubectl apply -f demo/compliance-reports

    ```

5. Deploy global alerts.

    >The alerts will be explored in a later lab.

    ```bash
    kubectl create -f demo/alerts/
   
    ```

[Next -> Module 1-1](../modules/app-service-control.md)

[Previous -> Module 0-3](../modules/joining-gke-to-calico-cloud.md)

[Menu](../README.md)


