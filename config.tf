resource "kubernetes_config_map" "hubble_relay_config" {
  metadata {
    name      = "hubble-relay-config"
    namespace = "cilium"
  }

  data = {
    "config.yaml" = "cluster-name: decoste-panda\npeer-service: \"hubble-peer.cilium.svc.cluster.local:443\"\nlisten-address: :4245\ndial-timeout: 15s\nretry-timeout: 15s\nsort-buffer-len-max: \nsort-buffer-drain-timeout: \ntls-client-cert-file: /var/lib/hubble-relay/tls/client.crt\ntls-client-key-file: /var/lib/hubble-relay/tls/client.key\ntls-hubble-server-ca-files: /var/lib/hubble-relay/tls/hubble-server-ca.crt\ndisable-server-tls: true\n"
  }
}

resource "kubernetes_config_map" "hubble_enterprise_config" {
  metadata {
    name      = "hubble-enterprise-config"
    namespace = "cilium"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "hubble-enterprise"
      "helm.sh/chart"                = "hubble-enterprise-1.10.3"
    }
  }

  data = {
    cilium-bpf              = "/sys/fs/bpf/tc/globals/"
    enable-cilium-api       = "true"
    enable-k8s-api          = "true"
    enable-process-cred     = "false"
    enable-process-ns       = "false"
    export-allowlist        = "{\"event_set\":[\"PROCESS_CONNECT\", \"PROCESS_EXEC\", \"PROCESS_HTTP\", \"PROCESS_KPROBE\", \"PROCESS_LISTEN\", \"PROCESS_TLS\"]}"
    export-denylist         = "{\"health_check\":true}\n{\"namespace\":[\"\", \"cilium\", \"kube-system\"]}"
    export-file-compress    = "false"
    export-file-max-backups = "5"
    export-file-max-size-mb = "10"
    export-filename         = "/var/run/cilium/hubble/fgs.log"
    export-rate-limit       = "-1"
    gops-address            = "localhost:8118"
    metrics-server          = ":2112"
    process-cache-size      = "65536"
    procfs                  = "/procRoot"
    server-address          = "localhost:54321"
    tlstc                   = "false"
  }
}

resource "kubernetes_config_map" "hubble_ui_nginx" {
  metadata {
    name      = "hubble-ui-nginx"
    namespace = "cilium"
  }

  data = {
    "nginx.conf" = "server {\n    listen       8081;\n    server_name  localhost;\n\n    client_max_body_size 1G;\n    proxy_buffers 256 512k;\n    proxy_buffer_size 512k;\n    subrequest_output_buffer_size 8k;\n    location / {\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n\n        # CORS\n        add_header Access-Control-Allow-Methods \"GET, POST, PUT, HEAD, DELETE, OPTIONS\";\n        add_header Access-Control-Allow-Origin *;\n        add_header Access-Control-Max-Age 1728000;\n        add_header Access-Control-Expose-Headers content-length,grpc-status,grpc-message;\n        add_header Access-Control-Allow-Headers range,keep-alive,user-agent,cache-control,content-type,content-transfer-encoding,x-accept-content-transfer-encoding,x-accept-response-streaming,x-user-agent,x-grpc-web,grpc-timeout;\n        if ($request_method = OPTIONS) {\n            return 204;\n        }\n        # /CORS\n\n        location /api {\n            proxy_http_version 1.1;\n            proxy_pass_request_headers on;\n            proxy_hide_header Access-Control-Allow-Origin;\n            proxy_set_header Upgrade $http_upgrade;\n            proxy_set_header Connection \"Upgrade\";\n            proxy_set_header Host $host;\n            proxy_read_timeout 96000s;\n            proxy_send_timeout 96000s;\n            proxy_socket_keepalive on;\n            proxy_pass http://127.0.0.1:8090;\n        }\n        location / {\n            rewrite  ^/(.*)  /$1 break;\n            proxy_pass http://localhost:8082;\n        }\n    }\n}\nserver {\n    listen       8082;\n    server_name  localhost;\n\n    root /app;\n    index index.html;\n\n    location / {\n        try_files $uri $uri/ /index.html;\n    }\n}"
  }
}

