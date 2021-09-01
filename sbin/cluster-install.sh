#!/bin/bash

# Help message
if [ "$#" -ne 3 ]; then
    echo "Install SLATE monitoring on the cluster"
    echo
    echo "      $0 CLUSTER_NAME KUBECONF_LOCATION BUCKET_CONF"
    echo
    echo "Example:  $0 umich-prod ~/.kube/conf bucket.yaml"
    exit -1
fi

# Get input parameters
CLUSTER=$1
SITE=`echo $CLUSTER | cut -d'-' -f1`
KUBECONFIG=`realpath $2`
BUCKET=`realpath $3`

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get global parameters
source global.param

cp $BUCKET $TMP_DIR/bucket.yaml

# Prepare Helm values file for Prometherus/Thanos installation
cat > $TMP_DIR/prom-values.yaml <<EOF
grafana:
  enabled: true
#  service:
#    type: LoadBalancer

prometheus:
  thanosServiceExternal:
    enabled: true
  prometheusSpec:
    image:
      tag: v2.14.0
    externalLabels:
      site: $SITE
      cluster: $CLUSTER
    thanos:
      objectStorageConfig:
        name: slate-metrics-bucket
        key: bucket.yaml

EOF

# Create namespace slate-monitoring
kubectl create namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Create the secret with access information to the long term storage
kubectl create secret generic slate-metrics-bucket --from-file=$TMP_DIR/bucket.yaml --namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Install the prometheus operator
helm install --values $TMP_DIR/prom-values.yaml prometheus-operator --namespace $NAMESPACE prometheus-community/kube-prometheus-stack --kubeconfig $KUBECONFIG --version 17.1.3
