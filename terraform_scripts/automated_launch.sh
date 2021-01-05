#!/bin/bash


###############NOTE: deploy terraform scripts


#terraform init
#terraform apply -auto-approve

floating_ip_instance_info=($(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_floatingip_associate_v2") | .instances[].attributes.id'))


###############NOTE: add hosts to /etc/hosts and /etc/dsh/machines.list


IFS=/

for i in "${floating_ip_instance_info[@]}";
do
	values=($i)
	floating_ip=$(echo "${values[0]}")
	instance_id=$(echo "${values[1]}")
	echo $instance_id
	instance_name=$(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_instance_v2") | .instances[] | select(.attributes.id=="'$instance_id'") | .attributes.name')
	echo $floating_ip $instance_name >> /etc/hosts
       	echo $floating_ip >> /etc/dsh/machines.list	
done

unset IFS


###############NOTE: get all ssh-keys specified in terraform.tfstate


#TODO: find home_dir programmatically
ssh_dir_path="/home/ubuntu/.ssh/"

IFS=" "
ssh_key_pair_names=$(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_instance_v2") | .instances[].attributes.key_pair')

array_index=0
for key_pair in "${ssh_key_pair_names[@]}"
do
	echo $key_pair
	ssh_key_file_name=$(echo $ssh_dir_path$(ls $ssh_dir_path | grep $key_pair))
	ssh_key_file_names_array[arrayIndex]=$ssh_key_file_name
	array_index=$((k+1))
done

echo $ssh_key_file_names_array

#TODO: make set of unique values
#for i in "${ssh_key_pair_names[@]}"; do b["$i"]=1; done


#TODO: now scp required set-up scripts to hosts or run scripts via dsh
