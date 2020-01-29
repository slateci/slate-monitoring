# slate-monitoring
SLATE resource monitoring based on Prometheus/Thanos/Grafana



# Changelog
- Porting to helm 3. Had to upgrade the helm chart as the old one (5.2.0) didn't support it. This broke the grafana dashboards, which need to be retouched.
- Refactoring code from previous repository. Splitting the part that will be executed by the SLATE client/service (in sbin) from the part that is used to manage an installation of multiple cluster by hand (in bin).
