#!/bin/bash

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
if [ $(hostname) == "controller-0" ]; then
    create_clusterrole
    create_clusterrolebinding
else
    echo "[ INFO ] RBAC not required for this controller node."
fi
