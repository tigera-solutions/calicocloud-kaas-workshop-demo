# Module 2-1: North-South Controls-Egress access controls

**Goal:** Configure egress access control for specific workloads so they are allow to external DNS domain, and configure block-threadfeed policy so workloads within cluster are not allow to external networkset

## Steps

1. Implement DNS policy to allow the external endpoint access from a specific workload, e.g. `dev/centos`.

    a. Apply a policy to allow access to `api.twilio.com` endpoint using DNS rule.

    ```bash
    # deploy dns policy
    kubectl apply -f demo/egress-access-controls/dns-policy.yaml

    # test egress access to api.twilio.com
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://api.twilio.com 2>/dev/null | grep -i http'
    # test egress access to www.google.com
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://www.google.com 2>/dev/null | grep -i http'
    ```

    Access to the `api.twilio.com` endpoint should be allowed by the DNS policy and any other external endpoints like `www.google.com` should be denied. 

    b. Modify the policy to include `www.google.com` in dns policy and test egress access to www.google.com again.

    ```bash
    # test egress access to www.google.com again and it should be allowed.
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://www.google.com 2>/dev/null | grep -i http'
    ```


2.  Edit the policy to use a `NetworkSet` with DNS domain instead of inline DNS rule.

    a. Apply a policy to allow access to `api.twilio.com` endpoint using DNS policy.

    ```bash
    # deploy network set
    kubectl apply -f demo/egress-access-controls/netset.external-apis.yaml
    # deploy DNS policy using the network set
    kubectl apply -f demo/egress-access-controls/dns-policy.netset.yaml


    # test egress access to api.twilio.com
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://api.twilio.com 2>/dev/null | grep -i http'
    # test egress access to www.google.com
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://www.google.com 2>/dev/null | grep -i http'
    ```
    
    b. Modify the `NetworkSet` to include `www.google.com` in dns domain and test egress access to www.google.com again.

    ```bash
    # test egress access to www.google.com again and it should be allowed.
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -skI https://www.google.com 2>/dev/null | grep -i http'
    ```

3. Protect workloads with GlobalThreatfeed from known bad actors.

    Calico offers `GlobalThreatfeed` resource to prevent known bad actors from accessing Kubernetes pods.

    ```bash
    # deploy feodo and other tracker threatfeed
    kubectl apply -f demo/threatfeeds/


    # Confirm and check the tracker threatfeed
    kubectl get globalthreatfeeds 

    ```



[WIP][Next -> Module 2-2](../modules/egress-gateway.md)

[Previous -> Module 1-3](../modules/host-protection.md)

[Menu](../README.md)