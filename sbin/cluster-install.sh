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
  enabled: false
  service:
    type: LoadBalancer

prometheusOperator:
  image:
    tag: v0.29.0
  prometheusConfigReloaderImage:
    tag: v0.29.0

prometheus:
  prometheusSpec:
    image:
      tag: v2.14.0
    externalLabels:
      site: $SITE
      cluster: $CLUSTER
    thanos:
      image: thanosio/thanos:v0.4.0
      objectStorageConfig:
        name: slate-metrics-bucket
        key: bucket.yaml

EOF

# Prepare Service description to expose thanos sidecar
cat > $TMP_DIR/thanos-store.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: thanos-store
  labels:
    thanos: store
spec:
  type: LoadBalancer
  selector:
    app: prometheus
    prometheus: prometheus-operator-prometheus
  ports:
  - protocol: TCP
    port: 10901
    targetPort: 10901
EOF

# Create namespace slate-monitoring
kubectl create namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Create the secret with access information to the long term storage
kubectl create secret generic slate-metrics-bucket --from-file=$TMP_DIR/bucket.yaml --namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Install the prometheus operator
helm install --values $TMP_DIR/prom-values.yaml prometheus-operator --namespace $NAMESPACE stable/prometheus-operator --kubeconfig $KUBECONFIG

# Expose the thanos-store
kubectl apply -f $TMP_DIR/thanos-store.yaml --namespace $NAMESPACE --kubeconfig $KUBECONFIG
