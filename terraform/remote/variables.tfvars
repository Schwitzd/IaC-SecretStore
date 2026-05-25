openbao_incluster_cluster_name = "farm"
cluster_namespaces = {
  farm = ["observability", "services", "database", "registry", "stocks", "productivity",
          "argocd", "infrastructure", "ai", "cattle-system", "rook-ceph", "storage", "pki", "identity"]
  vps  = ["pki", "gateway", "secrets", "queue", "stocks"]
}
