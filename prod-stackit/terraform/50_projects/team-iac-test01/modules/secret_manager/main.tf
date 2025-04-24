resource "stackit_secretsmanager_instance" "sm_instance" {
  project_id = var.project_id
  name       = "secret-manager"
}

resource "stackit_secretsmanager_user" "sm_user" {
  project_id    = var.project_id
  instance_id   = stackit_secretsmanager_instance.sm_instance.instance_id
  description   = "Example user for SM"
  write_enabled = true
}

resource "vault_kv_secret_v2" "example" {
  mount               = stackit_secretsmanager_instance.sm_instance.instance_id
  name                = "my-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      grafana_password = "ijdijww",
      other_secret     = "hiiwpwnowf"
    }
  )
}

