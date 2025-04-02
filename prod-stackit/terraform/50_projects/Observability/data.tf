data "stackit_resourcemanager_project" "this" {
  project_id = "7642de78-ce95-48b0-877f-a986d8f92c67" # Observability
}

data "stackit_secretsmanager_instance" "this" {
  project_id  = "7642de78-ce95-48b0-877f-a986d8f92c67"
  instance_id = "01ca5493-090c-4ec5-ad68-7e31440f1ade"
}
