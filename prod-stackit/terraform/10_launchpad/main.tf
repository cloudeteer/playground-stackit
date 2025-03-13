terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.43"
    }
  }

  # Terraform Remote State Backend Configuration
  # https://developer.hashicorp.com/terraform/language/backend/s3#configuration
  backend "s3" {
    bucket = "launchpad"
    region = "eu01"
    key    = "prod-stackit/terraform/10_launchpad/terraform.tfstate"

    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }

    # AWS specific checks must be skipped as they do not work on STACKIT
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true

    # Credentials supplied by environment variables
    # access_key = null # AWS_ACCESS_KEY_ID
    # secret_key = null # AWS_SECRET_ACCESS_KEY
  }
}

provider "stackit" {

  # Region will be used as the default location for regional services.
  # Not all services require a region, some are global
  region = "eu01"

  # NOTE: There are no environment variables available for the parameters stackit_service_account_key and private_key.
  # Alternatively, we use TF_VAR_stackit_service_account_key and TF_VAR_stackit_service_account_private_key.

  # Service account key used for authentication
  service_account_key = var.stackit_service_account_key

  # Private RSA key used for authentication, relevant for the key flow.
  # It takes precedence over the private key that is included in the service account key.
  private_key = var.stackit_service_account_private_key

  # Enable beta resources.
  enable_beta_resources = true
}

# These variables are mandatory and used on the provider configuration above.
variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}
