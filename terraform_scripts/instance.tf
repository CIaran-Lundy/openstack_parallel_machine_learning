variable "howmany" {
  default = 2
}

variable "flavor" {
  default = "m2.small"
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "subnet_1"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  admin_state_up      = true
  external_network_id = "79b16847-fb29-4870-9f18-0b06d6c2af70"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.howmany
  pool  = "public"
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "tf_wideopen"
  description = "wide open provisioned by terraform"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_compute_instance_v2" "cl25tf" {
  name  = format("cl25tf-%02d", count.index)
  count = var.howmany

  #image_id        = "2aa1d591-08ba-484a-8fd0-1f1499480092"
  image_id        = "5c5d6f0b-1e54-416e-a005-d01a2b3b8667"
  flavor_name     = var.flavor
  key_pair        = "cl25_theta_key"
  security_groups = [openstack_networking_secgroup_v2.secgroup.id]
  user_data       = format("#cloud-config\nhostname: cl25tf-%02d", count.index)

  network {
    #name = "network_1"
    # specify by uuid to avoid race
    uuid = openstack_networking_subnet_v2.subnet_1.network_id
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = var.howmany

  # it's important to use the array syntax not element(), or existing floating IPs
  # get deleted and recreated when howmany is changed and the plan is reapplied
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
  instance_id = openstack_compute_instance_v2.cl25tf[count.index].id
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.fip.*.address
}

output "private_ip" {
  value = openstack_compute_instance_v2.cl25tf.*.network.0.fixed_ip_v4
}

