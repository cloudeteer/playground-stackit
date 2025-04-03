resource "stackit_image" "this" {
  project_id = var.project_id
  labels     = var.labels

  name            = "pfsense-ce-2.7.2-amd64-10-12-2024_stackit_image"
  disk_format     = "qcow2"
  local_file_path = "${path.module}/pfsense-ce-2.7.2-amd64-10-12-2024.qcow2"

  config = {
    # UEFI must be disabled for this image to boot correctly
    uefi = false
  }
}

resource "stackit_server" "this" {
  project_id = var.project_id
  labels     = var.labels

  name              = "firewall"
  machine_type      = "c1.1"
  availability_zone = "eu01-1"

  boot_volume = {
    size                  = 8
    source_type           = "image"
    source_id             = stackit_image.this.image_id
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
  name               = "wan"
  project_id         = var.project_id
  network_id         = stackit_network.wan.network_id
  security_group_ids = [stackit_security_group.wan.security_group_id]
  labels             = var.labels
}

resource "stackit_network_interface" "lan" {
  name               = "lan"
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

resource "stackit_server_backup_schedule" "hourly" {
  project_id = var.project_id
  server_id  = stackit_server.this.server_id

  enabled = true
  name    = "hourly"
  rrule   = "DTSTART;TZID=Europe/Berlin:19700101T000000 RRULE:FREQ=HOURLY;INTERVAL=1"

  backup_properties = {
    name             = "hourly"
    retention_period = 1
  }
}

resource "stackit_server_backup_schedule" "daily" {
  project_id = var.project_id
  server_id  = stackit_server.this.server_id

  enabled = true
  name    = "daily"
  rrule   = "DTSTART;TZID=Europe/Berlin:19700101T000000 RRULE:FREQ=DAILY;INTERVAL=1"

  backup_properties = {
    name             = "daily"
    retention_period = 7
  }
}

resource "stackit_server_backup_schedule" "weekly" {
  project_id = var.project_id
  server_id  = stackit_server.this.server_id

  enabled = true
  name    = "weekly"
  rrule   = "DTSTART;TZID=Europe/Berlin:19700101T000000 RRULE:FREQ=WEEKLY;INTERVAL=1"

  backup_properties = {
    name             = "weekly"
    retention_period = (7 * 5)
  }
}

resource "stackit_server_backup_schedule" "monthly" {
  project_id = var.project_id
  server_id  = stackit_server.this.server_id

  enabled = true
  name    = "monthly"
  rrule   = "DTSTART;TZID=Europe/Berlin:19700101T000000 RRULE:FREQ=MONTHLY;INTERVAL=1"

  backup_properties = {
    name             = "monthly"
    retention_period = (31 * 3)
  }
}
