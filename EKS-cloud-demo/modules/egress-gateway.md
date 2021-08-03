# Module 6-2: North-South Controls-Egress Gateway

Refer to the documentation to [enable and configure Egress Gateways (EG)](https://docs.tigera.io/networking/egress-gateway) capability.

```bash
# enable Egress Gateways (EG) per pod and namespace
kubectl patch felixconfiguration.p default --type='merge' -p '{"spec":{"egressIPSupport":"EnabledPerNamespaceOrPerPod"}}'

# deploy EG IPPool
kubectl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: egress-ippool-1
spec:
  cidr: 10.198.178.188/31
  blockSize: 31
  natOutgoing: true
  nodeSelector: "!all()"
EOF

# copy Tigera pull secret into namespace where EG pods will run
# if EG namespace is other than "default", change namespace in command below and in the 50-egress-gateways/egress-gateways.yaml manifest
EG_NAMESPACE="bt-web-egress"
kubectl create ns $EG_NAMESPACE
kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
   grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
   kubectl apply --namespace=$EG_NAMESPACE -f -

# deploy egress gateway
kubectl apply -f egress-gateways/egress-gateways.yaml

# annotate client service namespace with EG label
CLIENT_NAMESPACE="dev"
kubectl annotate ns $CLIENT_NAMESPACE egress.projectcalico.org/selector='egress-code == "red"'
# if EG pods run in a dedicate namespace, annotate client pod namespace with EG pod namespace name
kubectl annotate ns $CLIENT_NAMESPACE egress.projectcalico.org/namespaceSelector="projectcalico.org/name == \"$EG_NAMESPACE\""
# view annotations
kubectl describe ns $CLIENT_NAMESPACE | grep -i -A5 annotation

# OR annotate client pod with EG label
CLIENT_NAMESPACE="dev"
kubectl -n $CLIENT_NAMESPACE annotate pod $(kubectl -n $CLIENT_NAMESPACE get pod -l app=netshoot -ojsonpath='{.items[0].metadata.name}') egress.projectcalico.org/selector='egress-code == "red"'
# if EG pods run in a dedicate namespace, annotate client pod namespace with EG pod namespace name
kubectl -n $CLIENT_NAMESPACE annotate pod $(kubectl -n $CLIENT_NAMESPACE get pod -l app=netshoot -ojsonpath='{.items[0].metadata.name}') egress.projectcalico.org/namespaceSelector="projectcalico.org/name == \"$EG_NAMESPACE\""
# view annotations
kubectl -n $CLIENT_NAMESPACE describe pod $(kubectl -n $CLIENT_NAMESPACE get pod -l app=netshoot -ojsonpath='{.items[0].metadata.name}') | grep -i -A5 annotation
```

To test egress gateway, run `ping` or `curl` command to a compute resource or HTTP service outside of the cluster and inspect the IP of the request.

If you want to disable the egress gateway, then remove the annotations

```bash
# example to remove annotations from the namespace
CLIENT_NAMESPACE="dev"
kubectl annotate ns $CLIENT_NAMESPACE egress.projectcalico.org/selector-
kubectl annotate ns $CLIENT_NAMESPACE egress.projectcalico.org/namespaceSelector-

# example to remove annotations from the pod
CLIENT_NAMESPACE="dev"
kubectl -n $CLIENT_NAMESPACE annotate pod $(kubectl -n $CLIENT_NAMESPACE get pod -l app=netshoot -ojsonpath='{.items[0].metadata.name}') egress.projectcalico.org/selector-
kubectl -n $CLIENT_NAMESPACE annotate pod $(kubectl -n $CLIENT_NAMESPACE get pod -l app=netshoot -ojsonpath='{.items[0].metadata.name}') egress.projectcalico.org/namespaceSelector-
```

[Next -> Module 7-1](../modules/firewall-integration.md)

[Previous -> Module 6-1](../modules/egress-access-controls.md)

[Menu](../README.md)