#!/bin/bash

# Help message
if [ "$#" == 0 ]; then
    echo "Updates the list of IPs used by the platform to connect to the clusters"
    echo
    echo "      $0 PLATFORM_KUBECONF_LOCATION IP1 IP2 ..."
    echo
    echo "Example:  $0 ~/.kube/conf 192.170.227.231 uchicago-prod.monitoring.slateci.net"
    exit -1
fi

# Get input parameters
KUBECONFIG=`realpath $1`

for ADDRESS in "${@:2}"
do
  if [[ $ADDRESS == *":"* ]]; then
  CLUSTER_STORES="$CLUSTER_STORES          - --store=$ADDRESS
"
  else
  CLUSTER_STORES="$CLUSTER_STORES          - --store=$ADDRESS:10901
"   
  fi   
done

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get global parameters
source global.param

# Prepare Helm values file for Prometherus/Thanos installation
cat > $TMP_DIR/thanos-query.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-query
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: thanos
      component: query
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: thanos
        component: query
    spec:
      containers:
      - name: query
        image: thanosio/thanos:v0.8.1
        args:
          - query
          - --http-address=\$(POD_IP):9090
          - --grpc-address=\$(POD_IP):10901
          - --store=store-gateway:10901
$CLUSTER_STORES
        env:
        - name: POD_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.podIP
        ports:
          - name: query
            containerPort: 9090
          - name: api
            containerPort: 10901
---
apiVersion: v1
kind: Service
metadata:
  name: query
spec:
  type: ClusterIP
  selector:
    app: thanos
    component: query
  ports:
    - name: http
      port: 9090
      targetPort: 9090
      protocol: TCP

EOF

kubectl apply -f $TMP_DIR/thanos-query.yaml --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG
