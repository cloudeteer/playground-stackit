locals {
  # Set dns_debug to true to enable public IP and SSH access
  dns_debug = false
}

data "cloudinit_config" "dns" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/dns-cloud-config.yaml")
  }
}

resource "time_sleep" "wait_5_minutes" {
  create_duration = "5m"

  triggers = {
    server_id = stackit_server.dns.server_id
  }
}

resource "stackit_server" "dns" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name = "dns"

  boot_volume = {
    size                  = 64
    source_type           = "image"
    source_id             = "117e8764-41c2-405f-aece-b53aa08b28cc" # Ubuntu 24.04
    delete_on_termination = true
  }

  machine_type      = "c1.1"
  availability_zone = "eu01-1"
  user_data         = data.cloudinit_config.dns.rendered

  # Set keypair only on debug mode
  keypair_name = local.dns_debug ? stackit_key_pair.default.name : null
}

resource "stackit_server_update_schedule" "dns" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  server_id  = time_sleep.wait_5_minutes.triggers["server_id"]

  name               = "default"
  enabled            = true
  maintenance_window = 1
  rrule              = "DTSTART;TZID=Europe/Berlin:20200803T023000 RRULE:FREQ=DAILY;INTERVAL=1"
}

resource "stackit_network" "dns" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name               = "dns"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
}

resource "stackit_network_interface" "dns" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  network_id         = stackit_network.dns.network_id
  security_group_ids = [stackit_security_group.dns.security_group_id]
  labels             = local.labels
}

resource "stackit_server_network_interface_attach" "dns" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  server_id            = stackit_server.dns.server_id
  network_interface_id = stackit_network_interface.dns.network_interface_id
}


resource "stackit_public_ip" "dns" {
  count                = local.dns_debug ? 1 : 0
  project_id           = data.stackit_resourcemanager_project.this.project_id
  network_interface_id = stackit_network_interface.dns.network_interface_id
  labels               = local.labels
}

resource "stackit_security_group" "dns" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  labels     = local.labels

  name        = "dns"
  description = "Security Group allowing DNS inbound traffic"
  stateful    = true
}

resource "stackit_security_group_rule" "dns" {
  project_id        = data.stackit_resourcemanager_project.this.project_id
  security_group_id = stackit_security_group.dns.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"

  # Do not restrict the ingress rule when debug mode is active (allows SSH among others)
  port_range = local.dns_debug ? null : {
    min = 53
    max = 53
  }
  protocol = local.dns_debug ? null : {
    name = "udp"
  }
}

