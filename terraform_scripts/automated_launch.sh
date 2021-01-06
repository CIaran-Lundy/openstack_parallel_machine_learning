#!/bin/bash


###############NOTE: deploy terraform scripts


terraform init
terraform apply -auto-approve


###############NOTE: add hosts to /etc/hosts and /etc/dsh/machines.list and record changes to changes file


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
	echo $floating_ip $instance_name >> etc_hosts_changes_file.txt
       	echo $floating_ip >> /etc/dsh/machines.list
	echo $floating_ip >> etc_dsh_machines_list_changes_file.txt

done

unset IFS


###############NOTE: get all ssh-keys in terraform.tfstate, make sure there is only 1, add it to /ect/dsh/dsh.conf


#TODO: find home_dir programmatically
ssh_dir_path="/home/ubuntu/.ssh/"

ssh_key_pair_names=$(cat terraform.tfstate | jq -r '.resources[] | select(.type=="openstack_compute_instance_v2") | .instances[].attributes.key_pair')


for key_pair in "${ssh_key_pair_names[@]}";
do
	ssh_key_pair_names_array=($key_pair)
	unique_ssh_key_pair_names_array=($(echo "${ssh_key_pair_names_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
	if [ "${#unique_ssh_key_pair_names_array[@]}" -gt 1 ];
	then
		echo "there are "${#unique_ssh_key_pair_names_array[@]}" unique keys"
		echo "key pairs are: "${unique_ssh_key_pair_names_array[@]}""
		#TODO: make the script die here (and run clean-up?) if there is more than 1 key
	fi
done

ssh_key_filename_and_path=$(echo $ssh_dir_path$(ls $ssh_dir_path | grep $(echo "${unique_ssh_key_pair_names_array}")))


###############NOTE: now use cloud-init to init the cloud

#do cloud things
