#!/bin/bash


terraform destroy


etc_hosts_changes_file=etc_hosts_changes_file.txt
etc_hosts_file="/etc/hosts"
while read line 
do
	del="$line" awk -i inplace '($0"") != ENVIRON["del"]' "$etc_hosts_file"
done < $etc_hosts_changes_file

rm $etc_hosts_changes_file
