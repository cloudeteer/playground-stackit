terraform {
  required_version = "~> 1.8"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.48.0"
    }
  }
}
