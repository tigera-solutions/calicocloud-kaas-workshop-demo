POD=$(kubectl get pod -l app=attacker-app -n storefront -o jsonpath="{.items[0].metadata.name}")
kubectl label pod $POD -n storefront quarantine=true
echo "kubectl label pod $POD -n storefront quarantine=true"