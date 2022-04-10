#!/bin/bash

set -vx

source ./tls_library.sh

echo "Generating certs"
generate_ca
generate_admin_cert
generate_kubelet_client_certs
generate_kube_controller_manager_cert
generate_kube_proxy_client_cert
generate_kube_scheduler_client_cert
generate_kubernetes_api_server_cert
generate_service_account_keypair

echo "Copy certs to Worker nodes"
copy_worker_certs

echo "Copy certs to Controller nodes"
copy_controller_certs