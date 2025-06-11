# GKE Module

This module provides a comprehensive solution for managing Google Kubernetes Engine (GKE) clusters with production-ready configurations and best practices.

## Features

- **Cluster Management**
  - Regional and zonal cluster support
  - Automatic node pool management
  - Windows node pool support
  - Release channel configuration
  - Gateway API support

- **Networking**
  - VPC-native networking
  - Network policy support
  - Pod security policies
  - Cloud NAT configuration
  - Firewall rules management

- **Security**
  - Workload identity
  - Master authorized networks
  - Node metadata configuration
  - Security group management
  - Mesh certificates

- **Monitoring & Logging**
  - Cloud Monitoring integration
  - Cloud Logging configuration
  - Managed Prometheus support
  - Custom metrics collection

- **Maintenance**
  - Automatic node upgrades
  - Maintenance windows
  - Node auto-repair
  - Node auto-upgrade

## Usage

```hcl
module "gke" {
  source = "path/to/module"

  project_id = "your-project-id"
  name       = "my-gke-cluster"
  region     = "us-central1"

  # Network configuration
  network            = "default"
  subnetwork         = "default"
  ip_range_pods      = "pod-range"
  ip_range_services  = "service-range"

  # Node pool configuration
  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
    }
  ]

  # Security configuration
  workload_identity_config = [{
    workload_pool = "your-project.svc.id.goog"
  }]

  # Monitoring configuration
  monitoring_enable_managed_prometheus = true
  logging_enabled_components          = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The project ID to host the cluster in | `string` | n/a | yes |
| name | The name of the cluster | `string` | n/a | yes |
| region | The region to host the cluster in | `string` | n/a | yes |
| network | The VPC network to host the cluster in | `string` | `"default"` | no |
| subnetwork | The subnetwork to host the cluster in | `string` | `"default"` | no |
| ip_range_pods | The secondary ip range to use for pods | `string` | n/a | yes |
| ip_range_services | The secondary ip range to use for services | `string` | n/a | yes |
| node_pools | List of node pools to be created | `list(map(string))` | `[]` | no |
| workload_identity_config | Workload Identity configuration | `list(map(string))` | `[]` | no |
| monitoring_enable_managed_prometheus | Enable managed Prometheus | `bool` | `false` | no |
| logging_enabled_components | List of logging components to enable | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The cluster ID |
| cluster_name | The cluster name |
| cluster_endpoint | The cluster endpoint |
| cluster_ca_certificate | The cluster CA certificate |
| node_pools_names | List of node pools names |
| node_pools_versions | Map of node pools versions |

## Best Practices

1. **Security**
   - Enable workload identity for secure pod authentication
   - Configure network policies to restrict pod-to-pod communication
   - Use private clusters for enhanced security
   - Enable binary authorization

2. **Networking**
   - Use VPC-native clusters
   - Configure proper IP ranges for pods and services
   - Set up Cloud NAT for outbound internet access
   - Configure appropriate firewall rules

3. **Monitoring**
   - Enable managed Prometheus for metrics collection
   - Configure logging for all components
   - Set up appropriate alerts
   - Use Cloud Monitoring for cluster health

4. **Maintenance**
   - Configure maintenance windows
   - Enable automatic node upgrades
   - Set up node auto-repair
   - Use release channels for version management

## Examples

See the [examples](./examples) directory for complete usage examples.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Add appropriate license information] 