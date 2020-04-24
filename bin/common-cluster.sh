#!/bin/bash

CLUSTER=$1
KUBECONFIG=../private/conf/$CLUSTER.conf
BUCKET=../private/bucketConf/$CLUSTER.yaml

if [ ! -f $KUBECONFIG ]; then
    echo "Kubernetes configuration file for $CLUSTER not found"
    exit 1
fi

if [ ! -f $BUCKET ]; then
    echo "S3 Bucket configuration file for $CLUSTER not found"
    exit 1
fi



