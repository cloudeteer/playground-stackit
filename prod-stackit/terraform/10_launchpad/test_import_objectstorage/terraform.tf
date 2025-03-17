terraform {
  required_version = "~> 1.8"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.44"
    }
  }

  # Terraform Local State Backend Configuration
  backend "local" {}
}
