resource "tls_private_key" "default" {
  algorithm = "ED25519"
}

resource "stackit_key_pair" "default" {
  name       = "default"
  public_key = chomp(tls_private_key.default.public_key_openssh)
}

resource "local_file" "id_ed25519" {
  content  = tls_private_key.default.private_key_openssh
  filename = "${path.root}/id_ed25519"
}
