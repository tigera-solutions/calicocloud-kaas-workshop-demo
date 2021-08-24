# Module 3-4: Enabling L7 visibility 

**Goal:** Enable L7/HTTP flow logs with Calico cloud.

Calico cloud not only can provide L3 flow logs, but also can provide L7 visibility without service mesh headache. 
For more details refer to [Configure L7 logs](https://docs.tigera.io/v3.7/visibility/elastic/l7/configure) documentaiton.

## Steps

1. Create the Envoy config with `envoy-config.yaml` in l7-visibility folder

    ```bash
    # create configmap
    kubectl create configmap envoy-config -n hipstershop --from-file=demo/l7-visibility/envoy-config.yaml
    ```
    
2. Configure Felix for log data collection, we should patch it before.
    
    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent"}}'
    ```


3. Install the envoy log collector.
   ```bash
   kubectl patch deployment adservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)" 
   kubectl patch deployment cartservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment checkoutservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment currencyservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment emailservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment frontend -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment loadgenerator -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment paymentservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment productcatalogservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment recommendationservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment redis-cart -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   kubectl patch deployment shippingservice -n hipstershop --patch "$(cat demo/l7-visibility/patch-envoy.yaml)"
   ```


    

4. Test your installation
   ```bash
   kubectl label svc frontend-external app=frontend -n hipstershop 
   TEST_IP=$(kubectl -n hipstershop get svc  -l app=frontend  -ojsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')
   curl $TEST_IP | grep http
   ``'
  
   Now view the L7 logs in Kibana by selecting the tigera_secure_ee_l7 index pattern. You should see the relevant L7 data from your request recorded.    

[Next -> Module 4-1](../modules/compliance-reports.md)

[Previous -> Module 3-1](../modules/dynamic-packet-capture.md)

[Menu](../README.md)

