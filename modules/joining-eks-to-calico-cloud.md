# Module 0-3: Joining EKS cluster to Calico Cloud

**Goal:** Join EKS cluster to Calico Cloud management plane.

>In order to complete this module, you must have [Calico Cloud trial account](https://www.tigera.io/tigera-products/calico-cloud/).

## Steps

1. Join EKS cluster to Calico Cloud management plane.

    Use Calico Cloud install script provided in the welcome email for Calico Cloud trial account.

    ```bash
    # script should look similar to this
    curl https://installer.calicocloud.io/xxxxxx_yyyyyyy-saay-management_install.sh | bash
    ```

    Joining the cluster to Calico Cloud can take a few minutes. Wait for the installation script to finish before you proceed to the next step.

    You should see the output similar to this:

    ```text
    [INFO] Checking for installed CNI Plugin
    [INFO] Deploying CRDs and Tigera Operator
    [INFO] Creating Tigera Pull Secret
    [INFO] Tigera Operator is Available
    [INFO] Adding Installation CR for Enterprise install
    [WAIT] Tigera calico is Progressing
    [INFO] Tigera Calico is Available
    [INFO] Deploying Tigera Prometheus Operator
    podmonitors.monitoring.coreos.com
    [INFO] Deploying CRs for Managed Cluster
    [INFO] Tigera Apiserver is Available
    [INFO] Generate New Cluster Registration Manifest
    [INFO] Creating connection
    [INFO] All Tigera Components are Available
    [INFO] Securing Install
    .....
    ```
  

    ```bash
    # output once your cluster join the calico cloud
    Install Successful

    Your Connected Cluster Name is r69bq5ox-management-managed-7b0970266ef69f99ae83f6e84f82425a-gr7-us-east-1-eks-amazonaws-com
    ```
    Set the Calico Cluster Name as a variable to use later in this workshop. The Cluster Name can also be obtained from the Calico Cloud Web UI at a later date. For the example above `CALICOCLUSTERNAME` should be set to __r69bq5ox-management-managed-7b0970266ef69f99ae83f6e84f82425a-gr7-us-east-1-eks-amazonaws-com__
    
    ```bash
    export CALICOCLUSTERNAME=<Cluster Name>
    echo export CALICOCLUSTERNAME=$CALICOCLUSTERNAME >> ~/.bashrc
    ```
    
    In calico cloud management UI, you can see your own aks cluster added in "managed cluster", you can also confirm by
    ```bash
    kubectl get tigerastatus
    ```
    
    ```bash
    #make sure all customer resources are "AVAILABLE=True" 
    NAME                            AVAILABLE   PROGRESSING   DEGRADED   SINCE
    apiserver                       True        False         False      5m38s
    calico                          True        False         False      4m44s
    compliance                      True        False         False      4m34s
    intrusion-detection             True        False         False      4m49s
    log-collector                   True        False         False      4m19s
    management-cluster-connection   True        False         False      4m54s
    ```
    
4. Navigating the Calico Cloud UI

    Once the cluster has successfully connected to Calico Cloud you can review the cluster status in the UI. Click on `Managed Clusters` from the left side menu and look for the `connected` status of your cluster. You will also see a `Tigera-labs` cluster for demo purposes. Ensure you are in the correct cluster context by clicking the `Cluster` dropdown in the top right corner. This will list the connected clusters. Click on your cluster to switch context otherwise the current cluster context is in *bold* font.
    
    ![cluster-selection](../img/cluster-selection.png)

5. Configure log aggregation and flush intervals.

    ```bash
    kubectl patch felixconfiguration.p default -p '{"spec":{"flowLogsFlushInterval":"10s"}}'
    kubectl patch felixconfiguration.p default -p '{"spec":{"dnsLogsFlushInterval":"10s"}}'
    kubectl patch felixconfiguration.p default -p '{"spec":{"flowLogsFileAggregationKindForAllowed":1}}'
    ```

3. Configure Felix for log data collection.

    >[Felix](https://docs.tigera.io/reference/architecture/overview#felix) is one of Calico components that is responsible for configuring routes, ACLs, and anything else required on the host to provide desired connectivity for the endpoints on that host.

    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent","l7LogsFileEnabled":true}}'
    ```
4. Configure Felix for enabling TCP socket stats

    >Calico Enterprise can collect additional TCP socket statistics. While this feature is available in both iptables and eBPF dataplane modes, it uses eBPF to collect the statistics. Therefore it requires a recent Linux kernel (at least v5.3.0/v4.18.0-193 for RHEL).

    ```bash
    kubectl patch felixconfiguration default -p '{"spec":{"flowLogsCollectTcpStats":true}}'

    ```



[Next -> Module 0-4](../modules/configuring-demo-apps.md)

[Previous -> Module 0-2](../modules/creating-eks-cluster.md)

[Menu](../README.md)
