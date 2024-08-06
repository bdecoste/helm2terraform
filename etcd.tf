# Used only when Cilium is in identity allocation kvstore (etcd) mode
resource "kubernetes_config_map" "cilium_etcd_config" {
  count = var.etcd_endpoint == "" ? 0 : 1

  metadata {
    name      = "cilium-etcd-config"
    namespace = "cilium"
  }
  data = {
    "etcd.config" = <<EOF
endpoints:
  - ${var.etcd_endpoint}
trusted-ca-file: /var/lib/etcd-secrets/etcd-client-ca.crt
key-file: /var/lib/etcd-secrets/etcd-client.key
cert-file: /var/lib/etcd-secrets/etcd-client.crt
EOF
  }
}
