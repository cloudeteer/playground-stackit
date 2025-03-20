# https://registry.terraform.io/providers/stackitcloud/stackit
provider "stackit" {

  # Region will be used as the default location for regional services.
  # Not all services require a region, some are global
  default_region = "eu01"

  # NOTE: There are no environment variables available for the parameters service_account_key and private_key.
  # Alternatively, we use TF_VAR_stackit_service_account_key and TF_VAR_stackit_service_account_private_key.

  # Service account key used for authentication
  service_account_key = var.stackit_service_account_key

  # Private RSA key used for authentication, relevant for the key flow.
  # It takes precedence over the private key that is included in the service account key.
  private_key = var.stackit_service_account_private_key

  # Enable beta resources.
  enable_beta_resources = true
}
