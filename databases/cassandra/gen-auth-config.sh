#!/usr/bin/env bash
set -eo pipefail

build=cassandra/build
password=$(grep keystore_password $build/certs/tctl.result | cut -d \" -f2)

# See: https://cassandra.apache.org/doc/stable/cassandra/operating/security.html
cat <<EOF > $build/auth-config.yaml
client_encryption_options:
   enabled: true
   optional: false
   keystore: /certs/out.keystore
   keystore_password: "${password}"

   require_client_auth: true
   truststore: /certs/out.truststore
   truststore_password: "${password}"
   protocol: TLS
   algorithm: SunX509
   store_type: JKS
   cipher_suites: [TLS_RSA_WITH_AES_256_CBC_SHA]
EOF
