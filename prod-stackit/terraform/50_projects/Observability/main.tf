resource "stackit_secretsmanager_user" "example" {
  project_id    = data.stackit_resourcemanager_project.this.project_id
  instance_id   = data.stackit_secretsmanager_instance.this.instance_id
  description   = "Example user"
  write_enabled = true
}

resource "vault_kv_secret_v2" "example" {
  mount               = data.stackit_secretsmanager_instance.this.instance_id
  name                = "my-terraform-secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
     grafana_password = "s3cr3t",
     #other_secret = ...,
    }
  )
}
