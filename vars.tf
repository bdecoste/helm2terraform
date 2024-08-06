# Do NOT add a cilium_version variable. The intent is to version the entire module,
# not try to write conditional logic to handle all Cilium versions.

variable "cilium_version" {
  description = "version of cilium chart"
  default     = "1.13.4"
}

variable "kube_version" {
  description = "version of target kubernetes"
  default     = "v1.28.0"
}

variable "cilium_namespace" {
  description = "namespace for cilium"
  default     = "cilium"
}

variable "cluster_name" {
  description = "Unique name used as a prefix for node names"
  default     = "default"
}

variable "debug" {
  description = "Enable Cilium debug logging"
  default     = false
}

variable "platform" {
  description = "Cilium operator supports cloud-specific integrations (e.g. generic, azure)"
  default     = "generic"
}

variable "k8s_service_host" {
  type        = string
  description = "Kubernetes apiserver to use (defaults to in-cluster discovery)"
  default     = ""
}

variable "ipam" {
  description = "Cilium IP address management (IPAM) mode (cluster-pool or azure)"
  default     = "cluster-pool"
}

variable "node_selectors" {
  type        = map(string)
  description = "Limit Cilium Pods to a specific set of nodes"
  default     = {}
}

variable "operator_tolerations" {
  type = list(object({
    key      = string
    operator = string
  }))
  default = [
    {
      key      = null
      operator = "Exists"
    }
  ]
}

variable "enable_local_redirect_policy" {
  description = "Install the CiliumLocalRedirectPolicy CRD"
  default     = false
}

# Azure IPAM

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID used by Cilium Operator (used when `platform` set to azure)"
  default     = ""
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID used by Cilium Operator (used when `platform` set to azure)"
  default     = ""
}

variable "azure_client_id" {
  description = "Azure client ID for use with Azure IPAM mode"
  default     = ""
}

variable "azure_client_secret" {
  description = "Azure client secret for use with Azure IPAM mode"
  default     = ""
}

variable "api_rate_limit_config" {
  # see https://docs.cilium.io/en/stable/configuration/api-rate-limiting/
  description = "API rate limit config"
  type        = map(string)
  default     = null
  # example value:
  # {
  #   "endpoint-create": "rate-limit:10/s,rate-burst:10,parallel-requests:10,auto-adjust:true",
  #   "endpoint-delete": "rate-limit:10/s,rate-burst:10,parallel-requests:10,auto-adjust:true",
  #   "endpoint-get": "rate-limit:10/s,rate-burst:10,parallel-requests:10,auto-adjust:true",
  #   "endpoint-list": "rate-limit:10/s,rate-burst:10,parallel-requests:10,auto-adjust:true",
  #   "endpoint-patch": "rate-limit:10/s,rate-burst:10,parallel-requests:10,auto-adjust:true"
  # }
}

variable "kube_client_config" {
  # see https://github.com/kubernetes/client-go/blob/b1c1c0345d1de93f69e3d6c61b21b90a2218827d/rest/client.go#L33-L38
  description = "Kubernetes client-go configuration"
  type = object({
    backoff_duration = number
    backoff_base     = number
  })
  default = {
    backoff_duration = -1
    backoff_base     = -1
  }
}

# etcd

variable "identity_allocation_mode" {
  type        = string
  description = "Mode for storing Cilium identities (crd or kvstore)"
  default     = "crd"
}

variable "etcd_endpoint" {
  type        = string
  description = "etcd endpoint Cilium should use (when identity allocation mode is kvstore)"
  default     = ""
}

# Metrics

variable "prometheus_port" {
  description = "Cilium agents serve Prometheus metrics on the given port (e.g. 9091, 0 to disable)"
  default     = 9091
}

variable "enable_hubble_metrics" {
  description = "Enable Hubble metrics"
  default     = false
}

# Embedded Hubble server

variable "enable_hubble" {
  description = "Enable the embedded Hubble server"
  default     = false
}

variable "identity_labels" {
  # https://docs.cilium.io/en/v1.13/operations/performance/scalability/identity-relevant-labels/
  description = "labels to include or exclude from Cilium identity evaluation"
  type        = list(string)
  default     = []
}

variable "revision" {
  # https://github.com/openai/api/pull/13679#discussion_r1278178931
  description = "Version of this module. Prevents us from rolling Cilium until we are good and ready"
  default     = 0
}
