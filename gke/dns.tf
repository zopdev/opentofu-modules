resource "kubernetes_config_map_v1_data" "kube-dns" {
  count = local.custom_kube_dns_config && !local.upstream_nameservers_config ? 1 : 0

  metadata {
    name      = "kube-dns"
    namespace = "kube-system"
  }

  data = {
    stubDomains = <<EOF
${jsonencode(var.stub_domains)}
EOF
  }

  force = true

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.pools,
  ]
}

resource "kubernetes_config_map_v1_data" "kube-dns-upstream-namservers" {
  count = !local.custom_kube_dns_config && local.upstream_nameservers_config ? 1 : 0

  metadata {
    name      = "kube-dns"
    namespace = "kube-system"
  }

  data = {
    upstreamNameservers = <<EOF
${jsonencode(var.upstream_nameservers)}
EOF
  }

  force = true

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.pools,
  ]
}

resource "kubernetes_config_map_v1_data" "kube-dns-upstream-nameservers-and-stub-domains" {
  count = local.custom_kube_dns_config && local.upstream_nameservers_config ? 1 : 0

  metadata {
    name      = "kube-dns"
    namespace = "kube-system"
  }

  data = {
    upstreamNameservers = <<EOF
${jsonencode(var.upstream_nameservers)}
EOF

    stubDomains = <<EOF
${jsonencode(var.stub_domains)}
EOF
  }

  force = true

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.pools,
  ]
}