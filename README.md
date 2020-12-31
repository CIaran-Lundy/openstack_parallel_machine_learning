# openstack_parallel_machine_learning
using terraform to provision compute cluster, and spark mlib to run parallel ML

1) run terraform to create n instances with the following characteristics: 
  - ssh allowed with right sec groups  - port 22 open
  - sec groups for 4040 and 8080 so spark web UI is available
  - floating ip address associated
  - large enough for required work
  - running ubuntu
  
add all hosts to /etc/hosts
scp set up scripts to hosts
run set up scripts with dsh
