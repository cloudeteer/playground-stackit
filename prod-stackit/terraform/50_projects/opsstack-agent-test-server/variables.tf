variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "agent_login" {
  type = string
  sensitive = true
  description = "Username and Password for the Agent User as hash "
}

variable "deepview_url" {
  type = string
  description = "Public URL of the Opsstack Deployment"
}

variable "agent_version" {
  type = string
  default = "latest"
}

