resource "kubernetes_cluster_role" "cilium" {
  metadata {
    name = "cilium"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces", "services", "pods", "endpoints", "nodes"]
  }

  rule {
    verbs      = ["list", "watch", "get"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumloadbalancerippools", "ciliumbgppeeringpolicies", "ciliumclusterwideenvoyconfigs", "ciliumclusterwidenetworkpolicies", "ciliumegressgatewaypolicies", "ciliumendpoints", "ciliumendpointslices", "ciliumenvoyconfigs", "ciliumidentities", "ciliumlocalredirectpolicies", "ciliumnetworkpolicies", "ciliumnodes", "ciliumsrv6egresspolicies", "ciliumsrv6vrfs", "ciliumnodeconfigs", "ciliumcidrgroups"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["isovalent.com"]
    resources  = ["isovalentegressgatewaypolicies"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumidentities", "ciliumendpoints", "ciliumnodes", "ciliumsrv6egresspolicies"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumidentities"]
  }

  rule {
    verbs      = ["delete", "get"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumendpoints", "ciliumsrv6egresspolicies"]
  }

  rule {
    verbs      = ["get", "update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnodes", "ciliumnodes/status"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnetworkpolicies/status", "ciliumclusterwidenetworkpolicies/status", "ciliumendpoints/status", "ciliumendpoints"]
  }
}

resource "kubernetes_cluster_role" "cilium_operator" {
  metadata {
    name = "cilium-operator"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  rule {
    verbs      = ["get", "list", "watch", "delete"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }

  rule {
    verbs      = ["update", "patch"]
    api_groups = [""]
    resources  = ["services/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services", "endpoints"]
  }

  rule {
    verbs      = ["watch", "list"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumegressgatewaypolicies"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumegressgatewaypolicies/status"]
  }

  rule {
    verbs      = ["watch", "list"]
    api_groups = ["isovalent.com"]
    resources  = ["isovalentegressgatewaypolicies"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["isovalent.com"]
    resources  = ["isovalentegressgatewaypolicies/status"]
  }

  rule {
    verbs      = ["create", "update", "deletecollection", "patch", "get", "list", "watch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnetworkpolicies", "ciliumclusterwidenetworkpolicies"]
  }

  rule {
    verbs      = ["patch", "update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnetworkpolicies/status", "ciliumclusterwidenetworkpolicies/status"]
  }

  rule {
    verbs      = ["delete", "list", "watch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumendpoints", "ciliumidentities"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumidentities"]
  }

  rule {
    verbs      = ["create", "update", "get", "list", "watch", "delete"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnodes"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumnodes/status"]
  }

  rule {
    verbs      = ["create", "update", "get", "list", "watch", "delete", "patch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumendpointslices", "ciliumenvoyconfigs"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs          = ["update"]
    api_groups     = ["apiextensions.k8s.io"]
    resources      = ["customresourcedefinitions"]
    resource_names = ["ciliumloadbalancerippools.cilium.io", "ciliumbgppeeringpolicies.cilium.io", "ciliumclusterwideenvoyconfigs.cilium.io", "ciliumclusterwidenetworkpolicies.cilium.io", "ciliumegressgatewaypolicies.cilium.io", "ciliumendpoints.cilium.io", "ciliumendpointslices.cilium.io", "ciliumenvoyconfigs.cilium.io", "ciliumexternalworkloads.cilium.io", "ciliumidentities.cilium.io", "ciliumlocalredirectpolicies.cilium.io", "ciliumnetworkpolicies.cilium.io", "ciliumnodes.cilium.io", "ciliumnodeconfigs.cilium.io", "ciliumcidrgroups.cilium.io", "isovalentfqdngroups.isovalent.com", "isovalentegressgatewaypolicies.isovalent.com"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumloadbalancerippools"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumloadbalancerippools/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["isovalent.com"]
    resources  = ["isovalentfqdngroups"]
  }

  rule {
    verbs      = ["create", "patch", "delete"]
    api_groups = ["cilium.io"]
    resources  = ["ciliumcidrgroups"]
  }

  rule {
    verbs      = ["create", "get", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_cluster_role" "hubble_enterprise" {
  metadata {
    name = "hubble-enterprise"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "hubble-enterprise"
      "helm.sh/chart"                = "hubble-enterprise-1.10.3"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cilium.io", "isovalent.com"]
    resources  = ["tracingpolicies", "tracingpoliciesnamespaced"]
  }

  rule {
    verbs      = ["create", "get", "list"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs          = ["update"]
    api_groups     = ["apiextensions.k8s.io"]
    resources      = ["customresourcedefinitions"]
    resource_names = ["tracingpolicies.cilium.io", "tracingpoliciesnamespaced.cilium.io", "tracingpolicies.isovalent.com"]
  }
}

resource "kubernetes_cluster_role" "hubble_ui" {
  metadata {
    name = "hubble-ui"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["componentstatuses", "endpoints", "namespaces", "nodes", "pods", "services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cilium.io"]
    resources  = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "cilium" {
  metadata {
    name = "cilium"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium"
    namespace = "cilium"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cilium"
  }
}

resource "kubernetes_cluster_role_binding" "cilium_operator" {
  metadata {
    name = "cilium-operator"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium-operator"
    namespace = "cilium"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cilium-operator"
  }
}

resource "kubernetes_cluster_role_binding" "hubble_enterprise" {
  metadata {
    name = "hubble-enterprise"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "hubble-enterprise"
      "helm.sh/chart"                = "hubble-enterprise-1.10.3"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "hubble-enterprise"
    namespace = "cilium"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "hubble-enterprise"
  }
}

resource "kubernetes_cluster_role_binding" "hubble_ui" {
  metadata {
    name = "hubble-ui"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "hubble-ui"
    namespace = "cilium"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "hubble-ui"
  }
}

resource "kubernetes_role" "cilium_config_agent" {
  metadata {
    name      = "cilium-config-agent"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
}

resource "kubernetes_role_binding" "cilium_config_agent" {
  metadata {
    name      = "cilium-config-agent"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/part-of" = "cilium"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cilium"
    namespace = "cilium"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cilium-config-agent"
  }
}

