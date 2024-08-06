# Cilium chart inputs
extraConfig: {
%{ if api_rate_limit_config != null ~}
api-rate-limit = ${api_rate_limit_config}
%{ endif ~}
}
keepDeprecatedProbes: true
kubeProxyReplacement: disabled
%{ if platform == "azure" ~}
azure:
  enabled: true
  subscriptionID: "${azure_subscription_id}"
  tenantID: "${azure_tenant_id}"
  clientID: "${azure_client_id}"
  clientSecret: "${azure_client_secret}"
%{ endif ~}
debug:
  enabled: ${debug}
cni:
  customConf: false
  chainingMode: none
cluster:
  name: ${cluster_name}
tls:
  enabled: false
  auto:
    enabled: false
identityAllocationMode: ${identity_allocation_mode}
%{ if length(identity_labels) != 0  ~}
labels: ${identity_labels}
%{ endif ~}
hubble:
  enabled: ${enable_hubble}
  listenAddress: ":4244"
  relay:
    enabled: ${enable_hubble}
  ui:
    enabled: false
  tls:
    enabled: false
    auto:
      enabled: false
%{ if prometheus_port != "" ~}
prometheus:
  enabled: true
  port: ${prometheus_port}
%{ endif ~}
%{ if enable_local_redirect_policy != "" ~}
localRedirectPolicy: true
%{ endif ~}
# reduce load on kube-apiserver
enableK8sEndpointSlice: true
enableCiliumEndpointSlice: true
