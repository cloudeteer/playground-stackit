resource "stackit_network" "shared" {
  project_id = var.project_id
  labels     = var.labels

  name               = "this"
  ipv4_prefix_length = "28"
  ipv4_nameservers   = var.ipv4_nameservers
}
