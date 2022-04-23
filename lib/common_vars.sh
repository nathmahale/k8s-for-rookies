#!/bin/bash

region=$(gcloud config get-value compute/region)
zone=$(gcloud config get-value compute/zone)

forwarding_rule_name="k8s-forwarding-rule"
target_pool_name="k8s-target-pool"
http_health_check_name="k8s-hc"
external_address="k8s-external"

## firewall rule

allow_nginx="k8s-allow-nginx-service"
allow_internal="k8s-allow-internal"
allow_external="k8s-allow-external"
allow_health_check="k8s-allow-health-check"

## network
route_10_200_0_0_24="k8s-route_10_200_0_0_24"
route_10_200_1_0_24="k8s-route_10_200_1_0_24"
route_10_200_2_0_24="k8s-route_10_200_2_0_24"

subnet="k8s-subnet"
vpc="k8s-vpc"

KUBERNETES_HOSTNAMES="kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local"

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe $external_address --region $region --format 'value(address)')
# KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe controller-0-static-ip --region us-west1 --format 'value(address)')

## get internal IP
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)


