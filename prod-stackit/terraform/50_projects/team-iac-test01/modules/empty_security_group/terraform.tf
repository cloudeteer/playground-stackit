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
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
