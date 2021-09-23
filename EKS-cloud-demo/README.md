# Calicocloud workshop on EKS

<img src="img/calico.png" alt="Calico on EKS" width="30%"/>


## Workshop prerequisites

>It is recommended to follow the EKS creation step outlined in [Module 0](modules/creating-eks-cluster.md) and to keep the resources isolated from any existing deployments. If you are using a corporate AWS account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage EKS clusters and Load Balancer resources.

- [Calico Cloud trial account](https://www.calicocloud.io/home)
- AWS account and credentials to manage AWS resources
- Terminal or Command Line console to work with AWS resources and EKS cluster
- most common environments are Cloud9, Mac OS, Linux, Windows WSL2
- `Git`
- `netcat`


## Modules

- [Module 0-1: Setting up workspace environment](./modules/setting-up-work-environment.md)
- [Module 0-2: Creating EKS cluster](modules/creating-eks-cluster.md)
- [Module 0-3: Joining EKS cluster to Calico Cloud](modules/joining-eks-to-calico-cloud.md)
- [Module 0-4: Configuring demo applications](modules/configuring-demo-apps.md)

- [Module 1-1: East-West controls-App service control](modules/app-service-control.md)
- [Module 1-2: East-West controls-Microsegmentation](modules/microsegmentation.md)
- [Module 1-3: East-West controls-Host protection](modules/host-protection.md)

- [Module 2-1: North-South Controls-Egress access controls, DNS policy and Global threadfeed ](modules/egress-access-controls.md)
- [WIP][Module 2-2: North-South Controls-Egress Gateway](modules/egress-gateway.md) 

- [Module 3-1: Observability-Dynamic Service Graph](modules/dynamic-service-graph.md)
- [Module 3-2: Observability-Kibana dashboard](modules/kibana-dashboard.md)
- [Module 3-3: Observability-Dynamic packet capture](modules/dynamic-packet-capture.md) 
- [Module 3-4: Observability-L7 visibility](modules/enable-l7-visibility.md) 

- [Module 4-1: Compliance and Security-Compliance](modules/compliance-reports.md) 
- [Module 4-2: Compliance and Security-Intrusion Detection and Prevention](modules/intrusion-detection-protection.md) 
- [WIP][Module 4-3: Compliance and Security-Encryption](modules/encryption.md) 

- [WIP][Module 5-1: Integration-Firewall Integration](modules/firewall-integration.md) 
- [WIP][Module 5-2: Integration-SIEM Integration](modules/siem-integration.md) 



## Cleanup

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

3. Delete EKS cluster.

    ```bash
    eksctl get cluster 
    eksctl delete cluster --name <your cluster name>
    ```

4. Delete EC2 Key Pair.

    ```bash
    export KEYPAIR_NAME='your-key'
    aws ec2 delete-key-pair --key-name $KEYPAIR_NAME
    ```

5. Delete Cloud9 instance.

    Navigate to `AWS Console` > `Services` > `Cloud9` and remove your workspace environment.

6. Delete IAM role created for this workshop.

    ```bash
    # use your local shell to set AWS credentials
    export AWS_ACCESS_KEY_ID="<your_accesskey_id>"
    export AWS_SECRET_ACCESS_KEY="<your_secretkey>"

    # delete IAM role
    IAM_ROLE='your-demo-admin'
    ADMIN_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AdministratorAccess`].Arn' --output text)
    aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn $ADMIN_POLICY_ARN
    # if this command fails, you can remove the role via AWS Console once you delete the Cloud9 instance
    aws iam delete-instance-profile --instance-profile-name $IAM_ROLE
    aws iam delete-role --role-name $IAM_ROLE
    ```
