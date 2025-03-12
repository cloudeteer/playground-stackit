locals {
  ipv4_nameservers = [stackit_network_interface.dns.ipv4]
}
