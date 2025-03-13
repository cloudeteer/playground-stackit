# prj-vpn-fw-test-firewall

> [!NOTE]
> This codebase is based on the [stackitcloud/terraform-pfsense-appliance](https://github.com/stackitcloud/terraform-pfsense-appliance/) repository, branch `sna`, commit `c6d1feaa9d00eed9b8b59e869a0fce87f64e7a5f`.

> [!IMPORTANT]
> Refer to the Keeper entry [prj-vpn-fw-test-firewall - Deployment Environment Variables](https://keepersecurity.eu/vault/#detail/QWR3P2yfM-nL6ILVxMuGWw) for the necessary deployment environment variables.

## CLOUDETEER Overrides

### Terraform Backend

The Terraform backend for this project is hosted in the [launchpad StackIT project](https://portal.stackit.cloud/projects/6b590d5d-f2ab-4584-9556-5ed8bbabb796), which is part of the [CLOUDETEER GmbH StackIT organization](https://portal.stackit.cloud/organization/6f0a04e7-8d5f-42a5-b1b3-89b8532126db).

### StackIT Authentication

We use StackIT's Key Flow authentication instead of the access token method provided by this Terraform code. The variables `stackit_service_account_key` (mandatory) and `stackit_service_account_private_key` (optional) are defined in `cloudeteer_addons.tf`. The variable `STACKIT_SERVICE_ACCOUNT_TOKEN` is not used, as a default value of `null` is set in the `cloudeteer_override.tf` file.

### StackIT Project

We use the data source `data.stackit_resourcemanager_project.this` defined in `cloudeteer_addons.tf` for the project ID reference. Additionally, we set a default value for the variable `STACKIT_PROJECT_ID` in `cloudeteer_override.tf`.

## GitHub Actions

We configure the environment variables `TF_VAR_PASSWORD`, `TF_VAR_TENANTID`, and `TF_VAR_USERNAME` in the `prod-stackit-terraform-50-prj-vpn-fw-test-firewall.yaml` GitHub Actions workflow. The values for these variables are securely stored in GitHub Secrets.
