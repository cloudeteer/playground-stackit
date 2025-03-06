locals {
  ssh_debug = false
}

resource "tls_private_key" "default" {
  algorithm = "ED25519"
}

resource "stackit_key_pair" "default" {
  name       = "default"
  public_key = chomp(tls_private_key.default.public_key_openssh)
}

output "tls_private_key" {
  description = "SSH Private Key, when ssh_debug is enabled – DO NOT DO THIS IN PRODUCTION! ;)"
  value       = local.ssh_debug ? nonsensitive(tls_private_key.default.private_key_openssh) : null
}
