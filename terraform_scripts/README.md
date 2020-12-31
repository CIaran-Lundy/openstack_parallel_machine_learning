This template creates multiple identical instances, each with a
floating IP address, and the number can be scaled up or down by
changing the "count" variable and reapplying the plan.

This shows the array syntax which is preferable to using `element()`,
so that when the template is scaled, the floating IPs on existing
instances are not affected. See
https://github.com/hashicorp/terraform/issues/3449#issuecomment-299335806

```
  floating_ip = "${element(openstack_networking_floatingip_v2.fip.*.address,count.index)}"
```
```
  floating_ip = "${openstack_networking_floatingip_v2.fip.*.address[count.index]}"
```

