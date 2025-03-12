/*
Copyright 2023 Schwarz IT KG <markus.brunsch@mail.schwarz>
Copyright 2024 STACKIT GmbH & Co. KG <markus.brunsch@stackit.cloud>

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
*/

#
# Custom User Settings
#

# OpenStack Availability Zone
variable "zone" {
  type        = string
  description = ""
  default     = "eu01-m"
}

# OpenStack VM Flavor
variable "flavor" {
  type        = string
  description = ""
  default     = "c1.2"
}

# Local VPC Subnet to create OpenStack Network
variable "LOCAL_SUBNET" {
  type        = string
  description = ""
  default     = "10.0.0.0/24"
}

############################################

#
# System Settings (do not edit)
#

# OpenStack UAT Username
variable "USERNAME" {
  type        = string
  description = ""
}

# OpenStack Project ID
variable "TENANTID" {
  type        = string
  description = ""
}

# OpenStack UAT Password
variable "PASSWORD" {
  type        = string
  description = ""
}

# STACKIT ProjectID
variable "STACKIT_PROJECT_ID" {
  type        = string
  description = ""
}

# STACKIT Service Account Token
variable "STACKIT_SERVICE_ACCOUNT_TOKEN" {
  type        = string
  description = ""
}
