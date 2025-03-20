resource "stackit_network_area" "hub_and_spoke_01" {
  organization_id = var.organization_id
  labels          = local.labels

  name                  = "hub-and-spoke-01"
  default_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
  default_prefix_length = 25
  max_prefix_length     = 29
  min_prefix_length     = 24
  transfer_network      = "10.255.1.0/24"

  network_ranges = [
    {
      prefix = "10.1.0.0/16"
    }
  ]
}
