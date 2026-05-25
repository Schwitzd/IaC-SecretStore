azure_location                      = "switzerlandnorth"
azure_sp_openbao                    = "openbao-unseal-sp"
azure_unseal_sp_openbao_secret_name = "openbao-unseal-sp-secret"
openbao_rg                          = "secretsstore"
openbao_key_name                    = "schwitzd-openbao"
openbao_vault_key                   = "openbao-unseal"
openbao_incluster_cluster_name      = "farm"
k3s_namespace                       = "secrets"
cluster_namespaces = {
  farm = ["observability", "services", "database", "registry", "stocks", "productivity",
          "argocd", "infrastructure", "ai", "cattle-system", "rook-ceph", "storage", "pki", "identity", "cicd"]
  vps  = ["pki", "gateway", "secrets", "queue", "stocks"]
}
