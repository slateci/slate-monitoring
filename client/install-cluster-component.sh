#!/bin/bash

# Help message
if [ "$#" -ne 5 ]; then
    echo "Install SLATE monitoring on the cluster"
    echo
    echo "      $0 KUBECONF_LOCATION MONITORING_NAMESPACE CLUSTER_NAME ACCESS_KEY SECRET_KEY"
    echo
    echo "Example:  $0 ~/.kube/conf slate-monitoring umich-prod RZO.............1U5 VAl..................................g6H"
    exit -1
fi

# Check helm exists
HELM_VERSION=`helm version --short`
if [ "$?" -ne 0 ]; then
    echo "Unable to locate helm in the search path"
    echo
    echo "If it is not installed, you can download it from https://github.com/helm/helm/releases"
fi

HELM_REPOS=`helm repo list | grep prometheus-community | grep "https://prometheus-community.github.io/helm-charts"`
if [ -z "$HELM_REPOS" ]; then
    echo "The prometheus-community repository does not appear to be properly configured."
    echo
    echo "It can be added with using:"
    echo "    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
fi

# Get input parameters
KUBECONF_LOCATION=`realpath $1`
MONITORING_NAMESPACE=$2
CLUSTER_NAME=$3
SITE_NAME=`echo $CLUSTER_NAME | cut -d'-' -f1`
ACCESS_KEY=$4
SECRET_KEY=$5
TMP_DIR=./tmp

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Clean temp directory
rm -rf $TMP_DIR
mkdir -p $TMP_DIR

# Create bucket configuration
cat > $TMP_DIR/bucket.yaml <<EOF
type: S3
config:
  bucket: "slate-metrics"
  endpoint: "rgw.osris.org"
  access_key: "$ACCESS_KEY"
  insecure: true
  signature_version2: false
  secret_key: "$SECRET_KEY"
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 0s
    insecure_skip_verify: false
EOF

# Prepare helm configuration
cat > $TMP_DIR/prom-values.yaml <<EOF
grafana:
  enabled: true

prometheus:
  thanosServiceExternal:
    enabled: true
  prometheusSpec:
    image:
      tag: v2.14.0
    externalLabels:
      site: $SITE_NAME
      cluster: $CLUSTER_NAME
    thanos:
      objectStorageConfig:
        name: slate-metrics-bucket
        key: bucket.yaml
EOF

# Create namespace slate-monitoring
kubectl create namespace $MONITORING_NAMESPACE --kubeconfig $KUBECONF_LOCATION

# Create the secret with access information to the long term storage
kubectl create secret generic slate-metrics-bucket --from-file=$TMP_DIR/bucket.yaml --namespace $MONITORING_NAMESPACE --kubeconfig $KUBECONF_LOCATION

# Install the prometheus operator
helm install --values $TMP_DIR/prom-values.yaml prometheus-operator --namespace $MONITORING_NAMESPACE prometheus-community/kube-prometheus-stack --kubeconfig $KUBECONF_LOCATION --version 17.1.3

rm -rf $TMP_DIR
