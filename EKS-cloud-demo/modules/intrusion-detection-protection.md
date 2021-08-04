# Module 8-2: Compliance and Security-Intrusion Detection and Prevention

**Goal:** Use global alerts to notify security and operations teams about unsanctioned or suspicious activity.

## Steps 1: Review and trigger embedded alerts

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

   #curl example.com couple times to trigger the dns aler
   kubectl exec -it nginx -n storefront -- sh -c 'curl -m3 -sI2 http://www.example.com 2>/dev/null | grep -i http'

   #curl nginx in dev ns to trigger the flows alerts
   kubectl exec -it nginx -n storefront -- sh -c 'curl -m3 -sI2 http://nginx-svc.dev 2>/dev/null | grep -i http'
   ```

4. Trigger the embedded alerts for threatfeeds.

    Calico offers `GlobalThreatfeed` resource to prevent known bad actors from accessing Kubernetes pods, including embedded alerts for threatfeeds.

    ```bash
    # try to ping any of the IPs in from the feodo tracker list, use 1.234.20.244 as example IP if your jq doesn't work
    IP=$(kubectl get globalnetworkset threatfeed.feodo-tracker -ojson | jq .spec.nets[0] | sed -e 's/^"//' -e 's/"$//' -e 's/\/32//')
    kubectl -n dev exec -t netshoot -- sh -c "ping -c1 $IP"
    ```

5. Confirm the embedded alerts for threatfeeds have been trigger.


6. Change one of the globalnetworksets from UI and confirm it will trigger alert by pre-defined globalalert policy



## Steps 2: Honeypod Threat Detection

Calico offers [Honeypod](https://docs.tigera.io/threat/honeypod/) capability which is based upon the same principles as traditional honeypots. Calico is able to detect traffic which probes the Honeypod resources which can be an indicator of compromise. Refer to the [official honeypod configuration documentation](https://docs.tigera.io/threat/honeypod/honeypods) for more details.

1. Configure honeypod namespace and Alerts for SSH detection

    ```bash
    # create dedicated namespace and RBAC for honeypods
    kubectl apply -f https://docs.tigera.io/manifests/threatdef/honeypod/common.yaml
    
    # add tigera pull secret to the namespace. We clone the existing secret from the calico-system NameSpace
    kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
    grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
    kubectl apply --namespace=tigera-internal -f -
    ```

2. Deploy sample honeypods

    ```bash
    # expose pod IP to test IP enumeration use case
    kubectl apply -f https://docs.tigera.io/manifests/threatdef/honeypod/ip-enum.yaml

    # expose nginx service that can be reached via ClusterIP or DNS
    kubectl apply -f https://docs.tigera.io/manifests/threatdef/honeypod/expose-svc.yaml 

    # expose MySQL service
    kubectl apply -f https://docs.tigera.io/manifests/threatdef/honeypod/vuln-svc.yaml 
    ```
3. Verify newly deployed pods are running

    ```bash
    kubectl get pods -n tigera-internal
    ```
    >Output should resemble:
    
    ```bash
    kubectl get pods -n tigera-internal
    
    NAME                                         READY   STATUS    RESTARTS   AGE
    tigera-internal-app-ks9s4                    1/1     Running   0          7h22m
    tigera-internal-app-lfnzz                    1/1     Running   0          7h22m
    tigera-internal-app-xfl57                    1/1     Running   0          7h22m
    tigera-internal-dashboard-5779bcb9bf-h8rdl   1/1     Running   0          19h
    tigera-internal-db-58547d8655-znhkj          1/1     Running   0          19h
    ```
4. Verify honeypod alerts are deployed

    ```bash
    kubectl get globalalerts | grep -i honeypod
    ```
    >Output should resemble:

    ```bash
    kubectl get globalalerts | grep -i honeypod
    honeypod.fake.svc         2021-07-22T15:33:37Z
    honeypod.ip.enum          2021-07-21T18:34:49Z
    honeypod.network.ssh      2021-07-21T18:30:47Z
    honeypod.port.scan        2021-07-21T18:34:50Z
    honeypod.vuln.svc         2021-07-21T18:36:34Z
    ```
5. Test honeypod use cases

    - Ping exposed Honeypod IP

    ```bash
    POD_IP=$(kubectl -n tigera-internal get po --selector app=tigera-internal-app -o jsonpath='{.items[0].status.podIP}')
    kubectl -n dev exec netshoot -- ping -c5 $POD_IP
    ```
    >Output should resemble:    
    
    ```bash
    kubectl -n dev exec netshoot -- ping -c5 $POD_IP
    PING 10.240.0.74 (10.240.0.74) 56(84) bytes of data.
    64 bytes from 10.240.0.74: icmp_seq=1 ttl=63 time=0.103 ms
    64 bytes from 10.240.0.74: icmp_seq=2 ttl=63 time=0.065 ms
    64 bytes from 10.240.0.74: icmp_seq=3 ttl=63 time=0.059 ms
    64 bytes from 10.240.0.74: icmp_seq=4 ttl=63 time=0.050 ms
    64 bytes from 10.240.0.74: icmp_seq=5 ttl=63 time=0.075 ms

    --- 10.240.0.74 ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4094ms
    rtt min/avg/max/mdev = 0.050/0.070/0.103/0.018 ms
    ```
    <br>
    
    - curl HoneyPod nginx service
    ```bash
    SVC_URL=$(kubectl -n tigera-internal get svc -l app=tigera-dashboard-internal-debug -ojsonpath='{.items[0].metadata.name}')
    SVC_PORT=$(kubectl -n tigera-internal get svc -l app=tigera-dashboard-internal-debug -ojsonpath='{.items[0].spec.ports[0].port}')
    kubectl -n dev exec netshoot -- curl -m3 -skI $SVC_URL.tigera-internal:$SVC_PORT | grep -i http
    ```
    >Output should resemble: 
    ```bash
    kubectl -n dev exec netshoot -- curl -m3 -skI $SVC_URL.tigera-internal:$SVC_PORT
    HTTP/1.1 200 OK
    Server: nginx/1.16.1
    Date: Fri, 23 Jul 2021 21:32:31 GMT
    Content-Type: text/html
    Content-Length: 112
    Last-Modified: Mon, 30 Dec 2019 17:35:18 GMT
    Connection: keep-alive
    ETag: "5e0a3556-70"
    Accept-Ranges: bytes
    ```
    <br>
    
    - Query HoneyPod MySQL service
    ```bash
    SVC_URL=$(kubectl -n tigera-internal get svc -l app=tigera-internal-backend -ojsonpath='{.items[0].metadata.name}')
    SVC_PORT=$(kubectl -n tigera-internal get svc -l app=tigera-internal-backend -ojsonpath='{.items[0].spec.ports[0].port}')
    kubectl -n dev exec netshoot -- nc -zv $SVC_URL.tigera-internal $SVC_PORT
    ```
    >Output should resemble
    ```bash
    kubectl -n dev exec netshoot -- nc -zv $SVC_URL.tigera-internal $SVC_PORT
    Connection to tigera-internal-backend.tigera-internal 3306 port [tcp/mysql] succeeded!
    ```

Head to `Alerts` view in the Enterprise Manager UI to view the related alerts. Note the alerts can take a few minutes to generate. 

<img src="../img/honeypod-threat-alert.png" alt="honeypod-threat-alert" width="100%"/>

    
## Steps 3: Introducing a malicious rogue pod to the cluster of storefront, and quarantine it later.

1. Introducing a malicious rogue pod
```bash
kubectl apply -f demo/attacker-rogue/rogue.yaml

#confirm the rogue from service graph
```
2. deploy the quarantine networkpolicy to protect your cluster

```bash
kubectl apply -f demo/10-security-controls/security-team.quarantine.yaml

#confirm the quarantine policy from policy dashboard
```

3. quarantine the rogue pod

```bash
./demo/attacker-rogue/QuarantineRogue.sh

#confirm the rogue been quarantined from policy dashboard
```

4. delete the rogue pod

```bash
kubectl delete -f demo/attacker-rogue/rogue.yaml

```

## Steps 4: Anomaly Detection

[Next -> Module 8-3](../modules/encryption.md)

[Previous -> Module 8-1](../modules/compliance-reports.md)

[Menu](../README.md)