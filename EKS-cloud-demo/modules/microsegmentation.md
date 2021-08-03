# Module 5-2: East-West controls-Microsegmentation

**Goal:** Configure a DevOps tier for our application which has a zone-based architecture.

## Steps



1. Implement tiered policy for devops team. 

   

    a. Create storefront application in devops tier, including implement Zone-Based policy for devops team 

    ```bash
    kubectl apply -f demo/storefront-stack
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



[Next -> Module 5-3](../modules/host-protection.md)

[Previous -> Module 5-1](../modules/app-service-control.md)

[Menu](../modules/README.md)