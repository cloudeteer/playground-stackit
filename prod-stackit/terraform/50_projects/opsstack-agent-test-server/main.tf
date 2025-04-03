resource "stackit_server" "agent_test" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  name       = "agent-test-vm"

  boot_volume = {
    size                  = 64
    source_type           = "image"
    delete_on_termination = true

    # stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images |
    #   jq '.items[] | select(.name=="Ubuntu 24.04 ARM64")'
    #source_id = "882a8fdc-3bc9-403e-96e0-e1c92a8ed7a9" # Ubuntu 24.04 ARM64

    # stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images |
    #   jq '.items[] | select(.name=="Ubuntu 22.04")'
    source_id = "117e8764-41c2-405f-aece-b53aa08b28cc" # Ubuntu 24.04
  }

  #machine_type = "g1r.1d" # ARM
  # the stackit server agent isnt available for arm yet
  machine_type = "g1.1" # X86

  availability_zone = "eu01-1" # eu01-1, eu01-2, eu03-3, eu01-m (Metro Zone is not available for ARM machine types)
  #keypair_name      = stackit_key_pair.agent_test.name
  user_data         = data.cloudinit_config.agent_test.rendered
}


data "cloudinit_config" "agent_test" {
  gzip          = false
  base64_encode = false

  part {
    filename = "install-stackit-server-agent.sh"
    content_type = "text/x-shellscript"
    content = file("${path.module}/assets/install_stackit_agent.sh")
  }

  #part {
  #  filename     = "download_opsstack_agent_setup.sh"
  #  content_type = "text/x-shellscript"

  #  content = templatefile("${path.module}/assets/download_opsstack_agent_setup.tftpl", {
  #    deepview_url = var.deepview_url
  #    agent_version = var.agent_version
  #    agent_login = var.agent_login
  #  })
  #}

}
resource "stackit_network" "agent_test" {
  project_id         = data.stackit_resourcemanager_project.this.project_id
  name               = "opsstack-agent-test"
  ipv4_nameservers   = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
  ipv4_prefix_length = 24
}

resource "stackit_security_group" "agent_test" {
  project_id = data.stackit_resourcemanager_project.this.project_id
  name               = "opsstack-agent-test"
  stateful   = true
}

resource "stackit_security_group_rule" "agent_test" {
  project_id        = data.stackit_resourcemanager_project.this.project_id
  security_group_id = stackit_security_group.agent_test.security_group_id
  direction         = "ingress"
  ether_type        = "IPv4"
}

resource "stackit_network_interface" "agent_test" {
  name               = "nic"
  project_id         = data.stackit_resourcemanager_project.this.project_id
  network_id         = stackit_network.agent_test.network_id
  security_group_ids = [stackit_security_group.agent_test.security_group_id]
}

resource "stackit_public_ip" "agent_test" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  network_interface_id = stackit_network_interface.agent_test.network_interface_id
}

resource "stackit_server_network_interface_attach" "agent_test" {
  project_id           = data.stackit_resourcemanager_project.this.project_id
  server_id            = stackit_server.agent_test.server_id
  network_interface_id = stackit_network_interface.agent_test.network_interface_id
}


resource "null_resource" "run_agent_install_script" {
  triggers = {
    body = jsonencode({
      commandTemplateName = "RunShellScript"
      parameters = {
        script    = <<-EOT
#!/bin/bash

set -eo pipefail
    retryCount=0
    while ! curl -H "Authorization: Basic ${var.agent_login}" --fail --fail-early -sSL "https://${var.deepview_url}/opsstack-agent/install/linux-${var.agent_version}.sh" -o linux-${var.agent_version}.sh; do
        retryCount=$((retryCount+1))

        if [ "$${retryCount}" -eq 100 ]; then
            echo "Request to $1 failed. Exiting" >&2
            exit 1
        fi
        echo "Request to $1 failed. Retrying in $((retryCount*2)) seconds"  >&2
        sleep $((retryCount*2));
    done

exec bash linux-${var.agent_version}.sh
        EOT
      }
    })
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-ec"]
    # wait a minute for the server agent to be online
    command = join("; ", [
      "sleep 60s",
      "printf '%s' \"$TF_VAR_stackit_service_account_key\" > ${path.cwd}/key.json",
      "stackit auth activate-service-account --service-account-key-path ${path.cwd}/key.json",
      "rm ${path.cwd}/key.json",
        format(
          "stackit curl -X POST https://run-command.api.eu01.stackit.cloud/v1/projects/%s/servers/%s/commands --data ${jsonencode(self.triggers.body)}",
          data.stackit_resourcemanager_project.this.project_id,
          stackit_server.agent_test.server_id
        )
      ,
      "stackit auth logout"
    ])
  }
}