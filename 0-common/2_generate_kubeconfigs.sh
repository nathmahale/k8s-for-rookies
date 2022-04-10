#!/bin/bash

set -vx

source ../lib/kubeconfig_library.sh
source ../lib/dataencryption_library.sh

echo "Generating kubeconfigs for controller manager, kubelet, kube-proxy and scheduler."
generate_kubeconfig_kubelet_worker_nodes
generate_kubeconfig_kube_proxy
generate_kubeconfig_kube_controller_manager
generate_kubeconfig_kube_scheduler
generate_kubeconfig_admin_user

echo "Copy kubeconfigs to worker and controller nodes"
copy_kubeconfig_kubelet_worker_nodes
copy_kubeconfig_controller_nodes

echo "Encrypt data at rest"
data_encryption_function