resource "kubernetes_config_map" "cilium_config" {
  metadata {
    name      = "cilium-config"
    namespace = "cilium"
  }

  data = {
    agent-not-ready-taint-key               = "node.cilium.io/agent-not-ready"
    arping-refresh-period                   = "30s"
    auto-direct-node-routes                 = "false"
    bpf-lb-external-clusterip               = "false"
    bpf-lb-map-max                          = "65536"
    bpf-lb-sock                             = "false"
    bpf-map-dynamic-size-ratio              = "0.0025"
    bpf-policy-map-max                      = "16384"
    bpf-root                                = "/sys/fs/bpf"
    cgroup-root                             = "/run/cilium/cgroupv2"
    cilium-endpoint-gc-interval             = "5m0s"
    cluster-id                              = "0"
    cluster-name                            = "decoste-panda"
    cluster-pool-ipv4-cidr                  = "192.168.0.0/16"
    cluster-pool-ipv4-mask-size             = "24"
    cni-uninstall                           = "true"
    custom-cni-conf                         = "false"
    debug                                   = "true"
    disable-cnp-status-updates              = "true"
    disable-endpoint-crd                    = "false"
    egress-gateway-healthcheck-timeout      = "2s"
    enable-auto-protect-node-port-range     = "true"
    enable-bgp-control-plane                = "false"
    enable-bpf-clock-probe                  = "true"
    enable-cilium-endpoint-slice            = "true"
    enable-cluster-aware-addressing         = "false"
    enable-endpoint-health-checking         = "true"
    enable-health-check-nodeport            = "true"
    enable-health-checking                  = "true"
    enable-hubble                           = "true"
    enable-hubble-open-metrics              = "true"
    enable-inter-cluster-snat               = "false"
    enable-ipv4                             = "true"
    enable-ipv4-masquerade                  = "true"
    enable-ipv6                             = "false"
    enable-ipv6-big-tcp                     = "false"
    enable-ipv6-masquerade                  = "true"
    enable-k8s-endpoint-slice               = "true"
    enable-k8s-terminating-endpoint         = "true"
    enable-l2-neigh-discovery               = "true"
    enable-l7-proxy                         = "true"
    enable-local-redirect-policy            = "true"
    enable-metrics                          = "true"
    enable-policy                           = "default"
    enable-remote-node-identity             = "true"
    enable-sctp                             = "false"
    enable-svc-source-range-check           = "true"
    enable-vtep                             = "false"
    enable-well-known-identities            = "false"
    enable-xt-socket-fallback               = "true"
    hubble-disable-tls                      = "false"
    hubble-listen-address                   = ":4244"
    hubble-metrics                          = "dns:query;sourceContext=workload-name;destinationContext=workload-name drop:sourceContext=identity;destinationContext=identity;labelsContext=source_workload,destination_workload tcp flow port-distribution http flows-to-world policy"
    hubble-metrics-server                   = ":9965"
    hubble-socket-path                      = "/var/run/cilium/hubble.sock"
    hubble-tls-cert-file                    = "/var/lib/cilium/tls/hubble/server.crt"
    hubble-tls-client-ca-files              = "/var/lib/cilium/tls/hubble/client-ca.crt"
    hubble-tls-key-file                     = "/var/lib/cilium/tls/hubble/server.key"
    identity-allocation-mode                = "crd"
    identity-gc-interval                    = "15m0s"
    identity-heartbeat-timeout              = "30m0s"
    install-no-conntrack-iptables-rules     = "false"
    ipam                                    = "cluster-pool"
    kube-proxy-replacement                  = "disabled"
    monitor-aggregation                     = "medium"
    monitor-aggregation-flags               = "all"
    monitor-aggregation-interval            = "5s"
    node-port-bind-protection               = "true"
    nodes-gc-interval                       = "5m0s"
    operator-api-serve-addr                 = "127.0.0.1:9234"
    operator-prometheus-serve-addr          = ":9963"
    preallocate-bpf-maps                    = "false"
    procfs                                  = "/host/proc"
    prometheus-serve-addr                   = ":9962"
    proxy-prometheus-port                   = "9964"
    remove-cilium-node-taints               = "true"
    set-cilium-is-up-condition              = "true"
    sidecar-istio-proxy-image               = "cilium/istio_proxy"
    skip-cnp-status-startup-clean           = "false"
    synchronize-k8s-nodes                   = "true"
    tofqdns-dns-reject-response-code        = "refused"
    tofqdns-enable-dns-compression          = "true"
    tofqdns-endpoint-max-ip-per-hostname    = "50"
    tofqdns-idle-connection-grace-period    = "0s"
    tofqdns-max-deferred-connection-deletes = "10000"
    tofqdns-min-ttl                         = "3600"
    tofqdns-proxy-response-max-delay        = "100ms"
    tunnel                                  = "vxlan"
    unmanaged-pod-watcher-interval          = "15"
  }
}

