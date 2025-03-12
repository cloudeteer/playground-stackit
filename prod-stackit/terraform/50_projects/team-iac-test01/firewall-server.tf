resource "openstack_images_image_v2" "firewall" {
  name             = "pfsense-ce-2.7.2-amd64-10-12-2024"
  image_source_url = "https://pfsense.object.storage.eu01.onstackit.cloud/pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"
  web_download     = true
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "shared"
}

# resource "stackit_image" "firewall" { ## !! DOES NOT WORK
#   project_id = data.stackit_resourcemanager_project.this.project_id
#   labels     = merge(local.labels)

#   name            = "pfsense-ce-2.7.2-amd64-10-12-2024"
#   disk_format     = "qcow2"
#   local_file_path = "pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"

#   config = {}
# }

resource "stackit_server" "firewall" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name              = "firewall"
  machine_type      = "c1.1"
  availability_zone = "eu01-1"

  boot_volume = {
    size                  = 8
    source_type           = "image"
    source_id             = openstack_images_image_v2.firewall.id # stackit_image.firewall.image_id
    delete_on_termination = true
    performance_class     = "storage_premium_perf0"
  }
}

resource "stackit_public_ip" "firewall" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  network_interface_id = stackit_network_interface.firewall_wan.network_interface_id
  labels               = local.labels
}

resource "stackit_network" "firewall_wan" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name               = "firewall-wan"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = local.ipv4_nameservers
}

resource "stackit_network" "firewall_lan" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name               = "firewall-lan"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = local.ipv4_nameservers
}

resource "stackit_network_interface" "firewall_wan" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  network_id         = stackit_network.firewall_wan.network_id
  security_group_ids = [stackit_security_group.firewall_wan.security_group_id]
  labels             = local.labels
}

resource "stackit_network_interface" "firewall_lan" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  network_id         = stackit_network.firewall_lan.network_id
  security_group_ids = [stackit_security_group.firewall_lan.security_group_id]
  labels             = local.labels
}

resource "stackit_server_network_interface_attach" "firewall_wan" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  server_id            = stackit_server.firewall.server_id
  network_interface_id = stackit_network_interface.firewall_wan.network_interface_id
}

resource "stackit_server_network_interface_attach" "firewall_lan" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  server_id            = stackit_server.firewall.server_id
  network_interface_id = stackit_network_interface.firewall_lan.network_interface_id
}

resource "stackit_security_group" "firewall_wan" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name     = "firewall-wan"
  stateful = true
}

resource "stackit_security_group" "firewall_lan" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name     = "firewall-lan"
  stateful = true
}

resource "stackit_security_group_rule" "firewall_wan_default" {
  project_id        = data.stackit_resourcemanager_project.this.project_id
  security_group_id = stackit_security_group.firewall_wan.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"
}

resource "stackit_security_group_rule" "firewall_lan_default" {
  project_id        = data.stackit_resourcemanager_project.this.project_id
  security_group_id = stackit_security_group.firewall_lan.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"
}
