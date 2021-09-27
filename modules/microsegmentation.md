# Module 1-2: East-West controls-Microsegmentation

**Goal:** Configure a DevOps tier for our application which has a zone-based architecture.

## Steps



1. Implement policy for storefront app. 

   

    a. Create logging policy for storefront application in platform tier 
    ```bash
    ###apply the logging policy
    kubectl apply -f demo/101-security-controls/platform-team.allow-logging.yaml
    ```

    
    b. Create zone-based policy for storefront application in dev-ops tier
    ```bash
    ###apply the zone-based policy
    kubectl apply -f demo/101-security-controls/storefront-FirewallZonesPolicies.yaml
    ```

   
2. Confirm the connection from microservice2 to backend are been allowed from flow visualization.


3. Change the lable of pod mircoservice2 and see the deny traffic in flow visualization. 

    ```bash

    #remove the label 
    kubectl -n storefront label pod $(kubectl -n storefront get po -l app=microservice2 -ojsonpath='{.items[0].metadata.name}') fw-zone-

    #add the label as dmz zone
    kubectl -n storefront label pod $(kubectl -n storefront get po -l app=microservice2 -ojsonpath='{.items[0].metadata.name}')  fw-zone=dmz
    ```

4. Confirm the connection from microservice2 to backend are been denied.


5. Reverse the lable of pod mircoservice2 with overwrite. 
   
   ```bash
    kubectl -n storefront label pod $(kubectl -n storefront get po -l app=microservice2 -ojsonpath='{.items[0].metadata.name}') fw-zone=trusted --overwrite
    ```



[Next -> Module 1-3](../modules/host-protection.md)

[Previous -> Module 1-1](../modules/app-service-control.md)

[Menu](../README.md)