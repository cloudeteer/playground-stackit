data "stackit_resourcemanager_project" "this" {
  project_id   = "321d4391-3983-424b-b9c2-064a46030474"
  container_id = "prj-vpn-fw-test-firewall"
}

# These variables are mandatory and used on the provider configuration above.
variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}
