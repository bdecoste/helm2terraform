resource "kubernetes_daemonset" "cilium" {
  metadata {
    name      = "cilium"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/name"    = "cilium-agent"
      "app.kubernetes.io/part-of" = "cilium"
      k8s-app                     = "cilium"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "cilium"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "cilium-agent"
          "app.kubernetes.io/part-of" = "cilium"
          k8s-app                     = "cilium"
        }

        annotations = {
          "container.apparmor.security.beta.kubernetes.io/apply-sysctl-overwrites" = "unconfined"
          "container.apparmor.security.beta.kubernetes.io/cilium-agent"            = "unconfined"
          "container.apparmor.security.beta.kubernetes.io/clean-cilium-state"      = "unconfined"
          "container.apparmor.security.beta.kubernetes.io/mount-cgroup"            = "unconfined"
          "prometheus.io/port"                                                     = "9962"
          "prometheus.io/scrape"                                                   = "true"
        }
      }

      spec {
        volume {
          name      = "tmp"
        }

        volume {
          name = "cilium-run"

          host_path {
            path = "/var/run/cilium"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "bpf-maps"

          host_path {
            path = "/sys/fs/bpf"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "hostproc"

          host_path {
            path = "/proc"
            type = "Directory"
          }
        }

        volume {
          name = "cilium-cgroup"

          host_path {
            path = "/run/cilium/cgroupv2"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "cni-path"

          host_path {
            path = "/opt/cni/bin"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "etc-cni-netd"

          host_path {
            path = "/etc/cni/net.d"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "lib-modules"

          host_path {
            path = "/lib/modules"
          }
        }

        volume {
          name = "xtables-lock"

          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }

        volume {
          name = "clustermesh-secrets"

          projected {
            sources {
              secret {
                name     = "cilium-clustermesh"
                optional = true
              }
            }

            sources {
              secret {
                name = "clustermesh-apiserver-remote-cert"

                items {
                  key  = "tls.key"
                  path = "common-etcd-client.key"
                }

                items {
                  key  = "tls.crt"
                  path = "common-etcd-client.crt"
                }

                items {
                  key  = "ca.crt"
                  path = "common-etcd-client-ca.crt"
                }

                optional = true
              }
            }

            default_mode = "0400"
          }
        }

        volume {
          name = "host-proc-sys-net"

          host_path {
            path = "/proc/sys/net"
            type = "Directory"
          }
        }

        volume {
          name = "host-proc-sys-kernel"

          host_path {
            path = "/proc/sys/kernel"
            type = "Directory"
          }
        }

        volume {
          name = "hubble-tls"

          projected {
            sources {
              secret {
                name = "hubble-server-certs"

                items {
                  key  = "ca.crt"
                  path = "client-ca.crt"
                }

                items {
                  key  = "tls.crt"
                  path = "server.crt"
                }

                items {
                  key  = "tls.key"
                  path = "server.key"
                }

                optional = true
              }
            }

            default_mode = "0400"
          }
        }

        init_container {
          name    = "config"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["cilium", "build-config"]

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
            name  = "KUBERNETES_SERVICE_HOST"
            value = "10.0.0.1"
          }

          env {
            name  = "KUBERNETES_SERVICE_PORT"
            value = "443"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"
        }

        init_container {
          name    = "mount-cgroup"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["sh", "-ec", "cp /usr/bin/cilium-mount /hostbin/cilium-mount;\nnsenter --cgroup=/hostproc/1/ns/cgroup --mount=/hostproc/1/ns/mnt \"$${BIN_PATH}/cilium-mount\" $CGROUP_ROOT;\nrm /hostbin/cilium-mount\n"]

          env {
            name  = "CGROUP_ROOT"
            value = "/run/cilium/cgroupv2"
          }

          env {
            name  = "BIN_PATH"
            value = "/opt/cni/bin"
          }

          volume_mount {
            name       = "hostproc"
            mount_path = "/hostproc"
          }

          volume_mount {
            name       = "cni-path"
            mount_path = "/hostbin"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["SYS_ADMIN", "SYS_CHROOT", "SYS_PTRACE"]
              drop = ["ALL"]
            }
          }
        }

        init_container {
          name    = "apply-sysctl-overwrites"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["sh", "-ec", "cp /usr/bin/cilium-sysctlfix /hostbin/cilium-sysctlfix;\nnsenter --mount=/hostproc/1/ns/mnt \"$${BIN_PATH}/cilium-sysctlfix\";\nrm /hostbin/cilium-sysctlfix\n"]

          env {
            name  = "BIN_PATH"
            value = "/opt/cni/bin"
          }

          volume_mount {
            name       = "hostproc"
            mount_path = "/hostproc"
          }

          volume_mount {
            name       = "cni-path"
            mount_path = "/hostbin"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["SYS_ADMIN", "SYS_CHROOT", "SYS_PTRACE"]
              drop = ["ALL"]
            }
          }
        }

        init_container {
          name    = "mount-bpf-fs"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["/bin/bash", "-c", "--"]
          args    = ["mount | grep \"/sys/fs/bpf type bpf\" || mount -t bpf bpf /sys/fs/bpf"]

          volume_mount {
            name              = "bpf-maps"
            mount_path        = "/sys/fs/bpf"
            mount_propagation = "Bidirectional"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            privileged = true
          }
        }

        init_container {
          name    = "clean-cilium-state"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["/init-container.sh"]

          env {
            name = "CILIUM_ALL_STATE"

            value_from {
              config_map_key_ref {
                name     = "cilium-config"
                key      = "clean-cilium-state"
                optional = true
              }
            }
          }

          env {
            name = "CILIUM_BPF_STATE"

            value_from {
              config_map_key_ref {
                name     = "cilium-config"
                key      = "clean-cilium-bpf-state"
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

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "bpf-maps"
            mount_path = "/sys/fs/bpf"
          }

          volume_mount {
            name              = "cilium-cgroup"
            mount_path        = "/run/cilium/cgroupv2"
            mount_propagation = "HostToContainer"
          }

          volume_mount {
            name       = "cilium-run"
            mount_path = "/var/run/cilium"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["NET_ADMIN", "SYS_MODULE", "SYS_ADMIN", "SYS_RESOURCE"]
              drop = ["ALL"]
            }
          }
        }

        init_container {
          name    = "install-cni-binaries"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["/install-plugin.sh"]

          resources {
            requests = {
              cpu    = "100m"
              memory = "10Mi"
            }
          }

          volume_mount {
            name       = "cni-path"
            mount_path = "/host/opt/cni/bin"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }
          }
        }

        container {
          name    = "cilium-agent"
          image   = "quay.io/isovalent/cilium:v1.13.4-cee.1"
          command = ["cilium-agent"]
          args    = ["--config-dir=/tmp/cilium/config-map"]

          port {
            name           = "peer-service"
            host_port      = 4244
            container_port = 4244
            protocol       = "TCP"
          }

          port {
            name           = "prometheus"
            host_port      = 9962
            container_port = 9962
            protocol       = "TCP"
          }

          port {
            name           = "envoy-metrics"
            host_port      = 9964
            container_port = 9964
            protocol       = "TCP"
          }

          port {
            name           = "hubble-metrics"
            host_port      = 9965
            container_port = 9965
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
            name  = "CILIUM_CLUSTERMESH_CONFIG"
            value = "/var/lib/cilium/clustermesh/"
          }

          env {
            name = "CILIUM_CNI_CHAINING_MODE"

            value_from {
              config_map_key_ref {
                name     = "cilium-config"
                key      = "cni-chaining-mode"
                optional = true
              }
            }
          }

          env {
            name = "CILIUM_CUSTOM_CNI_CONF"

            value_from {
              config_map_key_ref {
                name     = "cilium-config"
                key      = "custom-cni-conf"
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
            name       = "host-proc-sys-net"
            mount_path = "/host/proc/sys/net"
          }

          volume_mount {
            name       = "host-proc-sys-kernel"
            mount_path = "/host/proc/sys/kernel"
          }

          volume_mount {
            name              = "bpf-maps"
            mount_path        = "/sys/fs/bpf"
            mount_propagation = "HostToContainer"
          }

          volume_mount {
            name       = "cilium-run"
            mount_path = "/var/run/cilium"
          }

          volume_mount {
            name       = "etc-cni-netd"
            mount_path = "/host/etc/cni/net.d"
          }

          volume_mount {
            name       = "clustermesh-secrets"
            read_only  = true
            mount_path = "/var/lib/cilium/clustermesh"
          }

          volume_mount {
            name       = "lib-modules"
            read_only  = true
            mount_path = "/lib/modules"
          }

          volume_mount {
            name       = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }

          volume_mount {
            name       = "hubble-tls"
            read_only  = true
            mount_path = "/var/lib/cilium/tls/hubble"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          liveness_probe {
            exec {
              command = ["cilium", "status", "--brief"]
            }

            timeout_seconds   = 5
            period_seconds    = 30
            success_threshold = 1
            failure_threshold = 10
          }

          readiness_probe {
            exec {
              command = ["cilium", "status", "--brief"]
            }

            timeout_seconds   = 5
            period_seconds    = 30
            success_threshold = 1
            failure_threshold = 3
          }

          startup_probe {
            http_get {
              path   = "/healthz"
              port   = "9879"
              host   = "127.0.0.1"
              scheme = "HTTP"

              http_header {
                name  = "brief"
                value = "true"
              }
            }

            period_seconds    = 2
            success_threshold = 1
            failure_threshold = 105
          }

          lifecycle {
            post_start {
              exec {
                command = ["bash", "-c", "/cni-install.sh --enable-debug=true --cni-exclusive=true --log-file=/var/run/cilium/cilium-cni.log\n"]
              }
            }

            pre_stop {
              exec {
                command = ["/cni-uninstall.sh"]
              }
            }
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_MODULE", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
              drop = ["ALL"]
            }
          }
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 1

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name            = "cilium"
        automount_service_account_token = true
        host_network                    = true

        affinity {
          pod_anti_affinity {
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

        toleration {
          operator = "Exists"
        }

        priority_class_name = "system-node-critical"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "2"
      }
    }
  }
}

resource "kubernetes_daemonset" "hubble_enterprise" {
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

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "hubble-enterprise"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance"   = "release-name"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "hubble-enterprise"
          "helm.sh/chart"                = "hubble-enterprise-1.10.3"
        }
      }

      spec {
        volume {
          name = "cilium-run"

          host_path {
            path = "/var/run/cilium"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "export-logs"

          host_path {
            path = "/var/run/cilium/hubble"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "fgs-config"

          config_map {
            name = "hubble-enterprise-config"
          }
        }

        volume {
          name = "bpf-maps"

          host_path {
            path = "/sys/fs/bpf"
            type = "DirectoryOrCreate"
          }
        }

        volume {
          name = "host-proc"

          host_path {
            path = "/proc"
            type = "Directory"
          }
        }

        volume {
          name      = "metadata-files"
        }

        init_container {
          name                       = "enterprise-operator"
          image                      = "quay.io/isovalent/hubble-enterprise-operator:v1.10.2"
          command                    = ["hubble-enterprise-operator"]
          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"
        }

        init_container {
          name    = "enterprise-init"
          image   = "quay.io/isovalent/hubble-enterprise-metadata:current"
          command = ["sh"]
          args    = ["-c", "cp -r /var/run/hubble-fgs/* /var/lib/hubble-fgs/metadata\nuntil [ -S /var/run/cilium/cilium.sock -a -S /var/run/cilium/monitor1_2.sock ]; do sleep 3; done\n"]

          volume_mount {
            name       = "metadata-files"
            mount_path = "/var/lib/hubble-fgs/metadata"
          }

          volume_mount {
            name       = "cilium-run"
            mount_path = "/var/run/cilium"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "Always"
        }

        container {
          name    = "export-stdout"
          image   = "quay.io/isovalent/hubble-export-stdout:v1.0.3"
          command = ["hubble-export-stdout"]
          args    = ["/var/run/cilium/hubble/fgs.log", "/var/run/cilium/hubble/hubble.log"]

          volume_mount {
            name       = "export-logs"
            mount_path = "/var/run/cilium/hubble"
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"
        }

        container {
          name    = "enterprise"
          image   = "quay.io/isovalent/hubble-enterprise:v1.10.2"
          command = ["/usr/bin/hubble-fgs"]
          args    = ["--config-dir=/etc/hubble-enterprise"]

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name       = "metadata-files"
            mount_path = "/var/lib/hubble-fgs/metadata"
          }

          volume_mount {
            name       = "fgs-config"
            read_only  = true
            mount_path = "/etc/hubble-enterprise"
          }

          volume_mount {
            name              = "bpf-maps"
            mount_path        = "/sys/fs/bpf"
            mount_propagation = "Bidirectional"
          }

          volume_mount {
            name       = "cilium-run"
            mount_path = "/var/run/cilium"
          }

          volume_mount {
            name       = "export-logs"
            mount_path = "/var/run/cilium/hubble"
          }

          volume_mount {
            name       = "host-proc"
            mount_path = "/procRoot"
          }

          liveness_probe {
            exec {
              command = ["hubble-enterprise", "status", "--server-address", "localhost:54321"]
            }
          }

          termination_message_policy = "FallbackToLogsOnError"
          image_pull_policy          = "IfNotPresent"

          security_context {
            privileged = true
          }
        }

        termination_grace_period_seconds = 1
        dns_policy                       = "Default"
        service_account_name             = "hubble-enterprise"
        host_network                     = true

        toleration {
          operator = "Exists"
        }
      }
    }
  }
}

