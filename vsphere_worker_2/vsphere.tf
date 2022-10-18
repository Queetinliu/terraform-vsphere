## Configure the vSphere Provider
provider "vsphere" {
    vsphere_server = var.vsphere_server
    user = var.vsphere_user
    password = var.vsphere_password
    allow_unverified_ssl = true
}

## Build VM
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}


data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_host}/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "worker" {
  count = "1"
  name   = "worker-${count.index + 2}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  guest_id = "centos7_64Guest"

  num_cpus   = 8
  memory     = 16384
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
   label            = "disk0"
   size             = 200
   eagerly_scrub    = false
   thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
	customize {
	linux_options {
        host_name = "worker-${count.index + 2}"
		domain    = "example.com"
      }
	
	network_interface {
        ipv4_address = "10.0.6.${105 + count.index}"
        ipv4_netmask = 24
      }
	ipv4_gateway = "10.0.6.254"
  }
}

}
