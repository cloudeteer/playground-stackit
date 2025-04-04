#
# File: 00-provider.tf
#

terraform {

  # Terraform Remote State Backend Configuration
  # https://developer.hashicorp.com/terraform/language/backend/s3#configuration
  backend "s3" {
    bucket = "launchpad"
    region = "eu01"
    key    = "prod-stackit/terraform/50_projects/prj-vpn-fw-test-firewall/terraform.tfstate"

    # Use service side encryption
    # - https://docs.stackit.cloud/stackit/en/encryption-204342585.html#Encryption-SSE
    encrypt = true

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

#
# File: 01-config.tf
#

variable "STACKIT_PROJECT_ID" {
  type        = string
  description = "Replaced by data.stackit_resourcemanager_project.this"
  default     = null
}

variable "STACKIT_SERVICE_ACCOUNT_TOKEN" {
  type        = string
  description = "NOT USED"
  default     = null
}

#
# File: 03-pfsense-network.tf
#

resource "stackit_network" "lan_network" {
  project_id = data.stackit_resourcemanager_project.this.project_id
}

resource "stackit_network" "wan_network" {
  project_id = data.stackit_resourcemanager_project.this.project_id
}
