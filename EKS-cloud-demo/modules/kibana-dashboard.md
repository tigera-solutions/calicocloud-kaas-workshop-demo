# Module 3-2: Observability-Kibana Dashboard

**Goal:** Explore Calico observability tools.

## Calico observability tools

1. Kibana dashboards

    The `Kibana` components comes with Calico commercial offerings and provides you access to raw flow, audit, and dns logs, as well as ability to visualize the collected data in various dashboards.

    ![kibana dashboard](../img/kibana-dashboard.png)

    Calico provide Some of the default dashboards you get access to, including are DNS Logs, Flow Logs, Audit Logs, Kuernetes API calls, L7 HTTP metrics etc, and you can also customernize different dashboard. 

2. DNS dashboards   

    The `DNS` dashboard will give you a general idea about how DNS behave in your cluster, including internal & external queries, also DNS latency as it shows below.

     ![kibana dns dashboard](../img/kibana-dns-dashboard.png)

3. L7 logs    

    The `L7` dashboard will give you all details related to http protocol including method, response code and url etc. We will enable L7 logs in later module.

     ![kibana l7 logs](../img/kibana-l7-log.png)

4. Flow logs

    The `L7` dashboard will give you all details related to http protocol including method, response code and url etc. We will enable L7 logs in later module.

     ![kibana flow logs](../img/kibana-flow-logs.png)


5. Audit logs

    The `L7` dashboard will give you all details related to http protocol including method, response code and url etc. We will enable L7 logs in later module.

     ![kibana audit logs](../img/kibana-audit-log.png)



[Next -> Module 3-3](../modules/dynamic-packet-capture.md)

[Previous -> Module 3-1](../modules/dynamic-service-graph.md)

[Menu](../README.md)