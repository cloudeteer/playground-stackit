resource "stackit_security_group" "this" {
  project_id = var.project_id
  name       = "empty-security-group"
  labels     = var.labels
}

resource "null_resource" "delete_security_group_rules" {
  triggers = {
    security_group_id = stackit_security_group.this.security_group_id
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-ec"]

    command = join("; ", [
      "tmpfile=$(mktemp)",
      "chmod 600 \"$tmpfile\"",
      "printf '%s' \"$TF_VAR_stackit_service_account_key\" > \"$tmpfile\"",
      "stackit auth activate-service-account --service-account-key-path \"$tmpfile\"",
      "shred --remove \"$tmpfile\"", # Note: On macOS, install coreutils to enable the `shred` command (e.g., via `brew install coreutils`)
      join(" | ", [
        format(
          "stackit curl https://iaas.api.eu01.stackit.cloud/v1/projects/%s/security-groups/%s/rules",
          var.project_id,
          stackit_security_group.this.security_group_id
        ),
        "jq -r '.items[].id'",
        format(
          "xargs -L 1 -I %% stackit curl -X DELETE https://iaas.api.eu01.stackit.cloud/v1/projects/%s/security-groups/%s/rules/%%",
          var.project_id,
          stackit_security_group.this.security_group_id
        )
      ]),
      "stackit auth logout",
    ])
  }
}
