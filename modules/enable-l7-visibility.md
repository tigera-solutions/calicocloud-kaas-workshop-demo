# # Observability: L7 Visibility 

**Goal:** Enable L7/HTTP flow logs in hipstershop with Calico cloud.

Calico cloud not only can provide L3 flow logs, but also can provide L7 visibility without service mesh headache. 
For more details refer to [Configure L7 logs](https://docs.tigera.io/v3.9/visibility/elastic/l7/configure) documentaiton.

## Steps


1. In the namespace of the pod that you want to monitor, create a Kubernetes pull secret for accessing Calico Enterprise images. 
    ```bash
   kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
   grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
   kubectl apply --namespace=hipstershop -f -
   ```

2. Create the Envoy configmap with `envoy-config.yaml` in l7-visibility folder

    ```bash
    
    #Create the Envoy config in calico-system namespace.
    kubectl create configmap envoy-config -n calico-system --from-file=demo/l7-visibility/envoy-config.yaml

    ```
    
3. Configure Felix for log data collection, we should already patch it before.
    
    ```bash
    
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent"}}'
    ```


4. Apply l7-collector-daemonset.yaml and ensure that l7-collector and envoy-proxy containers are in Running state. You can also edit the `LOG_LEVEL` with different options: Trace, Debug, Info, Warning, Error, Fatal and Panic. Enable L7 log collection daemonset mode in Felix by setting Felix configuration variable tproxyMode to Enabled or by setting felix environment variable FELIX_TPROXYMODE to Enabled.

   ```bash
   kubectl apply -f demo/l7-visibility/l7-collector-daemonset.yaml

   kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"tproxyMode":"Enabled"}}'

   ```

5. Select traffic for L7 log collection

   ```bash
   #Annotate the services you wish to collect L7 logs as shown. Use hipstershop as example
   kubectl annotate svc --all -n hipstershop projectcalico.org/l7-logging=true
   ```
   
  Now view the L7 logs in Kibana by selecting the tigera_secure_ee_l7 index pattern. You should also see the relevant HTTP log from service graph.    

[Next -> Dynamic packet capture](../modules/dynamic-packet-capture.md) 

[Menu](../README.md)

