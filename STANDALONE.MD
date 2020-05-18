# Standalone monitoring installation for a SLATE cluster

The SLATE monitoring infrastructure aims to provide a unified view of the system metrics
across all slate clusters. However, it is possible to install the basic tools on a cluster
without worrying about plugging them to the overall SLATE infrastructure. This may be
useful for testing purposes or in case one wants to experiment on how to integrate these
same tools within the site infrastructure.

The SLATE monitoring infrastructure consiststs of three components:
 * Prometheus - gathers the data from each cluster
 * Thanos - collects the data from all cluster in a single place and provies long term storage for the data
 * Grafana - displays the data from either Prometheus or Thanos
 
For the standalong installation, just Prometheus and Grafana are needed. Here we provide a simple
guide to install them in a way that is similiar to how they will be installed by SLATE.

## Prerequisites

Before installation, make sure you have the following:
 * A Kubernetes cluster accessible with admin credentials
 * Helm v3 executable

Create a file prom-values.yaml with the following content:
```yaml
grafana:
  enabled: true

prometheus:
  prometheusSpec:
    image:
      tag: v2.14.0
```
The first section makes sure grafana will run and the second section fixes the Promethus version
to the one currently used by SLATE.

At the commanline, run the following command:
```bash
>helm install --values prom-values.yaml prometheus-operator --version 8.5.14 --namespace slate-monitoring stable/prometheus-operator
```
This will install the prometheus-operator, which is a utility to manage a Prometheus/Thanos/Grafana installation
over a Kubernetes cluster. The version number refers to the helm chart. It is the one currently
used by SLATE.

To access the service, forward the grafana service to localhost:
```bash
>kubectl -n slate-monitoring port-forward service/prometheus-operator-grafana 3000:80
```
Now you can open a browser to http://127.0.0.1:3000 and connect to grafana. Login using the admin account.
The default password will be 'prom-operator'. Note that the graphs in grafana are not going to be the same ones
that are available on SLATE.


