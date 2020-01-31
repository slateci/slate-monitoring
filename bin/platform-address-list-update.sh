#!/bin/bash


cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-platform.sh

ADDRESS_LIST=`echo \`cat ../private/address-list\``

../sbin/platform-address-list-update.sh $PLATFORM_KUBECONFIG $ADDRESS_LIST
