prefix = "k8s"

folder = "kubespray"

inventory_file = "inventory.ini"

network = "kubespray"

dns_primary = "10.0.20.72"
dns_secondary = "10.0.100.42"

machines = {
  "haproxy-0" : {
    "node_type" : "haproxy",
    "ip" : "10.0.51.141", # e.g. 192.168.0.5
    "netmask" : "24"
  },
  "haproxy-1" : {
    "node_type" : "haproxy",
    "ip" : "10.0.51.142", # e.g. 192.168.0.6
    "netmask" : "24"
  },
  "master-0" : {
    "node_type" : "master",
    "ip" : "10.0.51.150", # e.g. 192.168.0.10
    "netmask" : "24"
  },
  "worker-0" : {
    "node_type" : "worker",
    "ip" : "10.0.51.160", # e.g. 192.168.0.20
    "netmask" : "24"
  },
  "worker-1" : {
    "node_type" : "worker",
    "ip" : "10.0.51.161", # e.g. 192.168.0.21
    "netmask" : "24"
  }
}

gateway = "10.0.51.1" # e.g. 192.168.0.1

ssh_public_keys = [
  # Put your public SSH key here
  "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHuZ+lFvjFYMKrcPyWLOw9G09W0Etze6+f6vM164abVlatm0CGiaV/Y1f1t2mmQQH6xKl2K5Vx0yHjSfdNBd2o4yQA6se59RrwAtLNUAeFhSj7ideQEGQ1fuHXi107q5/VJc/1XPJ6o1qVD1uvAWOATwECOqP2qOuVLUlSQ9EDwbUHFuw== rodney@k8spray.poling.local",
]

vsphere_datacenter      = "Home"
vsphere_compute_cluster = "cluster01" # e.g. Cluster
vsphere_datastore       = "vmw-nfs" # e.g. ssd-000000
vsphere_server          = "vcenter.poling.local" # e.g. vsphere.server.com

template_name = "templates/ubuntu/packer-ubuntu-20.04" # e.g. ubuntu-bionic-18.04-cloudimg

vsphere_user = "administrator@home.local"
vsphere_password = "Yobiesa01!"