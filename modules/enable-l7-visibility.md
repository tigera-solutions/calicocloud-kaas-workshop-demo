# # Observability: L7 Visibility 

**Goal:** Enable L7/HTTP flow logs in hipstershop with Calico cloud.

> Calico cloud not only can provide L3 flow logs, but also can provide L7 visibility without service mesh headache. For more details refer to [Configure L7 logs](https://docs.tigera.io/v3.11/visibility/elastic/l7/configure) documentaiton.

**Not supported:**

  Windows
  eBPF dataplane
  RKE clusters

## Steps

1. Configure Felix for log data collection 

    ```bash
    kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"policySyncPathPrefix":"/var/run/nodeagent"}}'
    ```

2. Apply application layer resource and ensure that l7-collector and envoy-proxy containers are in Running state. Refer to [Log Collection Spec](https://docs.tigera.io/v3.11/reference/installation/api#operator.tigera.io/v1.ApplicationLayer) with different options. 

   ```bash
   cat > configs/alr7.yaml << EOF
   apiVersion: operator.tigera.io/v1
   kind: ApplicationLayer
   metadata:
     name: tigera-secure
   spec:
     logCollection:
       collectLogs: Enabled
       logIntervalSeconds: 5
       logRequestsPerInterval: -1
   EOF
   ```

   ```bash
   kubectl create -f configs/alr7.yaml
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

  Now view the L7 logs in Kibana by selecting the `tigera_secure_ee_l7` index pattern. You should also see the relevant HTTP log from service graph.    

   ![service graph HTTP log](../img/service-graph-l7.png)

   
   

[Next -> Dynamic packet capture](../modules/dynamic-packet-capture.md) 

[Menu](../README.md)

