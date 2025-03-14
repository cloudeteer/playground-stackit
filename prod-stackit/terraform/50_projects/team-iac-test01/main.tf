#
# DNS
#

module "dns" {
  source = "./modules/dns"

  count = var.features.dns ? 1 : 0

  labels       = local.labels
  project_id   = data.stackit_resourcemanager_project.this.project_id
  keypair_name = stackit_key_pair.default.name

  debug = false
}

#
# SECURITY GROUP WITHOUT DEFAULT RULES
#

module "empty_security_group" {
  source = "./modules/empty_security_group"

  count = var.features.empty_security_group ? 1 : 0

  labels     = local.labels
  project_id = data.stackit_resourcemanager_project.this.project_id
}

#
# FIREWALL
#

module "firewall" {
  source = "./modules/firewall"

  count = var.features.firewall ? 1 : 0

  ipv4_nameservers = length(module.dns) == 1 ? module.dns[0].ipv4_nameservers : local.fallback_nameserver
  labels           = local.labels
  project_id       = data.stackit_resourcemanager_project.this.project_id
}

#
# LOAD BALANCER
#

module "load_balancer" {
  source = "./modules/load_balancer"

  count = var.features.load_balancer ? 1 : 0

  ipv4_nameservers = length(module.dns) == 1 ? module.dns[0].ipv4_nameservers : local.fallback_nameserver
  keypair_name     = stackit_key_pair.default.name
  labels           = local.labels
  project_id       = data.stackit_resourcemanager_project.this.project_id

  backend_server_count                   = 3
  backend_server_update_schedule_enabled = false
}
