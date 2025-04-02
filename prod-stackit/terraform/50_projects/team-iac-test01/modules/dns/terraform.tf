terraform {
  required_version = "~> 1.8"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.46.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
