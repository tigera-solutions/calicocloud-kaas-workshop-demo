# Calico workshop on EKS

<img src="img/calico-on-eks.png" alt="Calico on EKS" width="30%"/>


## Workshop prerequisites

>It is recommended to use your personal AWS account which would have full access to AWS resources. If using a corporate AWS account for the workshop, make sure to check with account administrator to provide you with sufficient permissions to create and manage EKS clusters and Load Balancer resources.

- [Calico Cloud trial account](https://www.tigera.io/tigera-products/calico-cloud/)
  - for instructor-led workshop use instructions in the email you receive to request a Calico Trial account
  - for self-paced workshop follow the [link to register](https://www.tigera.io/tigera-products/calico-cloud/) for a Calico Trial account
- AWS account and credentials to manage AWS resources
- Terminal or Command Line console to work with AWS resources and EKS cluster
  - most common environments are Cloud9, Mac OS, Linux, Windows WSL2
- `Git`
- `netcat`


## Modules

- [Module 1: Setting up workspace environment](./modules/setting-up-work-environment.md)
- [Module 2: Creating EKS cluster](modules/creating-eks-cluster.md)
- [Module 3: Joining EKS cluster to Calico Cloud](modules/joining-eks-to-calico-cloud.md)
- [Module 4: Configuring demo applications](modules/configuring-demo-apps.md)

- [Module 5: East-West controls-App service control](modules/app-service-control.md)

- [Module 6: Host protection](modules/host-protection.md)

- [Module 7: North-South Controls-Egress access controls](modules/using-egress-access-controls.md)

- [Module 8: Observability-Dynamic service graph](modules/using-observability-tools.md)
- [Module 9: Security and Compliance-Using compliance reports](modules/using-compliance-reports.md)
- [Module 10: Security and Compliance-Intrusion Detection](modules/using-alerts.md)
- [Module 11: Observability-Dynamic packet capture](modules/dynamic-packet-capture.md)

## Cleanup

1. Delete application stack to clean up any `loadbalancer` services.

    ```bash
    kubectl delete -f demo/dev/app.manifests.yaml
    kubectl delete -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml
    ```

2. Delete EKS cluster.

    ```bash
    eksctl get cluster 
    eksctl delete cluster --name <your cluster name>
    ```

3. Delete EC2 Key Pair.

    ```bash
    export KEYPAIR_NAME='your-key'
    aws ec2 delete-key-pair --key-name $KEYPAIR_NAME
    ```

4. Delete Cloud9 instance.

    Navigate to `AWS Console` > `Services` > `Cloud9` and remove your workspace environment.

5. Delete IAM role created for this workshop.

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
