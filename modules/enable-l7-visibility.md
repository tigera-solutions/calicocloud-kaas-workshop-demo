# # Observability: L7 Visibility 

**Goal:** Enable L7/HTTP flow logs in hipstershop with Calico cloud.

Calico cloud not only can provide L3 flow logs, but also can provide L7 visibility without service mesh headache. 
For more details refer to [Configure L7 logs](https://docs.tigera.io/v3.9/visibility/elastic/l7/configure) documentaiton.

## Steps

1. Configure Felix for log data collection 

    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent"}}'
    ```

2.  Prepare scripts for deploying L7 Log Collector DaemonSet

    ```bash
    curl https://docs.tigera.io/v3.10/manifests/l7/daemonset/l7-collector-daemonset.yaml -O

    curl https://docs.tigera.io/v3.10/manifests/l7/daemonset/envoy-config.yaml -O

    ```
3.  Create the Envoy config in `calico-system` namespace
    ```bash
    kubectl create configmap envoy-config -n calico-system --from-file=envoy-config.yaml
    ```

4.  Enable L7 log collection daemonset mode in Felix by setting Felix configuration variable tproxyMode to Enabled or by setting felix environment variable FELIX_TPROXYMODE to Enabled.
    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"tproxyMode":"Enabled"}}'
    ```

5. Apply l7-collector-daemonset.yaml and ensure that l7-collector and envoy-proxy containers are in Running state. You can also edit the `LOG_LEVEL` with different options: Trace, Debug, Info, Warning, Error, Fatal and Panic. 

   ```bash
   kubectl apply -f l7-collector-daemonset.yaml
   ```

6. Select traffic for L7 log collection

   ```bash
   #Annotate the services you wish to collect L7 logs as shown. Use hipstershop as example
   kubectl annotate svc --all -n hipstershop projectcalico.org/l7-logging=true
   ```
   
7. *[Optional]* restart the pods in `hipstershop` if you want to see l7 logs right away.    

    ```bash
    kubectl delete pods --all -n hipstershop
    ``` 

  Now view the L7 logs in Kibana by selecting the tigera_secure_ee_l7 index pattern. You should also see the relevant HTTP log from service graph.    

   ![service graph HTTP log](../img/service-graph-l7.png)
   

[Next -> Dynamic packet capture](../modules/dynamic-packet-capture.md) 

[Menu](../README.md)

