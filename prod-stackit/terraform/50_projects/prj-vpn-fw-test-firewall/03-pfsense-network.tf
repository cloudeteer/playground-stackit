/*
Copyright 2023 Schwarz IT KG <markus.brunsch@mail.schwarz>
Copyright 2024 STACKIT GmbH & Co. KG <markus.brunsch@stackit.cloud>

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

# Get vNET Networks
resource "stackit_network" "lan_network" {
  project_id         = var.STACKIT_PROJECT_ID
  name               = "lan_network"
  ipv4_nameservers        = ["208.67.222.222", "9.9.9.9"]
  ipv4_prefix_length = 24
}

resource "stackit_network" "wan_network" {
  project_id         = var.STACKIT_PROJECT_ID
  name               = "wan_network"
  ipv4_nameservers        = ["208.67.222.222", "9.9.9.9"]
  ipv4_prefix_length = 28
}

# Get Subents
data "openstack_networking_subnet_v2" "vpc_subnet_1" {
  network_id  = stackit_network.lan_network.network_id
}

data "openstack_networking_subnet_v2" "wan_subnet_1" {
  network_id  = stackit_network.wan_network.network_id
}
