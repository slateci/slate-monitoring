# slate-monitoring
SLATE resource monitoring based on Prometheus/Thanos/Grafana

## Repository layout

```
sbin - contains scripts with the logic to implement in the SLATE service/client
bin - contains scripts to manually manage/debug multiple clusters
private - where to place the credentials for the bin scripts to work
  - address-list - list of IPs and hostnames for the platform thanos-query (one entry per line)
  - admin-password - the password to be used for the admin account of grafana in the platform installation
  - bucket.yaml - credentials for the long term storage of thanos data
  - conf - directory containing kubernetes credentials for each cluster (i.e. cluster-name.conf)
  - cont/platform - the kubernetes credential for the platform
  - grafana-url - the URL to be used for the grafana server in the platform installation
```

Run the commands without arguments to see the usage.

## Installation (platform components)

1. Make sure you have an S3 bucket on OSiRIS created with the appropriate credentials
1. Make sure you have the kubeconfig file to the kubernetes cluster, which should have an ingress appropriately setup
1. Use sbin/generate-bucket-configuration.sh to generate the bucket.yaml
1. Use sbin/platform-install.sh to install the platform components (NOTE: depending on the amount of data in the bucket, it may take some time for the thanos-store to initialize)
1. Use sbin/platform-status.sh to check the pods and services
1. Use sbin/platform-delete.sh to remove the platform components

## Installation (cluster components)

1. Make sure you have the credentials for the S3 bucket
1. Use sbin/generate-bucket-configuration.sh to generate the bucket.yaml
1. Use sbin/cluster-install.sh to install the cluster components
1. Use sbin/cluster-status.sh to check the pods and services
1. Use sbin/cluster-delete.sh to remove the cluster components

## How to manually generate credentials for OSiRIS

1. Go to https://comanage.osris.org/registry/
1. Login
1. Top left, menu from the username, Ceph Credentials/OSiRIS
1. In the list of the user "slate-monitoring", use the plus icon (Add new S3 access key)
1. Use sbin/generate-bucket-configuration.sh to generate the appropriate bucket.yaml

## Scritps for cluster managements (bin)
Make sure the private directory is populated as required above. The bin scripts get the information in "private" and then call the sbin script appropriately.

1. Use bin/platform-install.sh to install the platform components
1. Use bin/platform-status.sh to check the pods and services
1. Use bin/platform-delete.sh to remove the platform components
1. Use bin/cluster-install.sh CLUSTER_NAME to install the cluster components (must match name in private/conf/CLUSTER_NAME.conf)
1. Use bin/cluster-status.sh CLUSTER_NAME to check the pods and services (must match name in private/conf/CLUSTER_NAME.conf)
1. Use bin/cluster-delete.sh CLUSTER_NAME to remove the cluster components (must match name in private/conf/CLUSTER_NAME.conf)
1. Use bin/list-addresses.sh to query the IP address of all clusters; use the info to populate private/address-list
1. Use bin/platform-address-list-update.sh to notify the platform of changes in the cluster ips

## Changelog
- Added bin scripts for platform installation
- Added new more detailed dashboards
- Added scripts for platform installation
- Porting to helm 3. Had to upgrade the helm chart as the old one (5.2.0) didn't support it. This broke the grafana dashboards, which need to be retouched.
- Refactoring code from previous repository. Splitting the part that will be executed by the SLATE client/service (in sbin) from the part that is used to manage an installation of multiple cluster by hand (in bin).
