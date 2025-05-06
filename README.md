<p align="center">
  <img src="https://zop.dev/resources/cdn/newsletter/zopdev-transparent-logo.png" alt="zop.dev Logo" width="200">
</p>

<h2 align="center">OPENTOFU MODULES</h2>

<p align="center">
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/License-Apache_2.0-blue?style=for-the-badge" alt="Apache 2.0 License">
  </a>
</p>

A Terraform-based open-source framework to **provision, manage, and operate Kubernetes clusters, cloud services, and observability systems** across **AWS, GCP, Azure, and OCI** — with production-ready modules.

---

## 🎯 Goal

To simplify and standardize **Kubernetes cluster creation**, **datastore management**, and **infrastructure provisioning** across major cloud providers, while keeping the system modular and extensible.

---

## ✨ Features

- ✅ Multi-cloud support (AWS, Azure, GCP, OCI)
- ☸️ Managed Kubernetes provisioning with namespaces
- 📦 Artifact registries for container images
- 📊 Observability stack: Grafana, Loki, Tempo, Prometheus, Mimir, Fluentibit
- 🔁 Redis and SQL databases
- 📁 Terraform remote state handling
- 🚀 Helm-based service and cronjob deployment via [zopdev/helm-charts](https://github.com/zopdev/helm-charts)

---

## 📦 Module Overview

| #  | Module          | Purpose                                         |
|----|------------------|-------------------------------------------------|
| 1  | Account Setup     | Networking infra (VPCs, subnets, gateways)     |
| 2  | Artifact Registry | Container image registries                     |
| 3  | Kubernetes Cluster| EKS, GKE, AKS, OKE setup with namespace           |
| 4  | Observability     | Monitoring, logging, tracing                   |
| 5  | Redis             | Cloud-native Redis or local Redis via Helm     |
| 6  | SQL               | MySQL / PostgreSQL provisioning                |
| 7  | Remote State      | Terraform backend state management             |
| 8  | Zop Helm          | Helm-based cronjob and service deployments     |
| 9  | Zop System        | Helm chart management using zop.dev service    |
| 10 | Kops Kube         | Zop.dev-based log system deployment            |

---

## 🧱 1. Account Setup

Sets up networking infrastructure like VPCs, subnets, NAT gateways, and security controls for each cloud provider.

| Cloud  | Components Provisioned                                           | Path                        |
|--------|------------------------------------------------------------------|-----------------------------|
| AWS    | VPC, Public/Private Subnets, Internet/NAT Gateway, Security Groups | [`account-setup/aws/`](./account-setup/aws/)     |
| Azure  | Virtual Network, Subnets, NSGs, Public IPs                       | [`account-setup/azure/`](./account-setup/azure/)    |
| GCP    | VPC, Subnetworks, Firewall Rules, Cloud NAT                      | [`account-setup/gcp/`](./account-setup/gcp/)      |
| OCI    | VCN, Subnets, Internet Gateway, Security Lists                   | [`account-setup/oci/`](./account-setup/oci/)      |

---

## 📦 2. Artifact Registry

Creates and configures cloud-native artifact registries for container image storage.

| Cloud  | Service                     | Notes                              | Path                         |
|--------|-----------------------------|-------------------------------------|------------------------------|
| AWS    | ECR (Elastic Container Registry) | Supports private/public repos | [`artifact-registry/aws/`](./artifact/aws/)    |
| Azure  | Azure Container Registry    | Container Storage | [`artifact-registry/azure/`](./artifact/azure/)   |
| GCP    | Artifact Registry           | Region-specific container storage   | [`artifact-registry/gcp/`](./artifact/gcp/)    |
| OCI    | OCI Container Registry      | Supports private/public repos     | [`artifact-registry/oci/`](./artifact/oci/)    |

---

## ☸️ 3. Kubernetes Cluster

Provision managed Kubernetes clusters and namespaces with NGINX ingress setup.

| Cloud  | Submodules                         | Description                         | Path                     |
|--------|------------------------------------|-------------------------------------|--------------------------|
| AWS    | `auth`, `eks`, `iam`, `namespace`, `nginx` | Full EKS cluster provisioning | [`k8s-cluster/aws/`](./k8s/aws/)       |
| Azure  | `aad`, `aks`, `namespace`, `nginx`        | Azure AKS with AAD and ingress     | [`k8s-cluster/azure/`](./k8s/azure/)            |
| GCP    | `gke`, `namespace`, `nat`, `nginx`        | GKE setup with NAT and ingress     | [`k8s-cluster/gcp/`](./k8s/gcp/)              |
| OCI    | `oke`, `namespace`, `nginx`              | OKE cluster with NGINX setup       | [`k8s-cluster/oci/`](./k8s/oci/)        |

---

## 📊 4. Observability Stack

Deploy a full observability stack for metrics, logs, and traces.

| Tool        | Purpose                     |
|-------------|-----------------------------|
| Grafana     | Dashboard visualization     |
| Prometheus  | Metrics collection          |
| Loki        | Log aggregation             |
| Tempo       | Distributed tracing         |
| Mimir       | Long-term metrics backend   |
| Fluent Bit  | Log shipping and parsing    |

**Cloud-specific paths**:
- [`observability/aws/`](./observability/aws)
- [`observability/azure/`](./observability/azure)
- [`observability/gcp/`](./observability/gcp)

---

## ⚡ 5. Redis Module

Deploy Redis instances across multiple clouds or locally using Helm.

| Cloud  | Module Path            | Type            |
|--------|------------------------|------------------|
| AWS    | [`redis/aws-elasticache`](./redis/aws-elasticache/) | AWS ElastiCache |
| GCP    | [`redis/gcp-redis`](./redis/gcp-redis)       | GCP Redis       |
| Azure  | [`redis/azure-redis`](./redis/azure-redis/)     | Azure Redis     |
| OCI    | [`redis/oci-redis`](./redis/oci-redis)       | OCI Cache Cluster       |
| Local  | [`redis/local`](./redis/local/)           | Redis Helm chart |

---

## 🗃️ 6. SQL Database Module

Provision managed SQL databases (MySQL/PostgreSQL) in the cloud.

| Cloud  | Module Path              | Supported Engines       |
|--------|--------------------------|--------------------------|
| AWS    | [`sql/aws-rds`](./sql/aws-rds/)          | MySQL, PostgreSQL        |
| Azure  | [`sql/azure-mysql`](./sql/azure-mysql/) / [`sql/azure-postgres`](./sql/azure-postgres/) | Separate modules |
| GCP    | [`sql/gcp-sql`](./sql/gcp-sql/)           | MySQL, PostgreSQL        |
| OCI    | [`sql/oci-mysql`](./sql/oci-mysql) / [`sql/oci-postgres`](./sql/oci-postgres)     | Separate modules |

---

## 📁 7. Remote State Module

Used to store and manage Terraform state securely in each cloud provider.

| Cloud  | Backend Type          | Module Path         |
|--------|------------------------|----------------------|
| AWS    | S3                    | [`remote-state/aws/`](./remote-state/aws/)  |
| Azure  | Azure Storage Account | [`remote-state/azure/`](./remote-state/azure/)|
| GCP    | GCS                   | [`remote-state/gcp/`](./remote-state/gcp/)  |
| OCI    | GCS                   | [`remote-state/oci/`](./remote-state/oci/)  |

---

## ⏱️ 8. Zop Helm Module

Deploys cronjobs and services using Helm charts managed by [zopdev/helm-charts](https://github.com/zopdev/helm-charts).

| Component | Description            | Path          |
|----------|-------------------------|---------------|
| `cronjob`| Scheduled tasks         | [`zop-helm/`](./zop-helm/cronjob/)   |
| `service`| Microservices/API apps  | [`zop-helm/`](./zop-helm/service/)   |

---

## 🔧 9. Zop System Module

Deploys the **Zop System** controller for managing Helm charts via Zop.dev.

| Cloud  | Path              | 
|--------|-------------------|
| AWS    | [`zop-system/aws/`](./zop-system/aws/) | 
| Azure  | [`zop-system/azure/`](./zop-system/azure/)|
| GCP    | [`zop-system/gcp/`](./zop-system/gcp/) |                           
| OCI    |[ `zop-system/oci/`](./zop-system/oci/) | 

---

## 📥 10. Kops Kube Module

Deploy Zop.dev-based log management agents.

| Cloud  | Path              |
|--------|-------------------|
| AWS    | [`kops-kube/aws/`](./kops-kube/aws/)  | 
| Azure  | [`kops-kube/azure/`](./kops-kube/azure/)|
| GCP    | [`kops-kube/gcp/`](./kops-kube/gcp)  |

---

## 🛠️ Prerequisites

- Terraform v1.3+
- Cloud CLI (aws / gcloud / az / oci)
- Helm (for local deployments)
---

## 🔒 **License**

This project is licensed under the [Apache 2.0 License](./LICENSE).

---

## 📣 **Stay Connected**

For updates and support, visit the [zop.dev website](https://helm.zop.dev), join our [Discord community](https://discord.com/invite/jtKqDNBJNt), or participate in community discussions.