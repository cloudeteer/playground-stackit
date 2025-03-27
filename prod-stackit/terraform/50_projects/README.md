# StackIT Projects

StackIT organizes projects similarly to a combination of Azure Subscriptions and Resource Groups. In StackIT, there is no direct equivalent to an Azure Subscription, and Azure Resource Groups are referred to as StackIT Projects.

Our StackIT Playground and StackIT Organization include a Launchpad, which currently consists of:

- An Object Storage (S3-compatible) for storing Terraform state files.
- A Service Account with Owner rights on our StackIT Organization.

This Service Account is used in this repository for all Terraform deployments via GitHub Actions. Additionally, the Object Storage from the Launchpad serves as the Terraform Remote Backend for all deployments.

## Creating a New StackIT Project with Terraform

To create a new project using Terraform, follow these steps:

1. Create a new directory with the project name inside /prod-stackit/terraform/50_projects/.

2. Create the necessary Terraform configuration files:
   - `terraform.tf`
   - `providers.tf`
   - `variables.tf`

### Quick Start Configuration

`terraform.tf`

```hcl
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
```

`providers.tf`

```hcl
# https://registry.terraform.io/providers/stackitcloud/stackit
provider "stackit" {

  # Region will be used as the default location for regional services.
  # Not all services require a region, some are global
  default_region = "eu01"

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
```

`variables.tf`

```hcl
variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}
```

## Handling Credentials

To avoid hardcoding credentials, use environment variables. The following variables are required:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `TF_VAR_service_account_key`
- `TF_VAR_private_key` (optional, if the private key is included in `TF_VAR_stackit_service_account_key`)

These environment variables are automatically populated from GitHub Secrets during GitHub Actions workflows.

## Running Terraform Locally

Executing Terraform locally is permitted and encouraged, as this is a playground environment. However, environment variables must be set manually without exposing credentials in the code. To manage environment variables securely:

1. Use the tool direnv to automatically load environment variables from an .envrc file.

2. Alternatively, manually load an .envrc file with source .envrc.

3. Ensure .envrc is included in .gitignore to prevent it from being tracked by Git.

Example `.envrc` File

```env
export AWS_ACCESS_KEY_ID=AAAAAAAAAAAAAAAAAAAA
export AWS_SECRET_ACCESS_KEY=qwertyuiopasdfghjkl/zxcvbnm1234567890101
export TF_VAR_service_account_key='{JSON}'
```
