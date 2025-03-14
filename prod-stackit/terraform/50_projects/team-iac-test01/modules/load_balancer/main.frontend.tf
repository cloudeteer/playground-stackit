resource "stackit_loadbalancer" "frontend" {
  project_id = var.project_id

  name             = "load-balancer"
  external_address = stackit_public_ip.frontend.ip

  listeners = [
    {
      display_name = "tcp-80"
      port         = 80
      protocol     = "PROTOCOL_TCP"
      target_pool  = "backend"
    }
  ]

  networks = [
    # {
    #   network_id = stackit_network.frontend.network_id
    #   role       = "ROLE_LISTENERS"
    # },
    # {
    #   network_id = stackit_network.backend.network_id
    #   role       = "ROLE_TARGETS"
    # }
    {
      network_id = stackit_network.shared.network_id
      role       = "ROLE_LISTENERS_AND_TARGETS"
    }
  ]

  options = {
    private_network_only = false
  }

  target_pools = [
    {
      name        = "backend"
      target_port = 80

      targets = [
        for index, server in stackit_server.backend : {
          display_name = server.name
          ip           = stackit_network_interface.backend[index].ipv4
        }
      ]

      active_health_check = {
        healthy_threshold   = 10
        interval            = "3s"
        interval_jitter     = "3s"
        timeout             = "3s"
        unhealthy_threshold = 10
      }
    }
  ]
}

# resource "stackit_network" "frontend" {
#   project_id = var.project_id
#   labels     = var.labels

#   name               = "app"
#   ipv4_prefix_length = "29"
#   ipv4_nameservers   = var.ipv4_nameservers
# }

resource "stackit_network_interface" "frontend" {
  project_id = var.project_id
  labels     = var.labels

  # network_id = stackit_network.frontend.network_id
  network_id = stackit_network.shared.network_id
}

resource "stackit_public_ip" "frontend" {
  project_id           = var.project_id
  network_interface_id = stackit_network_interface.frontend.network_interface_id
  labels               = var.labels
}

resource "stackit_security_group" "frontend" {
  project_id = var.project_id
  labels     = var.labels

  name        = "load-balancer-frontend"
  stateful    = true
}

resource "stackit_security_group_rule" "frontend" {
  project_id        = var.project_id
  security_group_id = stackit_security_group.frontend.security_group_id

  direction  = "ingress"
  ether_type = "IPv4"

  port_range = {
    min = 80
    max = 80
  }

  protocol = {
    name = "tcp"
  }
}


#
# Workaround
#

