resource "stackit_network" "example" {
  project_id = data.stackit_resourcemanager_project.team_iac_test01.project_id
  name       = "example-network"
}
