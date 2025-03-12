data "stackit_resourcemanager_project" "this" {
  project_id   = "321d4391-3983-424b-b9c2-064a46030474"
  container_id = "prj-vpn-fw-test-firewall"
}

# These variables are mandatory and used on the provider configuration above.
variable "service_account_key" {}
variable "private_key" { default = null }
