terraform {
  required_version = "~> 1.8"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.43"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Terraform Remote State Backend Configuration
  # https://developer.hashicorp.com/terraform/language/backend/s3#configuration
  backend "s3" {
    bucket = "launchpad"
    region = "eu01"
    key    = "prod-stackit/terraform/50_projects/team-iac-test01/terraform.tfstate"

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
