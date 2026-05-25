# KV mounts — one per cluster/namespace for all clusters
resource "vault_mount" "namespaces" {
  for_each = merge([
    for cluster, namespaces in var.cluster_namespaces : {
      for ns in namespaces : "${cluster}:${ns}" => {
        cluster   = cluster
        namespace = ns
      }
    }
  ]...)

  path        = "${each.value.cluster}/${each.value.namespace}"
  type        = "kv-v2"
  description = "Kubernetes secrets for cluster ${each.value.cluster} namespace ${each.value.namespace}"
}

# KV mount for IaC operational config (remote cluster auth configs)
resource "vault_mount" "remote_clusters" {
  path        = var.remote_clusters_mount
  type        = "kv-v2"
  description = "IaC operational config: remote cluster auth configs stored at ${var.remote_clusters_mount}/clusters/<cluster>"
}

# Policies
resource "vault_policy" "cluster_rw" {
  for_each = merge([
    for cluster, namespaces in var.cluster_namespaces : {
      for ns in namespaces : "${cluster}:${ns}" => {
        cluster   = cluster
        namespace = ns
      }
    }
  ]...)

  name = "${each.value.cluster}-${each.value.namespace}-rw"
  policy = <<-EOT
    path "${each.value.cluster}/${each.value.namespace}/data/*" {
      capabilities = ["create", "update", "read", "delete", "list"]
    }

    path "${each.value.cluster}/${each.value.namespace}/metadata/*" {
      capabilities = ["read", "list", "delete"]
    }
  EOT

  depends_on = [vault_mount.namespaces]
}

resource "vault_policy" "cluster_ro" {
  for_each = merge([
    for cluster, namespaces in var.cluster_namespaces : {
      for ns in namespaces : "${cluster}:${ns}" => {
        cluster   = cluster
        namespace = ns
      }
    }
  ]...)

  name = "${each.value.cluster}-${each.value.namespace}-ro"
  policy = <<-EOT
    path "${each.value.cluster}/${each.value.namespace}/data/*" {
      capabilities = ["read", "list"]
    }

    path "${each.value.cluster}/${each.value.namespace}/metadata/*" {
      capabilities = ["read", "list"]
    }
  EOT

  depends_on = [vault_mount.namespaces]
}

# ESO role for the in-cluster (farm) only
# The kubernetes-farm auth backend is pre-created by the OpenBao init job
resource "vault_kubernetes_auth_backend_role" "eso" {
  backend   = "${var.openbao_kubernetes_auth_path_prefix}-${var.openbao_incluster_cluster_name}"
  role_name = "${var.openbao_kubernetes_role_name_prefix}-${var.openbao_incluster_cluster_name}"

  bound_service_account_names      = var.openbao_bound_service_account_names
  bound_service_account_namespaces = var.openbao_bound_service_account_namespaces

  token_policies = [
    for ns in var.cluster_namespaces[var.openbao_incluster_cluster_name] :
    "${var.openbao_incluster_cluster_name}-${ns}-ro"
  ]

  token_ttl     = 3600
  token_max_ttl = 7200

  depends_on = [vault_policy.cluster_ro]
}

# Dependency sink — target this to apply the full OpenBao structure in one shot
resource "terraform_data" "openbao_structure" {
  depends_on = [
    vault_mount.namespaces,
    vault_mount.remote_clusters,
    vault_policy.cluster_rw,
    vault_policy.cluster_ro,
    vault_kubernetes_auth_backend_role.eso,
  ]
}
