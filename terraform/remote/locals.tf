locals {
  remote_clusters = {
    for cluster, namespaces in var.cluster_namespaces :
    cluster => namespaces
    if cluster != var.openbao_incluster_cluster_name
  }

  kubernetes_auth_backend_paths = {
    for cluster in keys(local.remote_clusters) :
    cluster => "${var.openbao_kubernetes_auth_path_prefix}-${cluster}"
  }

  kubernetes_auth_config = {
    for cluster in keys(local.remote_clusters) : cluster => {
      kubernetes_host    = data.vault_kv_secret_v2.kubernetes_auth[cluster].data["url"]
      kubernetes_ca_cert = data.vault_kv_secret_v2.kubernetes_auth[cluster].data["ca_cert"]
      token_reviewer_jwt = data.vault_kv_secret_v2.kubernetes_auth[cluster].data["reviewer_jwt"]
    }
  }
}
