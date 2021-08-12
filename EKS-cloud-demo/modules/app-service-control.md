# Module 5-1: East-West controls: App service control

**Goal:** Leverage network policies to segment connections within Kubernetes cluster.

## Steps

1. Test connectivity between application components and across application stacks.

    a. Test connectivity between workloads within each namespace, use `dev` and `hipstershop` namespaces as example

    ```bash
    # test connectivity within dev namespace
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://nginx-svc 2>/dev/null | grep -i http'
    
    # test connectivity within hipstershop namespace in 3550 port
    
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') -c server -- sh -c 'nc -zv productcatalogservice 3550'

    # test connectivity within hipstershop namespace in 8080 port
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') -c server -- sh -c 'nc -zv recommendationservice 8080'
    ```

    b. Test connectivity across namespaces `dev` and `hipstershop`.

    ```bash
    # test connectivity from dev namespace to hipstershop namespace
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'

    # test connectivity from default namespace to dev namespace, this command will generate an alert as "[lateral movement"
    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI http://nginx-svc.dev 2>/dev/null | grep -i http'
    ```

    c. Test connectivity from each namespace `dev` and `default` to the Internet.

    ```bash
    # test connectivity from dev namespace to the Internet
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http'

    # test connectivity from default namespace to the Internet, this command will generate an alert as "dns"
    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI www.example.com 2>/dev/null | grep -i http'
    ```

    All of these tests should succeed if there are no policies in place to govern the traffic for `dev` and `default` namespaces.

2. Apply staged `hipstershop-dev-deny` policy.

    >Staged `hipstershop-dev-deny` policy is a good way of catching any traffic that is not explicitly allowed by a policy without explicitly blocking it.

    ```bash
    kubectl apply -f demo/101-security-controls/staged.hipstershop-dev-deny.yaml
    ```

    You should be able to view the potential affect of the staged `hipstershop-dev-deny` policy if you navigate to the `Dashboard` view in the Enterprise Manager UI and look at the `Packets by Policy` histogram.

    ```bash
    # make a request across namespaces and view Packets by Policy histogram
    for i in {1..5}; do kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'; sleep 2; done
    ```

    >The staged policy does not affect the traffic directly but allows you to view the policy impact if it were to be enforced.

3. Apply network policies to your application with explicity allow and deny control.

    ```bash
    # deploy dev policies
    kubectl apply -f demo/101-security-controls/dev-stack-policies.yaml

    # deploy boutiqueshop policies
    kubectl apply -f demo/101-security-controls/hipstershop-policies.yaml
    ```


4. Test connectivity with policies in place.

    a. The only connections between the components within each namespaces `dev` and `hipstershop` should be allowed as configured by the policies.

    ```bash
    # test connectivity within dev namespace
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://nginx-svc 2>/dev/null | grep -i http'

    # test connectivity within hipstershop namespace in 3550 port
    
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') -c server -- sh -c 'nc -zv productcatalogservice 3550'



    # test connectivity within hipstershop namespace in 8080 port
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') -c server -- sh -c 'nc -zv recommendationservice 8080'
    ```

    b. The connections across `dev/centos` pod and `hipstershop/frontend` pod should be blocked by the application policy.

    ```bash
    # test connectivity from dev namespace to hipstershop namespace

    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'

    # test connectivity from default namespace to dev namespace
    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI http://nginx-svc.dev 2>/dev/null | grep -i http'
  
    ```

    c. Test connectivity from `dev` namespace to the Internet, should be blocked by the configured policies.

    ```bash
    # test connectivity from dev namespace to the Internet
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http'

    ```

    d. Test connectivity from `default` namespace to the Internet, should be allowed right now.
    ```bash

    # test connectivity from default namespace to the Internet
    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI www.google.com 2>/dev/null | grep -i http'
    ```


5. Implement explicitic policy to allow egress access from a workload in one namespace/pod, e.g. `dev/centos`, to a service in another namespace, e.g. `hipstershop/frontend`.

    a. Test connectivity between `dev/centos` pod and `hipstershop/frontend` service, should be blocked now.
    ```bash
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'

    #output is command terminated with exit code 1
    ```
    
    b. Deploy egress policy.

    ```bash
    kubectl apply -f demo/101-security-controls/centos-to-frontend.yaml
    ```

    c. Test connectivity between `dev/centos` pod and `hipstershop/frontend` service again, should be allowed now.

    ```bash
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'
    #output is HTTP/1.1 200 OK
    ```

    The access should be allowed once the egress policy is in place.


> Now as we have proper policies in place, we can play around with `staged.hipstershop-dev-deny` policy as a beta version to test your E-W control, for examle adding `default` namespace and curl the google, you should be able to see the deny flow under `staged.hipstershop-dev-deny` policy, once you are happy with the results, you can using the `Policies Board` view in the Enterirpse Manager UI to enforce it as `hipstershop-dev-deny` policy manifest.

   


[Next -> Module 5-2](../modules/microsegmentation.md)

[Previous -> Module 4](../modules/configuring-demo-apps.md)

[Menu](../README.md)



