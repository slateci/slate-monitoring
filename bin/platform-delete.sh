#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-platform.sh

../sbin/platform-delete.sh $PLATFORM_KUBECONFIG
