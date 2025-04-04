#
# STACKIT Project
#

resource "stackit_resourcemanager_project" "this" {
  count = local.any_feature_enabled ? 1 : 0

  name                = "team-iac-test01"
  parent_container_id = "965b1adb-f3f9-4f46-9ee4-bc05682afe72" # Org: CLOUDETEER GmbH / Folder: Chapter OE
  owner_email         = jsondecode(var.stackit_service_account_key)["credentials"]["iss"]

  labels = {
    "ephemeral"   = "true"
    "networkArea" = data.stackit_network_area.this.network_area_id
  }
}

resource "stackit_authorization_project_role_assignment" "this" {
  for_each = local.any_feature_enabled ? toset([
    "al@cloudeteer.de",
    "pth@cloudeteer.de",
    "rs@cloudeteer.de",
    "se@cloudeteer.de",
  ]) : []

  resource_id = stackit_resourcemanager_project.this[0].project_id
  role        = "owner"
  subject     = each.value
}

#
# DNS
#

module "dns" {
  source = "./modules/dns"

  count = var.features.dns ? 1 : 0

  labels       = local.labels
  project_id   = one(stackit_resourcemanager_project.this[*].project_id)
  keypair_name = one(stackit_key_pair.default[*].name)

  debug = false
}

#
# SECURITY GROUP WITHOUT DEFAULT RULES
#

module "empty_security_group" {
  source = "./modules/empty_security_group"

  count = var.features.empty_security_group ? 1 : 0

  labels     = local.labels
  project_id = one(stackit_resourcemanager_project.this[*].project_id)
}

#
# FIREWALL
#

module "firewall" {
  source = "./modules/firewall"

  count = var.features.firewall ? 1 : 0

  ipv4_nameservers = length(module.dns) == 1 ? module.dns[0].ipv4_nameservers : local.fallback_nameserver
  labels           = local.labels
  project_id       = one(stackit_resourcemanager_project.this[*].project_id)
}

#
# LOAD BALANCER
#

module "load_balancer" {
  source = "./modules/load_balancer"

  count = var.features.load_balancer ? 1 : 0

  ipv4_nameservers = length(module.dns) == 1 ? module.dns[0].ipv4_nameservers : local.fallback_nameserver
  keypair_name     = one(stackit_key_pair.default[*].name)
  labels           = local.labels
  project_id       = one(stackit_resourcemanager_project.this[*].project_id)

  backend_server_count                   = 3
  backend_server_backup_schedule_enabled = false
  backend_server_update_schedule_enabled = false
}
