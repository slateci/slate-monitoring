#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo Current list:
cat ../private/address-list
echo

for CLUSTER in `./list-clusters.sh` ; do
    KUBECONFIG=../private/conf/$CLUSTER.conf
    echo IP for $CLUSTER:
    kubectl get service prometheus-operator-kube-p-thanos-external --namespace slate-monitoring --kubeconfig $KUBECONFIG --output=custom-columns=IP:.status.loadBalancer.ingress[*].ip --no-headers=true 
done

