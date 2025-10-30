# Replace AWS / Azure / OCI account setup modules with provisioner clients

**Description**  
Instead of using opentofu modules, we should use the **cloud resource provisioner** for account setup across AWS, Azure, and OCI.

This needs to be implemented as part of the **CLUSTER JOB** to handle infra-level setup actions.

---

## AWS Account Setup
**Opentofu Modules Reference**  
👉 [AWS Account Setup Module](https://github.com/zopdev/opentofu-modules/tree/main/account-setup/aws)

**Actions to Replace in Cluster Job**
- VPC creation with DNS support and hostnames
- Public subnets creation with auto-assign public IP
- Private subnets creation without public IP
- Database subnets creation for RDS/ElastiCache
- Internet Gateway creation and attachment
- NAT Gateway creation with Elastic IP allocation
- Route tables creation (public, private, database)
- Route rules configuration (0.0.0.0/0 to IGW for public, NAT for private/DB)
- Route table associations for all subnets
- Security groups creation and configuration
- Multi-AZ subnet distribution across availability zones  

---

## Azure Account Setup
**Opentofu Modules Reference**  
👉 [Azure Account Setup Module](https://github.com/zopdev/opentofu-modules/tree/main/account-setup/azure)

**Actions to Replace in Cluster Job**
- Virtual Network (VNet) creation with custom address space
- Resource Group data source lookup for location and name
- VNet configuration with specified address space ranges
- Conditional VNet creation based on variable input  

---

## OCI Account Setup
**Opentofu Modules Reference**  
👉 [OCI Account Setup Module](https://github.com/zopdev/opentofu-modules/tree/main/account-setup/oci)

**Actions to Replace in Cluster Job**
- VCN (Virtual Cloud Network) creation with DNS label and CIDR blocks
- Public subnets creation (k8sapi, svclb) with internet gateway routing
- Private subnets creation (node) with NAT gateway routing
- Database subnets creation with NAT gateway routing
- Internet Gateway creation and attachment
- NAT Gateway creation for private subnet outbound access
- Service Gateway creation for OCI services connectivity
- Route tables creation (public, private, database) with proper routing rules
- Security Lists creation with specific ingress/egress rules:
  - k8sapi subnet: Kubernetes API server access (6443, 12250)
  - svclb subnet: Service load balancer access
  - private subnet: Worker node communication and SSH access
  - database subnet: MySQL (3306), PostgreSQL (5432), Redis (6379) access
- OCI services discovery and configuration  

---

## GCP Account Setup
**Opentofu Modules Reference**  
👉 [GCP Account Setup Module](https://github.com/zopdev/opentofu-modules/tree/main/account-setup/gcp)

**Actions to Replace in Cluster Job**
- Enable required Google Cloud APIs:
  - Cloud Resource Manager API
  - Compute Engine API
  - Kubernetes Engine API
  - Cloud SQL Admin API
  - Secret Manager API
  - Redis API
  - DNS API
  - Service Networking API
  - Certificate Manager API
  - Service Usage API
- VPC (Virtual Private Cloud) creation with custom subnets
- Private subnets creation in specified regions
- Firewall rules creation for VPC access
- Cloud Router creation for NAT functionality
- Cloud NAT configuration for private subnet outbound access
- VPC peering setup for Google services:
  - Private IP address allocation for SQL proxy
  - Service networking connection for managed services
- IAM role assignments for compute service account:
  - Compute Instance Admin
  - Cloud SQL Client
  - DNS Admin
  - Logging Log Writer
  - Artifact Registry Reader
  - Compute Load Balancer Admin
  - Workload Identity User

---

## Hosted Zones Setup
**Opentofu Modules Reference**  
👉 [Hosted Zones Modules](https://github.com/zopdev/opentofu-modules/tree/main/hosted-zones)

### AWS Hosted Zones
**Actions to Replace in Cluster Job**
- Route53 hosted zone creation for each domain
- Name server records output for zone delegation
- Optional NS record creation in master zone (Google DNS) for delegation
- Zone configuration with domain names and NS record flags

### Azure Hosted Zones  
**Actions to Replace in Cluster Job**
- Azure DNS zone creation in specified resource group
- Name server records output for zone delegation
- Optional NS record creation in master zone (Google DNS) for delegation
- Zone configuration with domain names and NS record flags

### OCI Hosted Zones
**Actions to Replace in Cluster Job**
- OCI DNS zone creation as PRIMARY zone type
- Name server records output for zone delegation
- Optional NS record creation in master zone (Google DNS) for delegation
- DNS admin group creation for each zone
- DNS management policy creation with compartment-level permissions
- Zone configuration with domain names and NS record flags

### GCP Hosted Zones
**Actions to Replace in Cluster Job**
- Google Cloud DNS managed zone creation
- Zone labeling with provisioner information
- IAM role assignments for DNS management:
  - DNS Admin role for editors
  - DNS Reader role for viewers
- Name server records output for zone delegation
- Optional NS record creation in master zone for delegation
- Zone configuration with domain names and NS record flags

---

**Goal**  
Gradually move away from opentofu modules and rely on provisioner clients to handle account setup resources in a more granular, action-oriented way.