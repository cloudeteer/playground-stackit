resource "stackit_security_group" "empty" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  name       = "empty"
}

resource "null_resource" "delete_security_group_rules" {
  triggers = {
    security_group_id = stackit_security_group.empty.security_group_id
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-ec"]

    command = join("; ", [
      "printf '%s' \"$TF_VAR_service_account_key\" > key.json 2>/dev/null",
      "stackit auth activate-service-account --service-account-key-path key.json >/dev/null 2>&1",
      "rm key.json >/dev/null 2>&1",
      join(" | ", [
        format(
          "stackit curl https://iaas.api.eu01.stackit.cloud/v1/projects/%s/security-groups/%s/rules",
          data.stackit_resourcemanager_project.this.project_id,
          stackit_security_group.empty.security_group_id
        ),
        "jq -r '.items[].id'",
        format(
          "xargs -L 1 -I %% stackit curl -X DELETE https://iaas.api.eu01.stackit.cloud/v1/projects/%s/security-groups/%s/rules/%%",
          data.stackit_resourcemanager_project.this.project_id,
          stackit_security_group.empty.security_group_id
        )
      ]),
      "stackit auth logout >/dev/null 2>&1",
    ])
  }
}
