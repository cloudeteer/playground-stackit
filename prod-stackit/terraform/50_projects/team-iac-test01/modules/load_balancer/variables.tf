variable "backend_server_count" { type = number }
variable "backend_server_update_schedule_enabled" { type = bool }
variable "ipv4_nameservers" { type = list(string) }
variable "keypair_name" { type = string }
variable "labels" { type = map(string) }
variable "project_id" { type = string }
