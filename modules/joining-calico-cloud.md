# Joining your cluster to Calico Cloud

**Goal:** Join cluster to Calico Cloud management plane.

IMPORTANT: In order to complete this module, you will need to create a [Calico Cloud trial account](https://www.calicocloud.io/). Issues with being unable to navigate menus in the UI are often due to browsers blocking scripts - please ensure that you disabled all blocker scripts.

## Step 1 - Creating a Calico Cloud trial account

1. Navigate to [https://www.calicocloud.io/](https://www.calicocloud.io/) and sign up for a 14 day trial account - no credit cards required. Provide a valid e-mail and create a password following the guidelines provided. Continue and a verification e-mail will be sent to the address you provided. 

    ![register](https://user-images.githubusercontent.com/104035488/188006082-e13d07eb-fb4a-4a9a-8189-432a8659f100.gif)

2. You will receive the verification e-mail - if you did not received it after a few moments you registered check your SPAM folder. Click in the "VERIFY YOUR ACCOUNT" button in the e-mail. You should see a web pager with the email verification successed message. Click in the "Back to Calico Cloud" link to return to Calico Cloud. Enter your profile information and submit. In a few moments your trial environment will be ready for you to use.

    ![register_email](https://user-images.githubusercontent.com/104035488/188006198-834195b2-a5c0-416d-9b70-df11be95a699.gif)

This concludes the Calico Cloud trial account creation. From now on you have 14 days to test Calico Cloud. You can log in back at any time using the "Login as an Existing User" link in the [Calico Cloud](https://www.calicocloud.io/) website.

## Step 2 - Connecting your cluster to Calico Cloud.

1. When returning to the [Calico Cloud](https://www.calicocloud.io/) website, use the "Login as an Existing User" link, enter your e-mail and password to log back into your trial environment. The welcome screen will lead you to choose among four use cases which will give a tailored tour for learning more. You can select whichever use case better fits your needs. After that you can connect your first cluster. This option direct you to the **Managed Clusters** section. Click on the "**Connect Cluster**" button to start the process of connecting a new cluster.

    ![first_login](https://user-images.githubusercontent.com/104035488/188036056-1fd0221b-8402-4841-99c3-dc891810b678.gif)

2. The Connect Cluster window will allow you to choose a name to identify your cluster on Calico Cloud and specify what is the service you are using to run your Kubernetes cluster. The next window presents a link for you to review the cluster requirements for Calico Cloud. And finally, a kubectl command will be generate. You need to copy an apply it on your cluster to kick of the installation process of the necessary objects to connect your cluster to Calico Cloud.

    ![registering_get_key](https://user-images.githubusercontent.com/104035488/188036064-f85cac4f-66c0-4c09-bdd3-67922640679d.gif)

3. Run installation script in your aks cluster. Script should look similar to this:
    
    ```bash
    kubectl apply -f https://installer.calicocloud.io/manifests/cc-operator/latest/deploy.yaml && curl -H "Authorization: Bearer a7c2oex34:00llxrhcq:1ga2cz69d7ug81yjgakpyclv6o3eu8o97kp7t2483lmwajslu47xed94e4ic8ywn" "https://www.calicocloud.io/api/managed-cluster/deploy.yaml" | kubectl apply -f -
    ```

    > Output should look similar to:
    ```bash
    namespace/calico-cloud created
    customresourcedefinition.apiextensions.k8s.io/installers.operator.calicocloud.io created
    serviceaccount/calico-cloud-controller-manager created
    role.rbac.authorization.k8s.io/calico-cloud-leader-election-role created
    clusterrole.rbac.authorization.k8s.io/calico-cloud-metrics-reader created
    clusterrole.rbac.authorization.k8s.io/calico-cloud-proxy-role created
    rolebinding.rbac.authorization.k8s.io/calico-cloud-leader-election-rolebinding created
    clusterrolebinding.rbac.authorization.k8s.io/calico-cloud-installer-rbac created
    clusterrolebinding.rbac.authorization.k8s.io/calico-cloud-proxy-rolebinding created
    configmap/calico-cloud-manager-config created
    service/calico-cloud-controller-manager-metrics-service created
    deployment.apps/calico-cloud-controller-manager created
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100   355  100   355    0     0    541      0 --:--:-- --:--:-- --:--:--   541
    secret/api-key created
    installer.operator.calicocloud.io/aks-cc-repo created
    ```
    Joining the cluster to Calico Cloud can take a few minutes. Meanwhile the Calico resources can be monitored until they are all reporting `Available` as `True`

    ```bash
    kubectl get tigerastatus                                                                                                                    

    NAME                            AVAILABLE   PROGRESSING   DEGRADED   SINCE
    apiserver                       True        False         False      96s
    calico                          True        False         False      16s
    compliance                      True        False         False      21s
    intrusion-detection             True        False         False      41s
    log-collector                   True        False         False      21s
    management-cluster-connection   True        False         False      51s
    monitor                         True        False         False      2m1s
    ```

    You can also monitor your cluster installation on the Calico Cloud UI. Go to "**Managed Clusters**" section, select your cluster and expand the timestamp dropdown to see the installation logs.
    In a few minutes the status will change from **Installing** to **Done**. Congratulations! You sucessfully connected your cluster to Calico Cloud.

    ![installing](https://user-images.githubusercontent.com/104035488/188036070-71cd3cb7-639b-46f2-bd5e-dbdb401b48e3.gif)

## STEP 3 - Selecting your cluster.

Once the installation is completed, you will be able to start interacting with your cluster from the Calico Cloud interface. Calico Cloud provides a single pane of glass for applying security controls across multiple cluster. It means that you can have more than on cluster connected to Calico Cloud at the same time.
If you followed the previous steps, you may have two cluster connected to Calico Cloud at this point: Your cluster and a pre-configured cluster that allows you to explore the features in case you are not able to connect a cluster to Calico Cloud.

You can switch between cluster by following the steps below:

1. Navigate to the Dashboard section - the first icon under the Calico Cat on the top-left of the UI.

2. Click on the dropdown **Cluster** button on the top-right of the Dashboard section page.

3. Select your recem-added cluster.

    ![selecting_cluster](https://user-images.githubusercontent.com/104035488/188036074-857e6a19-7641-4dff-9f6b-02eb627cf748.gif)

The "**Cluster**" dropdown button will be always visible accross the Calico Cloud UI, no matter which section you are viewing. You can change the cluster you want to interact with at any moment. 
When you change the cluster, the whole Calico Cloud context will change immediatelly to reflect the information regarding the current selected cluster.

### Congratulation! You successfully connected your cluster to Calico Cloud and you are now read to move forward in the wokshop by configuring your cluster for the workshop environment.

--- 

[:arrow_right: Configure you cluster and demo applications for the workshop](./configuring-demo-apps.md)

[:leftwards_arrow_with_hook: README.md - STEP 1 - Create a compatible k8s cluster](../README.md#step-4---configure-demo-applications)