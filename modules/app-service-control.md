# East-West controls: App service control

**Goal:** Leverage network policies to segment connections within Kubernetes cluster.

## Steps

1. Test connectivity between application components and across application stacks. All of these tests should succeed as there are no policies in place.

    a. Test connectivity between workloads within each namespace, use `dev` and `hipstershop` namespaces as example

    ```bash
    # test connectivity within dev namespace, the expected result is "HTTP/1.1 200 OK"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://nginx-svc 2>/dev/null | grep -i http'
    ```

    ```bash
    # test connectivity within hipstershop namespace in 8080 port
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') \
    -c server -- sh -c 'nc -zv recommendationservice 8080'
    ```

    b. Test connectivity across namespaces `dev/centos`and `hipstershop/frontend`.
    ```bash
    # test connectivity from dev namespace to hipstershop namespace, the expected result is "HTTP/1.1 200 OK"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'

    ```

    c. Test connectivity from each namespace `dev` and `default` to the Internet.

    ```bash
    # test connectivity from dev namespace to the Internet, the expected result is "HTTP/1.1 200 OK"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http'

    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http'
    
    ```

2. Apply staged `default-deny` policy.

    >Staged `default-deny` policy is a good way of catching any traffic that is not explicitly allowed by a policy without explicitly blocking it.

    ```bash
    kubectl apply -f demo/app-control/staged.default-deny.yaml
    ```

    You should be able to view the potential affect of the staged `default-deny` policy if you navigate to the `Dashboard` view in the Enterprise Manager UI and look at the `Packets by Policy` histogram.

    ```bash
    # make a request across namespaces and view Packets by Policy histogram, the expected result is "HTTP/1.1 200 OK"
    for i in {1..5}; do kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'; sleep 2; done
    ```

    >The staged policy does not affect the traffic directly but allows you to view the policy impact if it were to be enforced. You can see the deny traffic in staged policy. 

3. Apply network policies to your application with explicity allow and deny control.

    ```bash
    # deploy policy to control centos ingress and egress
    kubectl apply -f demo/app-control/default.centos.yaml

    ```


4. Test connectivity with policies in place.

    a. The only connections between the components within namespaces `dev` are from `centos` to `nginx`, which should be allowed as configured by the policies.

    ```bash
    # test connectivity within dev namespace, the expected result is "HTTP/1.1 200 OK"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://nginx-svc 2>/dev/null | grep -i http'
    ```

    The connections within namespace `hipstershop` should be allowed as usual.

    ```bash
    # test connectivity within hipstershop namespace in 8080 port
    kubectl -n hipstershop exec -it $(kubectl -n hipstershop get po -l app=frontend -ojsonpath='{.items[0].metadata.name}') \
    -c server -- sh -c 'nc -zv recommendationservice 8080'
    ```

    b. The connections across `dev/centos` pod and `hipstershop/frontend` pod should be blocked by the application policy.
    ```bash
    # test connectivity from dev namespace to hipstershop namespace, the expected result is "command terminated with exit code 1"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'

    ```

    c. Test connectivity from each namespace `dev` and `default` to the Internet. 

    ```bash
    # test connectivity from dev namespace to the Internet, the expected result is "command terminated with exit code 1"
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://www.google.com 2>/dev/null | grep -i http'
    ```

    ```bash
    # test connectivity from default namespace to the Internet, the expected result is "HTTP/1.1 200 OK"
    kubectl exec -it curl-demo -- sh -c 'curl -m3 -sI www.google.com 2>/dev/null | grep -i http'
    ```


5. Implement explicitic policy to allow egress access from a workload in one namespace/pod, e.g. `dev/centos`, to `hipstershop/frontend`.

    
    a. Deploy egress policy between two namespaces `dev` and `hipstershop`.

    ```bash
    kubectl apply -f demo/app-control/platform.centos-to-frontend.yaml
    ```

    b. Test connectivity between `dev/centos` pod and `hipstershop/frontend` service again, should be allowed now.

    ```bash
    kubectl -n dev exec -t centos -- sh -c 'curl -m3 -sI http://frontend.hipstershop 2>/dev/null | grep -i http'
    #output is HTTP/1.1 200 OK
    ```

    The access should be allowed once the egress policy is in place.


> Now as we have proper policies in place, we can play around with `staged.default-deny` policy as a beta version to test your E-W control, for examle adding `default` namespace and curl the google, you should be able to see the deny flow under `staged.default-deny` policy, once you are happy with the results, you can using the `Policies Board` view in the Enterirpse Manager UI to enforce it as `default-deny` policy manifest.


[Next -> Pod Microsegmentation](../modules/pod-microsegmentation.md)

[Menu](../README.md)



