terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.43.3"
    }
  }

  backend "s3" {
    bucket = "team-iac-test01-tfstate"
    key    = "terraform.tfstate"
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region                      = "eu01"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true

    # secret_key = null  # Set by ENV AWS_SECRET_ACCESS_KEY
    # access_key = null  # Set by ENV AWS_ACCESS_KEY_ID
  }
}

provider "stackit" {
  region              = "eu01"

  # Note: There are no environment variables available for these parameters.
  # Instead, we use TF_VAR_service_account_key and TF_VAR_private_key.
  service_account_key = var.service_account_key
  private_key         = var.private_key
}

data "stackit_resourcemanager_project" "team_iac_test01" {
  project_id   = "341539db-8c67-43cf-ba1f-fd14157a0a5b"
  container_id = "team-iac-test01"
}

output "project_name" {
  value = data.stackit_resourcemanager_project.team_iac_test01.name
}
