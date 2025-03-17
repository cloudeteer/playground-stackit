data "stackit_resourcemanager_project" "this" {
  count = local.any_feature_enabled ? 1 : 0

  project_id = "341539db-8c67-43cf-ba1f-fd14157a0a5b"
}
