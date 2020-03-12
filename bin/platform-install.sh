#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-platform.sh

ADMIN_PASSWORD=`echo \`cat ../private/admin-password\``
GRAFANA_URL=`echo \`cat ../private/grafana-url\``

../sbin/platform-install.sh $PLATFORM_KUBECONFIG ../private/bucket.yaml $GRAFANA_URL $ADMIN_PASSWORD
