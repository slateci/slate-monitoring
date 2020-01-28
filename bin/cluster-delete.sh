#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-cluster.sh || exit 1

../sbin/cluster-delete.sh $KUBECONFIG
