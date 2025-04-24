#
# Github-runner
#

module "github_runner" {
  source = "./modules/github_runner"

  count = var.features.github_runner ? 1 : 0

  labels        = local.labels
  project_id = one(data.stackit_resourcemanager_project.this[*].project_id)
  key_pair_name = stackit_key_pair.default[0].name

  debug = false
}