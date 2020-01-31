# slate-monitoring
SLATE resource monitoring based on Prometheus/Thanos/Grafana

## Repository layout

```
sbin - contains scripts with the logic to implement in the SLATE service/client
bin - contains scripts to manually manage/debug multiple clusters
private - where to place the credentials for the bin scripts to work
  - address-list - list of IPs and hostnames for the platform thanos-query (one entry per line)
  - bucket.yaml - credentials for the long term storage of thanos data
  - conf - directory containing kubernetes credentials for each cluster (i.e. cluster-name.conf)
```

Run the commands without arguments to see the usage.

## How to manually generate credentials for OSiRIS

1. Go to https://comanage.osris.org/registry/
1. Login
1. Top left, menu from the username, Ceph Credentials/OSiRIS
1. In the list of the user "slate-monitoring", use the plus icon (Add new S3 access key)
1. Use sbin/generate-bucket-configuration.sh to generate the appropriate bucket.yaml

## Changelog
- Porting to helm 3. Had to upgrade the helm chart as the old one (5.2.0) didn't support it. This broke the grafana dashboards, which need to be retouched.
- Refactoring code from previous repository. Splitting the part that will be executed by the SLATE client/service (in sbin) from the part that is used to manage an installation of multiple cluster by hand (in bin).
