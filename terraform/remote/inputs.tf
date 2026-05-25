variable "cluster_namespaces" {
  description = "Per-cluster namespaces — used to derive remote clusters and their policies."
  type        = map(list(string))
}

variable "openbao_incluster_cluster_name" {
  description = "Cluster name for the in-cluster OpenBao instance — excluded from remote auth backend creation."
  type        = string
}

variable "openbao_kubernetes_auth_path_prefix" {
  description = "Prefix for Kubernetes auth backend paths (cluster name is appended)."
  type        = string
  default     = "kubernetes"
}

variable "openbao_kubernetes_role_name_prefix" {
  description = "Prefix for Kubernetes auth role names (cluster name is appended)."
  type        = string
  default     = "eso"
}

variable "openbao_bound_service_account_names" {
  description = "Service account names bound to the Kubernetes auth role."
  type        = list(string)
  default     = ["sa-external-secrets"]
}

variable "openbao_bound_service_account_namespaces" {
  description = "Service account namespaces bound to the Kubernetes auth role."
  type        = list(string)
  default     = ["secrets"]
}

variable "remote_clusters_mount" {
  description = "KV v2 mount path where remote cluster auth configs are stored (managed by the farm module)."
  type        = string
  default     = "remote-clusters"
}

variable "remote_clusters_path" {
  description = "Path prefix under remote_clusters_mount for per-cluster auth configs."
  type        = string
  default     = "clusters"
}
