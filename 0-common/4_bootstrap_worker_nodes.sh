#!/bin/bash

source ../lib/bootstrap_worker_nodes_library.sh

echo "Provision worker nodes."
provision_worker_nodes

echo "Configure CNI, containerd, kubelet, kube-proxy"
configure_cni_networking
configure_containerd
configure_kubelet
configure_kube_proxy

start_worker_services
echo "Please run this list_k8s_nodes from the machine used to create the compute instances"
