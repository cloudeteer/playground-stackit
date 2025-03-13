variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "runner_token" {
  type      = string
  sensitive = true
}
