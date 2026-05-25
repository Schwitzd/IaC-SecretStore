data "vault_kv_secret_v2" "kubernetes_auth" {
  for_each = local.remote_clusters

  mount = var.remote_clusters_mount
  name  = "${var.remote_clusters_path}/${each.key}"
}
