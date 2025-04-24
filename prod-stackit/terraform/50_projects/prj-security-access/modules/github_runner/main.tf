### Network ###
resource "stackit_network" "example_non_routed_network" {
  project_id         = var.project_id
  name               = "hub-routed-network-phil"
  ipv4_prefix_length = 24
  ipv4_prefix        = "10.1.2.0/24"
  labels = {
    "creator"      = "roman"
    "joke"         = "true"
    "real-creator" = "phil"
  }
  routed = false
}
### Security Group ###
resource "stackit_security_group" "sec-group" {
  project_id = var.project_id
  name       = "GithubRunner"
  stateful   = true
}

# Already exists
# resource "stackit_security_group_rule" "rule" {
#   project_id        = var.project_id
#   security_group_id = stackit_security_group.sec-group.security_group_id
#   direction         = "egress"
#   ether_type        = "IPv4"
# }

resource "stackit_network_interface" "nic" {
  project_id = var.project_id
  network_id = stackit_network.example_non_routed_network.network_id
  security_group_ids = [stackit_security_group.sec-group.security_group_id]
}

resource "stackit_server" "server-with-network" {
  project_id = var.project_id
  name       = "github-runner"
  boot_volume = {
    size                  = 64
    source_type           = "image"
    source_id             = "882a8fdc-3bc9-403e-96e0-e1c92a8ed7a9"
    delete_on_termination = true
  }
  availability_zone = "eu01-1"
  machine_type      = "g1r.1d"
  keypair_name      = var.key_pair_name
}

