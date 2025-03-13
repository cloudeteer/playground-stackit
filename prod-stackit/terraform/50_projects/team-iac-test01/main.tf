#
# DNS
#
module "dns" {
  source = "./modules/dns"

  labels       = local.labels
  project_id   = data.stackit_resourcemanager_project.this.project_id
  keypair_name = stackit_key_pair.default.name

  debug = false
}

#
# FIREWALL
#

module "firewall" {
  source = "./modules/firewall"

  ipv4_nameservers = module.dns.ipv4_nameservers
  labels           = local.labels
  project_id       = data.stackit_resourcemanager_project.this.project_id
}


#
# SECURITY GROUP WITHOUT DEFAULT RULES
#

module "empty_security_group" {
  source = "./modules/empty_security_group"

  labels     = local.labels
  project_id = data.stackit_resourcemanager_project.this.project_id
}
