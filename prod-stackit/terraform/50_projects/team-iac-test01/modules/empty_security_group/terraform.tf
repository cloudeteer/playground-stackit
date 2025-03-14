terraform {
  required_version = "~> 1.8"

  required_providers {
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
