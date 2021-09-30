## Cleanup this workshop.

1. Delete application stack to clean up any `loadbalancer` services.

    ```bash
    kubectl delete -f demo/dev-stack/
    kubectl delete -f demo/acme-stack/
    kubectl delete -f demo/storefront-stack
    kubectl delete -f demo/hipstershop/
    ```

2. Remove calicocloud components from your cluster.
   - Download the script 
   ```bash
   curl -O https://installer.calicocloud.io/manifests/v3.9.0-3/downgrade.sh
   ```

   - Make the script executable 
   ```bash
   chmod +x downgrade.sh
   ```

   - Run the script and read the help to determine if you need to specify any flags 
   ```bash
   ./downgrade.sh --help.
   ```

   - Run the script with any needed flags, for example: 
   ```bash
   ./downgrade.sh --remove-prometheus.
   
   ```   

3. Delete your managed cluster.
   
    a. For AKS cluster, please follow the steps below.  

    ```bash
    #Delete AKS cluster.
    az aks delete -n $CLUSTERNAME -g $RGNAME
    ```

    ```bash
    #Delete the azure resource group. 
    az group delete -g $RGNAME
    ```


   b. For EKS cluster, please follow the steps below.  

    ```bash
    #Delete EKS cluster.
    eksctl get cluster 
    eksctl delete cluster --name <your cluster name>
    ```

    ```bash
    #Delete EC2 Key Pair you created for this workshop.
    export KEYPAIR_NAME='your-key'
    aws ec2 delete-key-pair --key-name $KEYPAIR_NAME
    ```

    ```bash
    # Delete IAM role created for this workshop. IAM_ROLE was set in previous step as calicocloud-workshop-admin.
    IAM_ROLE='calicocloud-workshop-admin'
    ADMIN_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AdministratorAccess`].Arn' --output text)
    aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn $ADMIN_POLICY_ARN
    # if this command fails, you can remove the role via AWS Console once you delete the Cloud9 instance
    aws iam delete-instance-profile --instance-profile-name $IAM_ROLE
    aws iam delete-role --role-name $IAM_ROLE
    ```

   c. For GKE cluster, please follow the steps below.  

   