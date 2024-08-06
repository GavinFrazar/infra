#!/bin/bash
set -e

B64_CLUSTER_CA=${cluster_auth_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${cluster_name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL \
  --ip-family ${cluster_ip_family} --service-${cluster_ip_family}-cidr ${cluster_service_cidr}
