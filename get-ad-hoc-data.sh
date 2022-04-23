#!/bin/bash

declare -a instance_list

instance_list=$(gcloud compute instances list | awk 'NR>1 {print $1}')

for i in ${instance_list[@]}; do
    if [ $i == "controller-0" ]; then
        gcloud compute instances describe $i --format 'value(networkInterfaces.accessConfigs[0].natIP)'
    fi
done
