# Module 3-4: Enabling L7 visibility 

**Goal:** Enable L7/HTTP flow logs with Calico cloud.

Calico cloud not only can provide L3 flow logs, but also can provide L7 visibility without service mesh headache. 
For more details refer to [Configure L7 logs](https://docs.tigera.io/v3.7/visibility/elastic/l7/configure) documentaiton.

## Steps

1. In the namespace of the pod that you want to monitor, create a Kubernetes pull secret for accessing Calico Enterprise images. 
    ```bash
   kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
   grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
   kubectl apply --namespace=hipstershop -f -
   ```

2. Create the Envoy config with `envoy-config.yaml` in l7-visibility folder

    ```bash
    #Download the manifest file for L7 log collector daemonset.
    curl https://docs.tigera.io/v3.9/manifests/l7/daemonset/l7-collector-daemonset.yaml -O

    #Download the Envoy config.
    curl https://docs.tigera.io/v3.9/manifests/l7/daemonset/envoy-config.yaml -O

    #Create the Envoy config in calico-system namespace.
    kubectl create configmap envoy-config -n calico-system --from-file=envoy-config.yaml

    ```
    
3. Configure Felix for log data collection, we should patch it before.
    
    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent"}}'
    ```


4. Apply the customized(if needed) l7-collector-daemonset.yaml from Step 2 and ensure that l7-collector and envoy-proxy containers are in Running state.

   ```bash
   kubectl apply -f l7-collector-daemonset.yaml
   ```

5. Select traffic for L7 log collection

   ```bash
   #Annotate the services you wish to collect L7 logs as shown. Use hipstershop as example
   kubectl annotate svc --all -n hipstershop projectcalico.org/l7-logging=true
   ```


6. Test your installation
   ```bash
   kubectl label svc frontend-external app=frontend -n hipstershop 
   TEST_IP=$(kubectl -n hipstershop get svc  -l app=frontend  -ojsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
   curl $TEST_IP | grep http
   ```
  
   Now view the L7 logs in Kibana by selecting the tigera_secure_ee_l7 index pattern. You should see the relevant L7 data from your request recorded.    

[Next -> Module 4-1](../modules/compliance-reports.md)

[Previous -> Module 3-1](../modules/dynamic-packet-capture.md)

[Menu](../README.md)

