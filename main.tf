locals {
  vm_img = "/var/lib/libvirt/images/vm.img"
  vm_size = "120G"
}

# configure bridges
data "template_file" "bridge" {
    count = var.bridge_count
    template = file("bridge.tpl")
    vars =  {
      name        = "${var.bridges[count.index]["name"]}"
      ip          = "${var.bridges[count.index]["ip"]}"
      netmask     = "${var.bridges[count.index]["netmask"]}"
      range_start = "${var.bridges[count.index]["range_start"]}"
      range_end   = "${var.bridges[count.index]["range_end"]}"
    }
}

resource "local_file" "bridge" {
  count = var.bridge_count
  content = "${data.template_file.bridge[count.index]["rendered"]}"
  filename = "/tmp/bridge_${count.index}.xml"
}

resource "null_resource" "bridge" {
    count = var.bridge_count
    provisioner "local-exec" {
        command = <<EOT
virsh net-define /tmp/bridge_${count.index}.xml
virsh net-start ${var.bridges[count.index]["name"]}
EOT

    }
    depends_on = [local_file.bridge]
}


# configure vms
data "template_file" "vm_master" {
    count = var.master_count
    template = file("vm.tpl")
    vars =  {
      name                     = "${var.master_nodes[count.index]["name"]}"
      memory_gb                = "${var.master_nodes[count.index]["memory_gb"]}"
      vcpu                     = "${var.master_nodes[count.index]["vcpu"]}"
      vm_img                   = "${local.vm_img}"
      provisioning_bridge      = "${var.master_nodes[count.index]["provisioning_bridge"]}"
      baremetal_bridge         = "${var.master_nodes[count.index]["baremetal_bridge"]}"
      baremetal_mac_address    = "${var.master_nodes[count.index]["baremetal_mac_address"]}"
      provisioning_mac_address = "${var.master_nodes[count.index]["provisioning_mac_address"]}"
    }
}

resource "local_file" "vm_master" {
  count = var.master_count
  content = "${data.template_file.vm_master[count.index]["rendered"]}"
  filename = "/tmp/master_vm_${count.index}.xml"
}

resource "null_resource" "vm_master" {
    count = var.master_count
    provisioner "local-exec" {
        command = <<EOT
rm -f ${local.vm_img} || true
qemu-img create -f qcow2 ${local.vm_img} ${local.vm_size}
chown qemu:qemu ${local.vm_img}
virsh define  /tmp/master_vm_${count.index}.xml
vbmc add ${var.master_nodes[count.index]["name"]} --username ${var.master_nodes[count.index]["ipmi_user"]} --password ${var.master_nodes[count.index]["ipmi_password"]} --port ${var.master_nodes[count.index]["ipmi_port"]}
vbmc start ${var.master_nodes[count.index]["name"]}
EOT

    }
    depends_on = [local_file.vm_master, null_resource.bridge]
}

# destroy bridge
resource "null_resource" "bridge_destroy" {
    count = var.bridge_count
    provisioner "local-exec" {
        when = "destroy"
        command = <<EOT
virsh net-destroy ${var.bridges[count.index]["name"]}
virsh net-undefine ${var.bridges[count.index]["name"]}
EOT

    }
}

# destroy vm
resource "null_resource" "vm_master_destroy" {
    count = var.master_count
    provisioner "local-exec" {
        when = "destroy"
        command = <<EOT
virsh destroy ${var.master_nodes[count.index]["name"]} || true
virsh undefine ${var.master_nodes[count.index]["name"]} || true
vbmc stop ${var.master_nodes[count.index]["name"]}
vbmc delete ${var.master_nodes[count.index]["name"]}
EOT

    }
    depends_on = [null_resource.bridge_destroy]
}
