resource "tls_private_key" "default" {
  count = local.any_feature_enabled ? 1 : 0

  algorithm = "ED25519"
}

resource "stackit_key_pair" "default" {
  count = local.any_feature_enabled ? 1 : 0

  name       = "default"
  public_key = chomp(tls_private_key.default[0].public_key_openssh)
}

resource "local_sensitive_file" "id_ed25519" {
  count = local.any_feature_enabled ? 1 : 0

  content  = tls_private_key.default[0].private_key_openssh
  filename = "${path.root}/id_ed25519"
}
