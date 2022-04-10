#!/bin/bash

set -vx

source ../lib/bootstrap_controller_nodes_library.sh

echo "Bootstrap etcd cluster."
bootstrap_etcd_cluster
bootstrap_k8s_control_plane

echo "Test nginx"
nginx_test
nginx_health_check

echo "Verify Kubernetes cluster"
verify_cluster_info

echo "Create clusterRole and clusterRoleBinding"
create_clusterrole
create_clusterrolebinding

echo "Provision NLB"
provision_nlb
verify_cluster_version


