#!/bin/bash

# Help message
if [ "$#" -ne 4 ]; then
    echo "Install SLATE monitoring central components"
    echo
    echo "      $0 KUBECONF_LOCATION BUCKET_CONF INGRESS_HOSTNAME GRAFANA_ADMIN_PASSWORD"
    echo
    echo "Example:  $0 ~/.kube/conf bucket.yaml monitoring.umich-prod.slateci.net ********"
    exit -1
fi

# Get input parameters
KUBECONFIG=`realpath $1`
BUCKET=`realpath $2`
INGRESS_HOSTNAME=$3
GRAFANA_ADMIN_PASSWORD=$4

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get global parameters
source global.param

cp $BUCKET $TMP_DIR/bucket.yaml

# Prepare Thanos Store deployment
cat > $TMP_DIR/thanos-store.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: thanos-store
spec:
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: thanos
      component: store-gateway
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: thanos
        component: store-gateway
    spec:
      containers:
      - name: store-gateway
        image: thanosio/thanos:v0.8.1
        args:
          - store
          - --data-dir=/var/thanos/store
          - --objstore.config=\$(OBJSTORE_CONFIG)
          - --grpc-address=\$(POD_IP):10901
          - --http-address=\$(POD_IP):10902
        ports:
          - name: api
            containerPort: 10901
          - name: http
            containerPort: 10902
        env:
          - name: OBJSTORE_CONFIG
            valueFrom:
              secretKeyRef:
                key: bucket.yaml
                name: slate-metrics-bucket
          - name: POD_IP
            valueFrom:
              fieldRef:
                apiVersion: v1
                fieldPath: status.podIP
---
apiVersion: v1
kind: Service
metadata:
  name: store-gateway
spec:
  selector:
    app: thanos
    component: store-gateway
  ports:
    - name: api
      port: 10901
      targetPort: 10901
    - name: http
      port: 10902
      targetPort: 10902
EOF

# Prepare Thanos Store deployment
cat > $TMP_DIR/values-grafana.yaml <<EOF
adminPassword: $GRAFANA_ADMIN_PASSWORD
service:
  type: LoadBalancer
ingress:
  enabled: true
  hosts:
    - $INGRESS_HOSTNAME
  annotations:
    kubernetes.io/ingress.class: "slate"
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Content-Security-Policy: frame-ancestors 'self' *.slateci.io *.slateci.net";
  tls:
    - secretName: grafana-slate
      hosts:
        - $INGRESS_HOSTNAME
grafana.ini:
  auth.anonymous:
    enabled: true
    org_name: Main Org.
    org_role: Viewer
datasources: 
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: SLATE
      type: prometheus
      url: http://query:9090
      access: proxy
      isDefault: true
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards/default
dashboards:
  default:
    kubernetes-usagebynamespace:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/kubernetes-usagebynamespace.json
    kubernetes-usagebycluster:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/kubernetes-usagebycluster.json
    slate-usagebycluster:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/slate-usagebycluster.json
    slate-usagebygroup:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/slate-usagebygroup.json
    slate-usagebyapplication:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/slate-usagebyapplication.json
    slate-cluster-status:
      url: https://raw.githubusercontent.com/slateci/slate-monitoring/master/dashboards/slate-cluster-status.json
EOF

echo Creating platform namespace
kubectl create namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Create the secret with access information to the long term storage
kubectl create secret generic slate-metrics-bucket --from-file=$TMP_DIR/bucket.yaml --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Install the thanos-store
kubectl apply -f $TMP_DIR/thanos-store.yaml --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Install grafana
helm install grafana-slate stable/grafana --values $TMP_DIR/values-grafana.yaml --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

./platform-address-list-update.sh $KUBECONFIG
