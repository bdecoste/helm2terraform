data "helm_template" "cilium_manifests" {

  name             = "cilium"
  namespace        = var.cilium_namespace
  repository       = "https://helm.isovalent.com"
  create_namespace = true
  chart            = "cilium"
  version          = var.cilium_version
  kube_version     = var.kube_version
  include_crds     = true
  
  values = [templatefile("${path.module}/values.yaml.tpl", {
    platform              = var.platform
    azure_subscription_id = var.azure_subscription_id
    azure_tenant_id       = var.azure_tenant_id
    azure_client_id       = var.azure_client_id
    azure_client_secret   = var.azure_client_secret

    debug = var.debug
    api_rate_limit_config        = var.api_rate_limit_config
    cluster_name                 = var.cluster_name
    identity_allocation_mode     = var.identity_allocation_mode
    identity_labels              = var.identity_labels
    enable_hubble                = var.enable_hubble
    prometheus_port              = var.prometheus_port
    enable_local_redirect_policy = var.enable_local_redirect_policy
    }
  )]
}

resource "local_file" "cilium_manifest" {
  filename = "./manifests.yaml"
  content  = data.helm_template.cilium_manifests.manifest
}
