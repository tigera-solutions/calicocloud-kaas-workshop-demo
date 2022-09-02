# Configure your cluster and install demo applications

**Goal:** Configure Calico parameters for a quicker visualization of the changes done during the workshop, and install and configure demo applications.

## Step 1 - Configure Calico paramenters

1. Configure log aggregation and flush intervals in your cluster, we will use 15s instead of default value 300s for lab testing only.   

    ```bash
    kubectl patch felixconfiguration default -p '{"spec":{"flowLogsFlushInterval":"15s"}}'
    kubectl patch felixconfiguration default -p '{"spec":{"dnsLogsFlushInterval":"15s"}}'
    kubectl patch felixconfiguration default -p '{"spec":{"flowLogsFileAggregationKindForAllowed":1}}'
    kubectl patch felixconfiguration default -p '{"spec":{"flowLogsFileAggregationKindForDenied":0}}'
    kubectl patch felixconfiguration default -p '{"spec":{"dnsLogsFileAggregationKind":0}}'
    ```

   > If you hit an error message of "**iptablesBackend cannot be auto**" for your RKE, use command below to remove this Field and value in spec.

    ```bash
    kubectl edit felixconfigurations default
    ```

    ```yaml
    # Please edit the object below. Lines beginning with a '#' will be ignored,
    # and an empty file will abort the edit. If an error occurs while saving this file will be
    # reopened with the relevant failures.
    #
    apiVersion: projectcalico.org/v3
    kind: FelixConfiguration
    metadata:
      creationTimestamp: "2022-09-01T15:46:45Z"
      name: default
      resourceVersion: "3276"
      uid: 2314864e-d31e-457a-a002-da2c1f0e867d
    spec:
      floatingIPs: Disabled
      iptablesBackend: auto  # <--- Remove this line and save --- #
      healthPort: 9099
      logSeverityScreen: Info
      reportingInterval: 0s
      tproxyMode: Disabled
    ```
2. Configure Felix to collect TCP stats - this uses eBPF TC program and requires miniumum Kernel version of v5.3.0/v4.18.0-193. Further [documentation](https://docs.tigera.io/visibility/elastic/flow/tcpstats).


    ```bash
    kubectl patch felixconfiguration default -p '{"spec":{"flowLogsCollectTcpStats":true}}'
    ```

## Step 2 - Create policy tier and essential policies

1. Deploy policy tiers.

    We are going to deploy some policies into policy tier to take advantage of hierarcical policy management.

    You can copy and past the command below,

    ```yaml
    kubectl apply -f - <<-EOF
    apiVersion: projectcalico.org/v3
    kind: Tier
    metadata:
      name: platform
    spec:
      order: 700
    ---
    apiVersion: projectcalico.org/v3
    kind: Tier
    metadata:
      name: security
    spec:
      order: 500
    EOF
    ```
    
    or 

    ```bash
    kubectl apply -f demo/setup/tiers/
    ```
    This will add tiers `security`, and `platform` to the Calico cluster.
    

2. Deploy base policy.

    In order to explicitly allow workloads to connect to the Kubernetes DNS component, we are going to implement a policy that controls such traffic. We also deploy allow policy for logging and contraint for PCI compliance.

    ```yaml
    kubectl apply -f - <<-EOF
    apiVersion: projectcalico.org/v3
    kind: GlobalNetworkPolicy
    metadata:
      name: platform.allow-kube-dns
    spec:
      tier: platform
      order: 200
      selector: projectcalico.org/namespace != "acme"
      egress:
        - action: Allow
          source: {}
          destination:
            selector: k8s-app == "kube-dns"
      types:
        - Egress
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalNetworkPolicy
    metadata:
      name: platform.pass
    spec:
      tier: platform
      order: 2000
      ingress:
        - action: Pass
      egress:
        - action: Pass
      doNotTrack: false
      applyOnForward: false
      preDNAT: false
      types:
        - Ingress
        - Egress
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalNetworkPolicy
    metadata:
      name: security.pass
    spec:
      tier: security
      order: 2000
      ingress:
        - action: Pass
      egress:
        - action: Pass
      types:
        - Ingress
        - Egress
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalNetworkPolicy
    metadata:
      name: security.pci-whitelist
    spec:
      tier: security
      order: 300
      selector: projectcalico.org/namespace != "acme"
      ingress:
      - action: Deny
        source:
          serviceAccounts:
            selector: PCI != "true"
        destination:
          serviceAccounts:
            selector: PCI == "true"
      - action: Pass
        source:
        destination:
      egress:
      - action: Deny
        source:
          serviceAccounts:
            selector: PCI == "true"
        destination:
          serviceAccounts:
            selector: PCI != "true"
      - action: Pass
        source:
        destination:
      types:
      - Ingress
      - Egress
    EOF
    ```

    ```bash
    kubectl apply -f demo/setup/stage0/
    ```

## STEP 3 - Install the demo applications

1. Deploy demo applications.

    ```bash
    #deploy dev app stack
    kubectl apply -f demo/setup/dev
    
    #deploy storefront app stack
    kubectl apply -f demo/setup/storefront

    #deploy hipstershop app stack
    kubectl apply -f demo/setup/hipstershop
    ```

## STEP 4 - Create the Global Reports and the Global Alerts

1. Deploy compliance reports which schedule as cronjob in every hour for cluster report and a daily cis benchmark report.

    >The compliance reports will be needed for one of a later lab, is cronjob in your cluster, you can change the schedule by edit it.

    Global Reports YAML

    ```yaml
    kubectl apply -f - <<-EOF
    apiVersion: projectcalico.org/v3
    kind: GlobalReport
    metadata:
      name: cis-results
      labels:
        deployment: production
    spec:
      reportType: cis-benchmark
      schedule: '0 * * * *'
      cis:
        highThreshold: 100
        medThreshold: 50
        includeUnscoredTests: true
        numFailedTests: 5
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalReport
    metadata:
      name: cluster-inventory
    spec:
      reportType: inventory
      schedule: '0 * * * *'
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalReport
    metadata:
      name: cluster-network-access
    spec:
      reportType: network-access
      schedule: '0 * * * *' 
    ---
    apiVersion: projectcalico.org/v3
    kind: GlobalReport
    metadata:
      name: cluster-policy-audit
    spec:
      reportType: policy-audit
      schedule: '0 * * * *'
    EOF
    ```
    or

    ```bash
    kubectl apply -f demo/compliance-reports/cis-benchmark-report.yaml
    kubectl apply -f demo/compliance-reports/cluster-reports.yaml
    ```

2. Deploy global alerts.

    >The alerts will be explored in a later lab.

    ```bash
    kubectl apply -f demo/alerts/
    ```

3. Confirm the global compliance report and global alert are running.
    
    ```bash
    kubectl get globalreport

    kubectl get globalalert
    ``` 


    The output looks like as below:

    ```bash
    NAME                      CREATED AT 
    cis-results               2022-09-01T15:42:33Z
    cluster-inventory         2022-09-01T15:42:33Z
    cluster-network-access    2022-09-01T15:42:33Z
    cluster-policy-audit      2022-09-01T15:42:33Z
    

    NAME                      CREATED AT
    dns.unsanctioned.access   2022-09-01T15:42:40Z
    network.lateral.access    2022-09-01T15:42:40Z
    policy.globalnetworkset   2022-09-01T15:42:39Z
    ```

--- 

[:arrow_right: Configure you cluster and demo applications for the workshop](./app-service-control.md)

[:leftwards_arrow_with_hook: Back to README.md](../README.md)