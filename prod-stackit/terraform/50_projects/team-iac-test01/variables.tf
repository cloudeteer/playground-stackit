variable "stackit_service_account_key" {
  type      = string
  sensitive = true
}

variable "stackit_service_account_private_key" {
  type      = string
  default   = null
  sensitive = true
}

variable "features" {
  type = object({
    dns                  = optional(bool, false)
    empty_security_group = optional(bool, false)
    firewall             = optional(bool, false)
  })
}
