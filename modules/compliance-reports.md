# Security: Compliance reports

**Goal:** Use global reports to satisfy compliance requirements.

## Steps

1. Use `Compliance Reports` view to see all generated reports.

    >We have deployed a few compliance reports in one of the first labs and by this time a few reports should have been already generated. If you don't see any reports, you can manually kick off report generation task. Follow the steps below if you need to do so.

    Calico provides `GlobalReport` resource to offer [Compliance reports](https://docs.tigera.io/compliance/compliance-reports/) capability. There are several types of reports that you can configure:

    - CIS benchmarks
    - Inventory
    - Network access
    - Policy audit

    >When using EKS cluster, you need to [enable and configure audit log collection](https://docs.tigera.io/compliance/compliance-reports/compliance-managed-cloud#enable-audit-logs-in-eks) on AWS side in order to get the data captured for the `policy-audit` reports.

    A compliance report could be configured to include only specific endpoints leveraging endpoint labels and selectors. Each report has the `schedule` field that determines how often the report is going to be generated and sets the timeframe for the data to be included into the report.

    Compliance reports organize data in a CSV format which can be downloaded and moved to a long term data storage to meet compliance requirements.

    ![compliance report](../img/compliance-report.png)


2. Deploy hipstershop policies and observe the score in the next report which wil be different comparing with the previous ones, you may need change the cronjob schedule for those reports if you want to see the results quicker.

   ```bash
   kubectl apply -f demo/app-control/tiers-devops.yaml
   kubectl apply -f demo/app-control/hipstershop-policies.yaml
   ```

3. Generate a reports at any time to specify a different start/end time.
   
   a. Review and apply the yaml file for the managed cluster.

    Instructions below for a Managed cluster only. Follow [configuration documentation](https://docs.tigera.io/compliance/overview#run-reports) to configure compliance jobs for management and standalone clusters. We will need change the START/END time accordingly.

    ```bash
    vi demo/compliance-reports/compliance-reporter-pod.yaml
    ```

   b. We need to substitute the Cluster Name in the YAML file with the variable `CALICOCLUSTERNAME` we configured before. This enables compliance jobs to target the correct index in Elastic Search
	```bash
	sed -i "s/\$CALICOCLUSTERNAME/${CALICOCLUSTERNAME}/g" ./demo/compliance-reports/compliance-reporter-pod.yaml
	```
	For other variations/shells the following syntax may be required

	```bash
	sed -i "" "s/\$CALICOCLUSTERNAME/${CALICOCLUSTERNAME}/g" ./demo/compliance-reports/compliance-reporter-pod.yaml
	```

   c. Validate the change by cat the variable
    ```bash
    cat ./demo/compliance-reports/compliance-reporter-pod.yaml | grep -B 2 -A 0 $CALICOCLUSTERNAME
    ```

   Output will be like:
    ```text
          value: "warning"
     - name: ELASTIC_INDEX_SUFFIX
      value: "usza33l0-management-managed-a03b5f39d13f4802acfc947026eb47-gr7-us-east-2-eks-amazonaws-com"
    ```    

   d. We also need modify start/end time for specify the report time range. For examole:

   ```text
    - name: TIGERA_COMPLIANCE_REPORT_START_TIME
      value: 2021-12-31T23:00:00Z
    - name: TIGERA_COMPLIANCE_REPORT_END_TIME
      value: 2021-12-31T23:59:00Z
      # Modify these values with the start and end time frame that should be reported on.
   ```

   e. Now apply the compliance job YAML
	```bash
	kubectl apply -f demo/compliance-reports/compliance-reporter-pod.yaml
	```

    Once the `run-reporter` job finished, you should be able to see this report in manager UI and download the csv file. 

4. Reports are generated 30 minutes after the end of the report as [documented](https://docs.tigera.io/compliance/overview#change-the-default-report-generation-time). You can also deploy cronjob report to against your sensitive workload which need compliance report in place. Below yaml file is using `storefront` and `hipstershop` as example.

	```bash
	kubectl apply -f demo/compliance-reports/workload-report.yaml
	```


<br>

<br>


[Next -> Wireguard Encryption](../modules/encryption.md) 


[Menu](../README.md)