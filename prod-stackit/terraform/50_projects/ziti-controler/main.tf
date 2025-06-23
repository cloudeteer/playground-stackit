resource "random_string" "prefix" {
  length  = 4
  special = false
  upper   = false
}

resource "stackit_dns_zone" "ziti_runs_on_stackit_cloud" {
  dns_name   = "ziti-${random_string.prefix.result}.runs.onstackit.cloud"
  name       = "ziti"
  project_id = stackit_resourcemanager_project.ziti_controller.project_id
}

resource "stackit_resourcemanager_project" "ziti_controller" {
  name                = "ziti-controller"
  owner_email         = "rs@cloudeteer.de"
  parent_container_id = "965b1adb-f3f9-4f46-9ee4-bc05682afe72"
}

resource "stackit_ske_cluster" "ziti_controller" {
  project_id = stackit_resourcemanager_project.ziti_controller.project_id
  name       = "ziti-${random_string.prefix.result}"

  node_pools = [
    {
      name               = "np-1"
      machine_type       = "c1.3"
      minimum            = "2"
      maximum            = "2"
      availability_zones = ["eu01-1"]
    }
  ]

  extensions = {
    dns = {
      enabled = true
      zones   = [stackit_dns_zone.ziti_runs_on_stackit_cloud.dns_name]
    }
  }

  maintenance = {
    enable_kubernetes_version_updates    = true
    enable_machine_image_version_updates = true
    start                                = "01:00:00Z"
    end                                  = "02:00:00Z"
  }
}

resource "stackit_ske_kubeconfig" "ziti_controller" {
  project_id   = stackit_resourcemanager_project.ziti_controller.project_id
  cluster_name = stackit_ske_cluster.ziti_controller.name
  refresh      = true
}

resource "local_sensitive_file" "kubeconfig" {
  content  = stackit_ske_kubeconfig.ziti_controller.kube_config
  filename = "${path.root}/.kubeconfig"
}

resource "helm_release" "ziti_controller" {
  name       = "ziti-controller"
  repository = "https://docs.openziti.io/helm-charts/"
  chart      = "ziti-controller"
  version    = "1.3.4"

  namespace        = "ziti-controller"
  create_namespace = true

  values = [
    <<-VALUES
    clientApi:
      advertisedHost: "controller.${stackit_dns_zone.ziti_runs_on_stackit_cloud.dns_name}"
      advertisedPort: 443
      service:
        annotations:
          external-dns.alpha.kubernetes.io/hostname: "controller.${stackit_dns_zone.ziti_runs_on_stackit_cloud.dns_name}"
    cert-manager:
      enabled: true
    trust-manager:
      enabled: true
      app:
        trust:
          namespace: "ziti-controller"
  VALUES
  ]
}
