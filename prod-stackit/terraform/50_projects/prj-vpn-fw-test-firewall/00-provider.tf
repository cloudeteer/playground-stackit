/*
Copyright 2023 Schwarz IT KG <markus.brunsch@mail.schwarz>
Copyright 2024 STACKIT GmbH & Co. KG <markus.brunsch@stackit.cloud>

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.35.1"
    }
  }

  # Terraform Remote State Backend Configuration
  # https://developer.hashicorp.com/terraform/language/backend/s3#configuration
  backend "s3" {
    bucket = "launchpad"
    region = "eu01"
    key    = "prod-stackit/terraform/50_projects/prj-vpn-fw-test-firewall/terraform.tfstate"

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

# Configure the OpenStack Provider
provider "openstack" {
  user_name         = var.USERNAME
  tenant_id         = var.TENANTID
  user_domain_name  = "portal_mvp"
  project_domain_id = "portal_mvp"
  password          = var.PASSWORD
  auth_url          = "https://keystone.api.iaas.eu01.stackit.cloud/v3/"
  region            = "RegionOne"
}

provider "stackit" {
  region                = "eu01"
  service_account_token = var.STACKIT_SERVICE_ACCOUNT_TOKEN
}
