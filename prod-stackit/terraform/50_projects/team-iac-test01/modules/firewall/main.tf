resource "openstack_images_image_v2" "this" {
  name = "pfsense-ce-2.7.2-amd64-10-12-2024"

  image_source_url = "https://pfsense.object.storage.eu01.onstackit.cloud/pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"
  image_cache_path = "${path.root}/.terraform/image_cache"

  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "shared"
  web_download     = true
}

# resource "stackit_image" "this" { ## !! DOES NOT WORK
#   project_id = var.project_id
#   labels     = merge(var.labels)

#   name            = "pfsense-ce-2.7.2-amd64-10-12-2024"
#   disk_format     = "qcow2"
#   local_file_path = "pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"

#   config = {}
# }

resource "stackit_server" "this" {
  project_id = var.project_id
  labels     = var.labels

  name              = "firewall"
  machine_type      = "c1.1"
  availability_zone = "eu01-1"

  boot_volume = {
    size                  = 8
    source_type           = "image"
    source_id             = openstack_images_image_v2.this.id # stackit_image.this.image_id
    delete_on_termination = true
    performance_class     = "storage_premium_perf0"
  }
}

resource "stackit_public_ip" "this" {
  project_id           = var.project_id
  network_interface_id = stackit_network_interface.wan.network_interface_id
  labels               = var.labels
}

resource "stackit_network" "wan" {
  project_id = var.project_id
  labels     = var.labels

  name               = "firewall-wan"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = var.ipv4_nameservers
}

resource "stackit_network" "lan" {
  project_id = var.project_id
  labels     = var.labels

  name               = "firewall-lan"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = var.ipv4_nameservers
}

resource "stackit_network_interface" "wan" {
  project_id         = var.project_id
  network_id         = stackit_network.wan.network_id
  security_group_ids = [stackit_security_group.wan.security_group_id]
  labels             = var.labels
}

resource "stackit_network_interface" "lan" {
  project_id         = var.project_id
  network_id         = stackit_network.lan.network_id
  security_group_ids = [stackit_security_group.lan.security_group_id]
  labels             = var.labels
}

resource "stackit_server_network_interface_attach" "wan" {
  project_id           = var.project_id
  server_id            = stackit_server.this.server_id
  network_interface_id = stackit_network_interface.wan.network_interface_id
}

resource "stackit_server_network_interface_attach" "lan" {
  project_id           = var.project_id
  server_id            = stackit_server.this.server_id
  network_interface_id = stackit_network_interface.lan.network_interface_id
}

resource "stackit_security_group" "wan" {
  project_id = var.project_id
  labels     = var.labels

  name     = "firewall-wan"
  stateful = true
}

resource "stackit_security_group" "lan" {
  project_id = var.project_id
  labels     = var.labels

  name     = "firewall-lan"
  stateful = true
}

resource "stackit_security_group_rule" "wan" {
  project_id        = var.project_id
  security_group_id = stackit_security_group.wan.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"
}

resource "stackit_security_group_rule" "lan" {
  project_id        = var.project_id
  security_group_id = stackit_security_group.lan.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"
}
