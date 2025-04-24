data "stackit_resourcemanager_project" "this" {
  count = local.any_feature_enabled ? 1 : 0

  project_id = "46fab7e3-b605-4b6f-b13c-5890a8ed1b75"
}
