provision_networking_components() {

  ## vpc
  echo "[ GCP ] Provisioning a VPC"
  gcloud compute networks create k8s-vpc --subnet-mode custom

  ## subnet
  echo "[ GCP ] Provisioning a subnet with range 10.240.0.0/24"
  gcloud compute networks subnets create k8s-subnet \
    --network k8s-vpc \
    --range 10.240.0.0/24

  ## firewall rules
  echo "[ GCP ] Creating firewall rule for internal routing"
  gcloud compute firewall-rules create k8s-allow-internal \
    --allow tcp,udp,icmp \
    --network k8s-vpc \
    --source-ranges 10.240.0.0/24,10.200.0.0/16

  echo "[ GCP ] Creating firewall rule for external routing"
  gcloud compute firewall-rules create k8s-allow-external \
    --allow tcp:22,tcp:6443,icmp \
    --network k8s-vpc \
    --source-ranges 0.0.0.0/0

  ## list firewall rules
  echo "[ GCP ] Listing firewall rules"
  gcloud compute firewall-rules list --filter="network:k8s-vpc"

  ## create public IP
  echo "[ GCP ] Creating public IP"
  gcloud compute addresses create controller-0-static-ip --region us-west1

  ## list public IP
  echo "[ GCP ] Listing public IP"
  gcloud compute addresses list --filter="name=('k8s-pip')"

}

provision_controller_nodes() {

  for i in 0 1 2; do
    gcloud compute instances create controller-${i} \
      --async \
      --boot-disk-size 200GB \
      --can-ip-forward \
      --image-family ubuntu-2004-lts \
      --image-project ubuntu-os-cloud \
      --machine-type e2-standard-2 \
      --private-network-ip 10.240.0.1${i} \
      --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
      --subnet k8s \
      --tags k8s-thw,controller
  done

}

provision_worker_nodes() {

  for i in 0 1 2; do
    gcloud compute instances create worker-${i} \
      --async \
      --boot-disk-size 200GB \
      --can-ip-forward \
      --image-family ubuntu-2004-lts \
      --image-project ubuntu-os-cloud \
      --machine-type e2-standard-2 \
      --metadata pod-cidr=10.200.${i}.0/24 \
      --private-network-ip 10.240.0.2${i} \
      --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
      --subnet k8s \
      --tags k8s-thw,worker
  done

}

copy_security_keys_to_controller_nodes() {

  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem controller-0:~/
}

print_pod_cidr() {
  for instance in worker-0 worker-1; do
    gcloud compute instances describe ${instance} \
      --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
  done
}

list_k8s_nodes() {
  gcloud compute ssh controller-0 \
    --command "kubectl get nodes --kubeconfig admin.kubeconfig"
}

generate_kubeconfig_admin_user_localhost() {

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way

  ## print Kubernetes cluster version
  kubectl version

  ## get kubernetes nodes
  kubectl get nodes

}

create_network_routes() {
  for i in 0 1 2; do
    gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
      --network k8s-vpc \
      --next-hop-address 10.240.0.2${i} \
      --destination-range 10.200.${i}.0/24
  done
}

print_routes() {
  gcloud compute routes list --filter "network: k8s-vpc"
}

deploy_coredns() {
  kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns-1.8.yaml

  ## get pods created by kube-dns
  kubectl get pods -l k8s-app=kube-dns -n kube-system

  ## create busybox deployment
  kubectl run busybox --image=busybox:1.28 --command -- sleep 3600

  ## list pods created by busybox deployment
  kubectl get pods -l run=busybox

  ## get full pods name of busybox
  POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

  ## execute dns lookup inside busybox pod
  kubectl exec -ti $POD_NAME -- nslookup kubernetes

}

## smoke tests
verify_data_encryption() {

  ## create generic secret
  kubectl create secret generic kubernetes-the-hard-way \
    --from-literal="mykey=mydata"

  ## print hexdump
  gcloud compute ssh controller-0 \
    --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

}

create_nginx_deployment() {

  ## create nginx deployment
  kubectl create deployment nginx --image=nginx

  ## list pods
  kubectl get pods -l app=nginx

}

port_forwarding() {

  ## get nginx pod name
  POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")

  ## forward port
  kubectl port-forward $POD_NAME 8080:80

}

cleanup_environment() {
  # compute instances
  gcloud -q compute instances delete \
    controller-0 worker-0 worker-1 --zone us-west1-c

  ## networking
  ## external load balancer network resources
  gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule --region us-west1

  gcloud -q compute target-pools delete kubernetes-target-pool

  gcloud -q compute http-health-checks delete kubernetes

  gcloud -q compute addresses delete k8s-pip

  ## firewall rules
  gcloud -q compute firewall-rules delete \
    kubernetes-the-hard-way-allow-nginx-service \
    kubernetes-the-hard-way-allow-internal \
    kubernetes-the-hard-way-allow-external \
    kubernetes-the-hard-way-allow-health-check

  ## vpc
  gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
    kubernetes-route-10-200-1-0-24

  gcloud -q compute networks subnets delete kubernetes

  gcloud -q compute networks delete k8s-vpc

  ##  external IP
  gcloud -q compute addresses delete controller-0-static-ip --region us-west1

}
