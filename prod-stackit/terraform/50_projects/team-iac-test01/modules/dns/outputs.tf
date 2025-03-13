output "ipv4_nameservers" {
  value = [stackit_network_interface.this.ipv4]
}
