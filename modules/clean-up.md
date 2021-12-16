## Cleanup this workshop.

1. Delete application stack to clean up any `loadbalancer` services.

    ```bash
    kubectl delete -f demo/setup/dev
    kubectl delete -f demo/setup/acme
    kubectl delete -f demo/setup/storefront
    kubectl delete -f demo/setup/hipstershop/
    kubectl delete ns yaobank
    ```

2. Remove calicocloud components from your cluster.
   - Download the script 
   ```bash
   curl -O https://installer.calicocloud.io/manifests/v3.10.0-0/downgrade.sh
   ```

   - Make the script executable 
   ```bash
   chmod +x downgrade.sh
   ```

   - Run the script and read the help to determine if you need to specify any flags 
   ```bash
   ./downgrade.sh --help
   ```

   - Run the script with any needed flags, for example: 
   ```bash
   ./downgrade.sh --remove-prometheus --remove-all-calico-policy
   
   ```   

3. Delete your managed cluster.

   a. For EKS cluster, please follow the steps below.  

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
   
    b. For AKS cluster, please follow the steps below.  

    ```bash
    #Delete AKS cluster.
    az aks delete -n $CLUSTERNAME -g $RGNAME
    ```

    ```bash
    #Delete the azure resource group. 
    az group delete -g $RGNAME
    ```




   c. For GKE cluster, please follow the steps below.  

   ```bash
    #Get GKE cluster name.
    gcloud container clusters list --region $REGION    

    gcloud container clusters delete <your cluster name> --region $REGION 
    ```

   [Menu](../README.md)
   