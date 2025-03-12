/*
Copyright 2023 Schwarz IT KG <markus.brunsch@mail.schwarz>
Copyright 2024 STACKIT GmbH & Co. KG <markus.brunsch@stackit.cloud>

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

# Create root Volume
resource "openstack_blockstorage_volume_v3" "fw_root_volume" {
  name              = "pfsense-2.7.2-root"
  description       = "Root Volume"
  size              = 16
  image_id          = openstack_images_image_v2.pfsense_image.id
  availability_zone = var.zone
  volume_type       = "storage_premium_perf4"
}

# Create virtual Server
resource "openstack_compute_instance_v2" "instance_fw" {
  name              = "pfSense" # Server name
  flavor_name       = var.flavor
  availability_zone = var.zone

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.fw_root_volume.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.wan_port_1.id
  }

  network {
    port = openstack_networking_port_v2.vpc_port_1.id
  }

}

# Network Ports
resource "openstack_networking_port_v2" "wan_port_1" {
  name                  = "FW WAN Port"
  network_id            = stackit_network.wan_network.network_id
  admin_state_up        = "true"
  port_security_enabled = "false"
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.wan_subnet_1.id
  }
}

resource "openstack_networking_port_v2" "vpc_port_1" {
  name                  = "FW VPC Port"
  network_id            = stackit_network.lan_network.network_id
  admin_state_up        = "true"
  port_security_enabled = "false"
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.vpc_subnet_1.id
  }
}


# Add FloatingIP
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "floating-net"
}

resource "openstack_networking_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_networking_port_v2.wan_port_1.id
}
