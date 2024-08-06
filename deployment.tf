resource "kubernetes_deployment" "cilium_operator" {
  metadata {
    name      = "cilium-operator"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/name"    = "cilium-operator"
      "app.kubernetes.io/part-of" = "cilium"
      "io.cilium/app"             = "operator"
      name                        = "cilium-operator"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "io.cilium/app" = "operator"
        name            = "cilium-operator"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "cilium-operator"
          "app.kubernetes.io/part-of" = "cilium"
          "io.cilium/app"             = "operator"
          name                        = "cilium-operator"
        }

        annotations = {
          "prometheus.io/port"   = "9963"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        volume {
          name = "cilium-config-path"

          config_map {
            name = "cilium-config"
          }
        }

        container {
          name    = "cilium-operator"
          image   = "quay.io/isovalent/operator-generic:v1.13.4-cee.1"
          command = ["cilium-operator-generic"]
          args    = ["--config-dir=/tmp/cilium/config-map", "--debug=$(CILIUM_DEBUG)"]

          port {
            name           = "prometheus"
            host_port      = 9963
            container_port = 9963
            protocol       = "TCP"
          }

          env {
            name = "K8S_NODE_NAME"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          env {
            name = "CILIUM_K8S_NAMESPACE"

            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }

          env {
            name = "CILIUM_DEBUG"

            value_from {
              config_map_key_ref {
                name     = "cilium-config"
                key      = "debug"
                optional = true
              }
            }
          }

          env {
            name  = "KUBERNETES_SERVICE_HOST"
            value = "10.0.0.1"
          }

          env {
            name  = "KUBERNETES_SERVICE_PORT"
            value = "443"
          }

          volume_mount {
            name       = "cilium-config-path"
            read_only  = true
            mount_path = "/tmp/cilium/config-map"
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "9234"
              host   = "127.0.0.1"
              scheme = "HTTP"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 3
            period_seconds        = 10
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"
        }

        restart_policy = "Always"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name            = "cilium-operator"
        automount_service_account_token = true
        host_network                    = true

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = {
                  "io.cilium/app" = "operator"
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        toleration {
          operator = "Exists"
        }

        priority_class_name = "system-cluster-critical"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }
  }
}

resource "kubernetes_deployment" "hubble_relay" {
  metadata {
    name      = "hubble-relay"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/name"    = "hubble-relay"
      "app.kubernetes.io/part-of" = "cilium"
      k8s-app                     = "hubble-relay"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "hubble-relay"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "hubble-relay"
          "app.kubernetes.io/part-of" = "cilium"
          k8s-app                     = "hubble-relay"
        }
      }

      spec {
        volume {
          name = "config"

          config_map {
            name = "hubble-relay-config"

            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }

        volume {
          name = "tls"

          projected {
            sources {
              secret {
                name = "hubble-relay-client-certs"

                items {
                  key  = "ca.crt"
                  path = "hubble-server-ca.crt"
                }

                items {
                  key  = "tls.crt"
                  path = "client.crt"
                }

                items {
                  key  = "tls.key"
                  path = "client.key"
                }
              }
            }

            default_mode = "0400"
          }
        }

        container {
          name    = "hubble-relay"
          image   = "quay.io/isovalent/hubble-relay:v1.13.4-cee.1"
          command = ["hubble-relay"]
          args    = ["serve", "--debug"]

          port {
            name           = "grpc"
            container_port = 4245
          }

          volume_mount {
            name       = "config"
            read_only  = true
            mount_path = "/etc/hubble-relay"
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/var/lib/hubble-relay/tls"
          }

          liveness_probe {
            tcp_socket {
              port = "grpc"
            }
          }

          readiness_probe {
            tcp_socket {
              port = "grpc"
            }
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 1

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "hubble-relay"

        affinity {
          pod_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = {
                  k8s-app = "cilium"
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
      }
    }
  }
}

resource "kubernetes_deployment" "hubble_ui" {
  metadata {
    name      = "hubble-ui"
    namespace = "cilium"

    labels = {
      k8s-app = "hubble-ui"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        k8s-app = "hubble-ui"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "hubble-ui"
        }
      }

      spec {
        volume {
          name = "hubble-ui-nginx-conf"

          config_map {
            name         = "hubble-ui-nginx"
            default_mode = "0644"
          }
        }

        container {
          name  = "frontend"
          image = "quay.io/isovalent/hubble-ui-enterprise:v0.17.6"

          port {
            name           = "http"
            container_port = 8081
          }

          volume_mount {
            name       = "hubble-ui-nginx-conf"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "nginx.conf"
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "backend"
          image = "quay.io/isovalent/hubble-ui-enterprise-backend:v0.17.6"

          port {
            name           = "grpc"
            container_port = 8090
          }

          env {
            name  = "EVENTS_SERVER_PORT"
            value = "8090"
          }

          env {
            name  = "FLOWS_API_ADDR"
            value = "hubble-relay:80"
          }

          env {
            name  = "GOPS_ENABLED"
            value = "false"
          }

          image_pull_policy = "Always"
        }

        service_account_name = "hubble-ui"

        security_context {
          run_as_user = 1001
          fs_group    = 1001
        }
      }
    }
  }
}

