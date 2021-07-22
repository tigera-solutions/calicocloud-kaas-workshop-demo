# Module 6: East-West controls-Microsegmentation

**Goal:** Configure a DevOps tier for our application which has a zone-based architecture.

## Steps



1. Implement tiered policy for devops team. 

    a. Apply a tier for devops

    ```bash
    # deploy devops tier policy
    kubectl apply -f demo/tiers/devops-tier.yaml

    ```

    b. Create storefront application in devops tier.

    ```bash
    kubectl apply -f demo/storefront
    ```

    c. Implement Zone-Based policy for devops team 

    ```bash
    kkubectl apply -f demo/10-security-controls/FirewallZonesPolicies.yaml

    ```
2. Confirm the connection from microservice2 to backend are been allowed from flow visualization.


3. Change the lable of pod mircoservice2 and see the deny traffic in flow visualization. 

    ```bash
    #remove the label 
    kubectl -n storefront label pod microservice2-7f7f575784-g9926 fw-zone-

    #add the label as dmz zone
    kubectl -n storefront label pod microservice2-7f7f575784-g9926 fw-zone=dmz
    ```

4. Confirm the connection from microservice2 to backend are been denied.


5. Reverse the lable of pod mircoservice2. 
   
   ```bash
    #remove the label 
    kubectl -n storefront label pod microservice2-7f7f575784-g9926 fw-zone-

    #add the label as trusted zone
    kubectl -n storefront label pod microservice2-7f7f575784-g9926 fw-zone=trusted
    ```



[Next -> Module 7](../modules/host-protection.md)
