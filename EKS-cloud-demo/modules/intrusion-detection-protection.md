# Module 8-2: Compliance and Security-Intrusion Detection and Prevention

**Goal:** Use global alerts to notify security and operations teams about unsanctioned or suspicious activity.

## Steps

1. Review alerts manifests.

    Navigate to `demo/alerts` and review YAML manifests that represent alerts definitions. Each file containes an alert template and alert definition. Alerts templates can be used to quickly create an alert definition in the UI.


2. View triggered alerts.

    >We implemented alerts in one of the first labs in order to see how our activity can trigger them.

    Open `Alerts` view to see all triggered alerts in the cluster. Review the generated alerts.

    ![alerts view](../img/alerts-view.png)

    You can also review the alerts configuration and templates by navigating to alerts configuration in the top right corner.

3. Trigger an alert by curl google from namespace storefront.
   
   ```bash
   #create nginx pod in storefront
   kubectl run nginx -n storefront --port=80 --image=nginx

   #curl google couple times to trigger the dns aler
   kubectl exec -it nginx -n storefront -- sh -c 'curl -m3 -sI2 http://www.google.com 2>/dev/null | grep -i http'
   ```

4. Trigger the embedded alerts for threatfeeds.

    Calico offers `GlobalThreatfeed` resource to prevent known bad actors from accessing Kubernetes pods, including embedded alerts for threatfeeds.

    ```bash
    # try to ping any of the IPs in from the feodo tracker list
    IP=$(kubectl get globalnetworkset threatfeed.feodo-tracker -ojson | jq .spec.nets[0] | sed -e 's/^"//' -e 's/"$//' -e 's/\/32//')
    kubectl -n dev exec -t centos -- sh -c "ping -c1 $IP"
    ```

5. Confirm the embedded alerts for threatfeeds have been trigger.


6. Change one of the globalnetworksets from UI and confirm it will trigger alert by pre-defined globalalert policy




[Next -> Module 8-3](../modules/encryption.md)

[Previous -> Module 8-1](../modules/compliance-reports.md)

[Menu](../README.md)