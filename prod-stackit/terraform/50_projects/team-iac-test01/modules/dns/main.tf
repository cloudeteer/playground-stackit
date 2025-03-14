data "cloudinit_config" "this" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/cloud-config.yaml")
  }
}

resource "time_sleep" "this" {
  create_duration = "5m"

  triggers = {
    server_id = stackit_server.this.server_id
  }
}

resource "stackit_server" "this" {
  project_id = var.project_id
  labels     = var.labels

  name = "dns"

  boot_volume = {
    size                  = 25
    source_type           = "image"
    source_id             = "117e8764-41c2-405f-aece-b53aa08b28cc" # Ubuntu 24.04
    delete_on_termination = true
    performance_class     = "storage_premium_perf0"
  }

  machine_type      = "c1.1"
  availability_zone = "eu01-1"
  user_data         = data.cloudinit_config.this.rendered

  # Set keypair only on debug mode
  keypair_name = var.debug ? var.keypair_name : null
}

resource "stackit_server_update_schedule" "this" {
  project_id = var.project_id
  server_id  = time_sleep.this.triggers["server_id"]

  name               = "default"
  enabled            = true
  maintenance_window = 1
  rrule              = "DTSTART;TZID=Europe/Berlin:20200803T023000 RRULE:FREQ=DAILY;INTERVAL=1"
}

resource "stackit_network" "this" {
  project_id = var.project_id
  labels     = var.labels

  name               = "dns"
  ipv4_prefix_length = "29"
  ipv4_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
}

resource "stackit_network_interface" "this" {
  name               = "nic"
  project_id         = var.project_id
  network_id         = stackit_network.this.network_id
  security_group_ids = [stackit_security_group.this.security_group_id]
  labels             = var.labels
}

resource "stackit_server_network_interface_attach" "this" {
  project_id           = var.project_id
  server_id            = stackit_server.this.server_id
  network_interface_id = stackit_network_interface.this.network_interface_id
}


resource "stackit_public_ip" "this" {
  count                = var.debug ? 1 : 0
  project_id           = var.project_id
  network_interface_id = stackit_network_interface.this.network_interface_id
  labels               = var.labels
}

resource "stackit_security_group" "this" {
  project_id = var.project_id
  labels     = var.labels

  name        = "dns"
  description = "Security Group allowing DNS inbound traffic"
  stateful    = true
}

resource "stackit_security_group_rule" "this" {
  project_id        = var.project_id
  security_group_id = stackit_security_group.this.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"

  # Do not restrict the ingress rule when debug mode is active (allows SSH among others)
  port_range = var.debug ? null : {
    min = 53
    max = 53
  }
  protocol = var.debug ? null : {
    name = "udp"
  }
}

