resource "stackit_server" "launchpad" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  name       = "launchpad"
  boot_volume = {
    size        = 64
    source_type = "image"

    # stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images |
    #   jq '.items[] | select(.name=="Ubuntu 24.04 ARM64")'
    # source_id = "882a8fdc-3bc9-403e-96e0-e1c92a8ed7a9" # Ubuntu 24.04 ARM64

    # stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images |
    #   jq '.items[] | select(.name=="Ubuntu 22.04")'
    source_id = "117e8764-41c2-405f-aece-b53aa08b28cc" # Ubuntu 24.04
  }
  # machine_type = "g1r.1d"
  machine_type = "g1.1"
  keypair_name = stackit_key_pair.launchpad.name
  user_data    = cloudinit_config.launchpad.rendered
}

resource "tls_private_key" "launchpad" {
  algorithm = "ED25519"
}

resource "stackit_key_pair" "launchpad" {
  name       = "launchpad"
  public_key = chomp(tls_private_key.launchpad.public_key_openssh)
}

resource "cloudinit_config" "launchpad" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "install_github_runner.sh"
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/assets/install_github_actions_runner.sh.tftpl", {
      runner_token = var.runner_token
    })
  }
}

resource "stackit_network" "launchpad" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  name               = "launchpad"
  ipv4_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
  ipv4_prefix_length = 24
}

resource "stackit_security_group" "launchpad" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  name       = "launchpad"
  stateful   = true
}

resource "stackit_security_group_rule" "launchpad" {
  project_id        = data.stackit_resourcemanager_project.this.project_id
  security_group_id = stackit_security_group.launchpad.security_group_id
  direction         = "ingress"
  ether_type        = "IPv4"
}

resource "stackit_network_interface" "launchpad" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  network_id         = stackit_network.launchpad.network_id
  security_group_ids = [stackit_security_group.launchpad.security_group_id]
}

resource "stackit_public_ip" "launchpad" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  network_interface_id = stackit_network_interface.launchpad.network_interface_id
}

resource "stackit_server_network_interface_attach" "launchpad" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  server_id            = stackit_server.launchpad.server_id
  network_interface_id = stackit_network_interface.launchpad.network_interface_id
}
