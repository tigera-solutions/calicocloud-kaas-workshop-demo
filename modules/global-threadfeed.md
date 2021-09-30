# North-South Controls: Global Threadfeed

**Goal:** Configure egress access control for outside threadfeed policy so workloads within cluster are not allow to external networkset

## Steps

1. Protect workloads with GlobalThreatfeed from known bad actors.

    Calicocloud offers [Global threat feed](https://docs.tigera.io/reference/resources/globalthreatfeed) resource to prevent known bad actors from accessing Kubernetes pods.

    ```bash
    kubectl get globalthreatfeeds
    ```

    ```bash
    NAME                           CREATED AT
    alienvault.domainthreatfeeds   2021-09-28T15:01:33Z
    alienvault.ipthreatfeeds       2021-09-28T15:01:33Z
    ```

    You can get these domain/ip list from yaml file, the url would be:

    ```bash
    kubectl get globalthreatfeeds alienvault.domainthreatfeeds -ojson | jq -r '.spec.pull.http.url'

    kubectl get globalthreatfeeds alienvault.ipthreatfeeds -ojson | jq -r '.spec.pull.http.url'
    ```

    ```bash
    https://installer.calicocloud.io/feeds/v1/domains

    https://installer.calicocloud.io/feeds/v1/ips
    ```


    ```bash
    # deploy feodo and snort threatfeeds
    kubectl apply -f demo/threatfeeds/feodo-tracker.yaml
    kubectl apply -f demo/threatfeeds/snort-ip-block-list.yaml
    kubectl apply -f demo/threatfeeds/feodo-block-policy.yaml

    # Confirm and check the tracker threatfeed
    kubectl get globalthreatfeeds 

    ```

    ```bash
    NAME                           CREATED AT
    alienvault.domainthreatfeeds   2021-09-28T15:01:33Z
    alienvault.ipthreatfeeds       2021-09-28T15:01:33Z
    feodo-tracker                  2021-09-28T17:32:13Z
    snort-ip-block-list            2021-09-28T17:35:23Z
    ```
    
2. Generate alerts by accessing the IP from `feodo-tracker` list. 

    ```bash
    # try to ping any of the IPs in from the feodo tracker list.
    FIP=$(kubectl get globalnetworkset threatfeed.feodo-tracker -ojson | jq -r '.spec.nets[0]' | sed -e 's/^"//' -e 's/"$//' -e 's/\/32//')
    kubectl -n dev exec -t netshoot -- sh -c "ping -c1 $FIP"
    ```

3. Add more threatfeeds labels into networkset and prevent your cluster from them.

    ```bash
    # deploy embargo and other threatfeeds
    kubectl apply -f demo/threatfeeds/embargo.networkset.yaml
    kubectl apply -f demo/threatfeeds/tor-bulk-exit-list.yaml

    kubectl apply -f demo/threatfeeds/security.block-threadfeed.yaml
    kubectl apply -f demo/threatfeeds/security.embargo-countries.yaml

    # Confirm and check the tracker threatfeed
    kubectl get globalthreatfeeds 

    ```

4. Generate alerts by accessing the IP from `tor-bulk-exit` list. 

    ```bash
    # try to ping any of the IPs in from the tor-bulk-exit list.
    TIP=$(kubectl get globalnetworkset threatfeed.tor-bulk-exit-list -ojson | jq -r '.spec.nets[0]' | sed -e 's/^"//' -e 's/"$//' -e 's/\/32//')
    kubectl -n dev exec -t netshoot -- sh -c "ping -c1 $TIP"
    ```

[Next -> Manager UI](../modules/manager-ui.md)

[Menu](../README.md)