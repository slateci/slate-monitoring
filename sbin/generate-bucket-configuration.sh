#!/bin/bash

# Help message
if [ "$#" -ne 2 ]; then
    echo "Generates the bucket.yaml configuration from the OSiRIS access/secret keys"
    echo
    echo "      $0 ACCESS_KEY SECRET_KEY"
    echo
    echo "Example:  $0 P9TYGJVT1BODF3N1M6CH yHE4IW0mTvFBioMoaqm896q6nECTDW6bp4M5OCKT"
    exit -1
fi

# Get input parameters
ACCESS_KEY=$1
SECRET_KEY=$2

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get global parameters
source global.param

echo "type: S3
config:
  bucket: \"slate-metrics\"
  endpoint: \"rgw.osris.org\"
  access_key: \"$ACCESS_KEY\"
  insecure: true
  signature_version2: false
  encrypt_sse: false
  secret_key: \"$SECRET_KEY\"
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 0s
    insecure_skip_verify: false"
