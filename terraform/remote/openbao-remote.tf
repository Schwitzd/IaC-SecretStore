resource "vault_auth_backend" "kubernetes" {
  for_each = local.remote_clusters

  type = "kubernetes"
  path = local.kubernetes_auth_backend_paths[each.key]
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  for_each = local.kubernetes_auth_config

  backend            = local.kubernetes_auth_backend_paths[each.key]
  kubernetes_host    = each.value.kubernetes_host
  kubernetes_ca_cert = each.value.kubernetes_ca_cert
  token_reviewer_jwt = each.value.token_reviewer_jwt

  depends_on = [vault_auth_backend.kubernetes]
}

resource "vault_kubernetes_auth_backend_role" "eso" {
  for_each = local.remote_clusters

  backend   = local.kubernetes_auth_backend_paths[each.key]
  role_name = "${var.openbao_kubernetes_role_name_prefix}-${each.key}"

  bound_service_account_names      = var.openbao_bound_service_account_names
  bound_service_account_namespaces = var.openbao_bound_service_account_namespaces

  token_policies = [
    for ns in each.value :
    "${each.key}-${ns}-ro"
  ]

  token_ttl     = 3600
  token_max_ttl = 7200

  depends_on = [vault_auth_backend.kubernetes]
}
