9. *[Optional]* Create AKS cluster with mutiple nodepool/subnet.

 - Create a vnet with two subnet network
   ```bash
   vnet="myVirtualNetwork"
   az network vnet create -g $RGNAME --location $LOCATION --name $vnet --address-prefixes 10.0.0.0/8 -o none 
   az network vnet subnet create -g $RGNAME --vnet-name $vnet --name subnet1 --address-prefixes 10.240.0.0/16 -o none 
   az network vnet subnet create -g $RGNAME --vnet-name $vnet --name subnet2 --address-prefixes 10.241.0.0/16 -o none
   
   ```

  - Pull out the subnet ID
   ```bash
   Subnet1=$(az network vnet subnet list -g $RGNAME --vnet-name $vnet -o json | jq -c '.[] | select( .type == "Microsoft.Network/virtualNetworks/subnets")' | jq .id | awk 'NR==1{print $1 }')
   Subnet2=$(az network vnet subnet list -g $RGNAME --vnet-name $vnet -o json | jq -c '.[] | select( .type == "Microsoft.Network/virtualNetworks/subnets")' | jq .id | awk 'NR==2{print $1 }')
   Subnet1_ID=$(sed -e 's/^"//' -e 's/"$//' <<<"$Subnet1")
   Subnet2_ID=$(sed -e 's/^"//' -e 's/"$//' <<<"$Subnet2")
   ```

  - Create Azure Service Principal to use for further steps.
   ```bash
   CLUSTERNAME=aks-mutipool-${UNIQUE_SUFFIX}
   az ad sp create-for-rbac --skip-assignment
   ```

    - This will return the following. !!!IMPORTANT!!! - Please copy this information down as you'll need it for labs going forward.

	```text
	"appId": "7248f250-0000-0000-0000-dbdeb8400d85",
	"displayName": "azure-cli-2017-10-15-02-20-15",
	"name": "http://azure-cli-2017-10-15-02-20-15",
	"password": "77851d2c-0000-0000-0000-cb3ebc97975a",
	"tenant": "72f988bf-0000-0000-0000-2d7cd011db47"
	```

  - Set the values from above as variables **(replace <appid><password>with your values)</password></appid>**.

   ```bash
   # Persist for Later Sessions in Case of Timeout
   APPID=<appId>
   echo export APPID=$APPID >> ~/.bashrc
   CLIENTSECRET=<password>
   echo export CLIENTSECRET=$CLIENTSECRET >> ~/.bashrc
   ```

  - Create AKS

   ```bash
   az aks create -n $CLUSTERNAME -g $RGNAME --kubernetes-version $K8SVERSION --service-principal $APPID --client-secret $CLIENTSECRET \
   --generate-ssh-keys -l $LOCATION --node-count 3 --network-plugin azure --vnet-subnet-id $Subnet1_ID --no-wait
   ``` 
  
  - Add `subnet2` as `nodepool2` into AKS cluster 
   ```bash
   az aks nodepool add -g $RGNAME --cluster-name $CLUSTERNAME --name nodepool2 --node-count 3 \
   --vnet-subnet-id $Subnet2_ID --no-wait
   ```