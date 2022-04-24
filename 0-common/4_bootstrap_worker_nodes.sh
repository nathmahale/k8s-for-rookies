#!/bin/bash

source ../lib/bootstrap_worker_nodes_library.sh
source ../lib/base_library.sh

echo "[ INFO ] Provision worker nodes."
provision_worker_nodes

echo "[ INFO ] Configure CNI, containerd, kubelet, kube-proxy"
configure_cni_networking
configure_containerd
configure_kubelet
configure_kube_proxy

start_worker_services
echo "[ INFO ] Please run this list_k8s_nodes from the machine used to create the compute instances"
