provider "vsphere" {
  # Username and password set through env vars VSPHERE_USER and VSPHERE_PASSWORD
  user     = var.vsphere_user
  password = var.vsphere_password

  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_resource_pool" "pool" {
  name                    = "${var.prefix}-cluster-pool"
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_folder" "folder" {
  path = "${var.folder}"
  type = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

module "kubernetes" {
  source = "./modules/kubernetes-cluster"

  prefix = var.prefix

  machines = var.machines

  ## HA Proxy ##
  haproxy_cores     = var.haproxy_cores
  haproxy_memory    = var.haproxy_memory
  haproxy_disk_size = var.haproxy_disk_size

  ## Master ##
  master_cores     = var.master_cores
  master_memory    = var.master_memory
  master_disk_size = var.master_disk_size

  ## Worker ##
  worker_cores     = var.worker_cores
  worker_memory    = var.worker_memory
  worker_disk_size = var.worker_disk_size

  ## Global ##

  gateway       = var.gateway
  dns_primary   = var.dns_primary
  dns_secondary = var.dns_secondary

  pool_id      = vsphere_resource_pool.pool.id
  datastore_id = data.vsphere_datastore.datastore.id

  folder                = var.folder
  guest_id              = data.vsphere_virtual_machine.template.guest_id
  scsi_type             = data.vsphere_virtual_machine.template.scsi_type
  network_id            = data.vsphere_network.network.id
  adapter_type          = data.vsphere_virtual_machine.template.network_interface_types[0]
  interface_name        = var.interface_name
  firmware              = var.firmware
  hardware_version      = var.hardware_version
  disk_thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  template_id = data.vsphere_virtual_machine.template.id
  vapp        = var.vapp

  ssh_public_keys = var.ssh_public_keys
}

#
# Generate ansible inventory
#

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    connection_strings_master = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s etcd_member_name=etcd%d",
      keys(module.kubernetes.master_ip),
      values(module.kubernetes.master_ip),
    range(1, length(module.kubernetes.master_ip) + 1))),
    connection_strings_worker = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s",
      keys(module.kubernetes.worker_ip),
    values(module.kubernetes.worker_ip))),
    list_master = join("\n", formatlist("%s", keys(module.kubernetes.master_ip))),
    list_worker = join("\n", formatlist("%s", keys(module.kubernetes.worker_ip)))
  })
  filename = var.inventory_file
}
/*
#===============================================================================
# Template files
#===============================================================================

# HAProxy hostname and ip list template #
data "template_file" "haproxy_hosts" {
  count    = "${length(var.vm_haproxy_ips)}"
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${var.prefix}-haproxy-${count.index}"
    host_ip  = "${lookup(var.vm_haproxy_ips, count.index)}"
  }
}

# Kubespray master hostname and ip list template #
data "template_file" "kubespray_hosts_master" {
  count    = "${length(var.vm_master_ips)}"
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${var.prefix}-master-${count.index}"
    host_ip  = "${lookup(var.vm_master_ips, count.index)}"
  }
}

# Kubespray worker hostname and ip list template #
data "template_file" "kubespray_hosts_worker" {
  count    = "${length(var.vm_worker_ips)}"
  template = "${file("templates/ansible_hosts.tpl")}"

  vars = {
    hostname = "${var.prefix}-worker-${count.index}"
    host_ip  = "${lookup(var.vm_worker_ips, count.index)}"
  }
}

# HAProxy hostname list template #
data "template_file" "haproxy_hosts_list" {
  count    = "${length(var.vm_haproxy_ips)}"
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${var.prefix}-haproxy-${count.index}"
  }
}

# Kubespray master hostname list template #
data "template_file" "kubespray_hosts_master_list" {
  count    = "${length(var.vm_master_ips)}"
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${var.prefix}-master-${count.index}"
  }
}

# Kubespray worker hostname list template #
data "template_file" "kubespray_hosts_worker_list" {
  count    = "${length(var.vm_worker_ips)}"
  template = "${file("templates/ansible_hosts_list.tpl")}"

  vars = {
    hostname = "${var.prefix}-worker-${count.index}"
  }
}

# HAProxy template #
data "template_file" "haproxy" {
  template = "${file("templates/haproxy.tpl")}"

  vars = {
    bind_ip = "${var.haproxy_vip}"
  }
}

# HAProxy server backend template #
data "template_file" "haproxy_backend" {
  count    = "${length(var.vm_master_ips)}"
  template = "${file("templates/haproxy_backend.tpl")}"

  vars = {
    prefix_server     = "${var.prefix}"
    backend_server_ip = "${lookup(var.vm_master_ips, count.index)}"
    count             = "${count.index}"
  }
}

# Keepalived master template #
data "template_file" "keepalived_master" {
  template = "${file("templates/keepalived_master.tpl")}"

  vars = {
    virtual_ip = "${var.haproxy_vip}"
  }
}

# Keepalived slave template #
data "template_file" "keepalived_slave" {
  template = "${file("templates/keepalived_slave.tpl")}"

  vars = {
    virtual_ip = "${var.haproxy_vip}"
  }
}

#===============================================================================
# Local Files
#===============================================================================

# Create Kubespray hosts.ini configuration file from Terraform templates #
resource "local_file" "kubespray_hosts" {
  content  = "${join("", data.template_file.haproxy_hosts.*.rendered)}${join("", data.template_file.kubespray_hosts_master.*.rendered)}${join("", data.template_file.kubespray_hosts_worker.*.rendered)}\n[haproxy]\n${join("", data.template_file.haproxy_hosts_list.*.rendered)}\n[kube-master]\n${join("", data.template_file.kubespray_hosts_master_list.*.rendered)}\n[etcd]\n${join("", data.template_file.kubespray_hosts_master_list.*.rendered)}\n[kube-node]\n${join("", data.template_file.kubespray_hosts_worker_list.*.rendered)}\n[k8s-cluster:children]\nkube-master\nkube-node"
  filename = "config/hosts.ini"
}

# Create HAProxy configuration from Terraform templates #
resource "local_file" "haproxy" {
  content  = "${data.template_file.haproxy.rendered}${join("", data.template_file.haproxy_backend.*.rendered)}"
  filename = "config/haproxy.cfg"
}

# Create Keepalived master configuration from Terraform templates #
resource "local_file" "keepalived_master" {
  content  = "${data.template_file.keepalived_master.rendered}"
  filename = "config/keepalived-master.cfg"
}

# Create Keepalived slave configuration from Terraform templates #
resource "local_file" "keepalived_slave" {
  content  = "${data.template_file.keepalived_slave.rendered}"
  filename = "config/keepalived-slave.cfg"
}
*/