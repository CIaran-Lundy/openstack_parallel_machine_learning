#!/bin/bash

#terraform init
#terraform apply -auto-approve

floating_ip_instance_info=($(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_floatingip_associate_v2") | .instances[].attributes.id'))


IFS=/

for i in "${floating_ip_instance_info[@]}";
do
	values=($i)
	floating_ip=$(echo "${values[0]}")
	instance_id=$(echo "${values[1]}")
	echo $instance_id
	instance_name=$(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_instance_v2") | .instances[] | select(.attributes.id=="'$instance_id'") | .attributes.name')
	echo $floating_ip $instance_name >> /etc/hosts 
done

