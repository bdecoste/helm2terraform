resource "kubernetes_service_account" "cilium" {
  metadata {
    name      = "cilium"
    namespace = "cilium"
  }
}

resource "kubernetes_service_account" "cilium_operator" {
  metadata {
    name      = "cilium-operator"
    namespace = "cilium"
  }
}

resource "kubernetes_service_account" "hubble_relay" {
  metadata {
    name      = "hubble-relay"
    namespace = "cilium"
  }
}

resource "kubernetes_service_account" "hubble_enterprise" {
  metadata {
    name      = "hubble-enterprise"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "hubble-enterprise"
      "helm.sh/chart"                = "hubble-enterprise-1.10.3"
    }
  }
}

resource "kubernetes_service_account" "hubble_ui" {
  metadata {
    name      = "hubble-ui"
    namespace = "cilium"
  }
}

