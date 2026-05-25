variable "openbao_address" {
  description = "OpenBao server address."
  type        = string
}

variable "openbao_token" {
  description = "OpenBao API token."
  type        = string
  sensitive   = true
}

variable "azure_location" {
  description = "Azure region where the Key Vault and resources will be deployed."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID used for the deployment."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID used for the deployment."
  type        = string
}

variable "k3s_namespace" {
  description = "K3s namespace for Kubernetes resources."
  type        = string
}

variable "azure_sp_openbao" {
  description = "Display name for the Azure AD Service Principal used by OpenBao for auto-unseal."
  type        = string
}

variable "openbao_rg" {
  description = "Azure Resource Group name for the OpenBao auto-unseal setup."
  type        = string
}

variable "openbao_key_name" {
  description = "Azure Key Vault name for the OpenBao auto-unseal setup."
  type        = string
}

variable "openbao_vault_key" {
  description = "Name of the RSA key inside Azure Key Vault used by OpenBao for auto-unseal."
  type        = string
}

variable "azure_unseal_sp_openbao_secret_name" {
  description = "Display name for the OpenBao unseal service principal secret."
  type        = string
}

variable "cluster_namespaces" {
  description = "Per-cluster namespaces to provision in OpenBao (KV mounts and policies created for all clusters)."
  type        = map(list(string))
}

variable "openbao_incluster_cluster_name" {
  description = "Cluster name for the in-cluster OpenBao instance (auth backend pre-created by init job)."
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
  description = "KV v2 mount path for IaC operational config (remote cluster auth, etc.)."
  type        = string
  default     = "remote-clusters"
}
