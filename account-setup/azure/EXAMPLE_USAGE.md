# Azure Account Setup - Example Usage

## Sample Terraform Configuration

### Basic Example (Single VNet)

```hcl
module "azure_account_setup" {
  source = "./account-setup/azure"

  resource_group_name = "my-resource-group"

  vnet_config = {
    "production-vnet" = {
      address_space        = ["10.0.0.0/16"]
      private_subnets_cidr = ["10.0.1.0/24"]
      # database_subnets_cidr and public_subnets_cidr are optional
      # If not provided, they will be auto-created with defaults
    }
  }
}
```

### Complete Example (With All Subnets)

```hcl
module "azure_account_setup" {
  source = "./account-setup/azure"

  resource_group_name = "my-resource-group"

  vnet_config = {
    "production-vnet" = {
      address_space         = ["10.1.0.0/16"]      # Must NOT be 10.0.0.0/16 (conflicts with Azure's default service CIDR)
      private_subnets_cidr  = ["10.1.1.0/24"]      # For AKS nodes (with public IPs)
      database_subnets_cidr = ["10.1.2.0/24"]      # For MySQL/PostgreSQL (optional)
    }
  }
}
```

### Multiple VNets Example

```hcl
module "azure_account_setup" {
  source = "./account-setup/azure"

  resource_group_name = "my-resource-group"

  vnet_config = {
    "production-vnet" = {
      address_space         = ["10.0.0.0/16"]
      private_subnets_cidr  = ["10.0.1.0/24", "10.0.5.0/24"]  # Multiple private subnets
      database_subnets_cidr = ["10.0.2.0/24"]
    }
    
    "staging-vnet" = {
      address_space        = ["10.1.0.0/16"]
      private_subnets_cidr = ["10.1.1.0/24"]
      # database_subnets_cidr omitted - databases will use public access
    }
  }
}
```

### Minimal Example (Auto-defaults)

```hcl
module "azure_account_setup" {
  source = "./account-setup/azure"

  resource_group_name = "my-resource-group"

  vnet_config = {
    "my-vnet" = {
      address_space        = ["10.1.0.0/16"]      # Must NOT be 10.0.0.0/16 (conflicts with Azure's default service CIDR)
      private_subnets_cidr = ["10.1.1.0/24"]
      # Database subnet omitted - no VNet integration for DBs
      # AKS nodes will have public IPs for internet access (no NAT Gateway needed)
    }
  }
}
```

## Using Subnet Names

Subnet names follow a pattern: `{vnet_name}-{type}-subnet`

For VNet `"production-vnet"`:
- Private subnet: `"production-vnet-private-subnet"`
- Database subnet: `"production-vnet-database-subnet"`

**For AKS cluster:**
```hcl
vpc    = "production-vnet"
subnet = "production-vnet-private-subnet"
```

**For namespace module:**
```hcl
vpc    = "production-vnet"
subnet = "production-vnet-database-subnet"
```

## Integration with AKS and Databases

```hcl
# Step 1: Create VNet setup
module "vnet" {
  source = "./account-setup/azure"
  
  resource_group_name = "my-rg"
  vnet_config = {
    "my-vnet" = {
      address_space        = ["10.1.0.0/16"]      # Must NOT be 10.0.0.0/16 (conflicts with Azure's default service CIDR)
      private_subnets_cidr = ["10.1.1.0/24"]
      database_subnets_cidr = ["10.1.2.0/24"]
    }
  }
}

# Step 2: Create AKS cluster
module "aks" {
  source = "./k8s/azure/aks"
  
  resource_group_name = "my-rg"
  app_name            = "my-app"
  vpc                 = "my-vnet"                                    # VNet name from account-setup
  subnet              = "my-vnet-private-subnet"                     # Private subnet name (pattern: {vnet_name}-private-subnet)
  # ... other vars
}

# Step 3: Create namespace with databases
module "namespace" {
  source = "./k8s/azure/namespace"
  
  resource_group_name = "my-rg"
  app_name            = "my-app"
  namespace           = "production"
  vpc                 = "my-vnet"                                    # VNet name from account-setup
  subnet              = "my-vnet-database-subnet"                    # Database subnet name (pattern: {vnet_name}-database-subnet)
  
  sql_db = {
    type = "postgresql"
    # ... other config
  }
  # ... other vars
}
```

## Notes

- **VNet Address Space**: Must NOT use `10.0.0.0/16` (conflicts with Azure's default AKS service CIDR). Use `10.1.0.0/16`, `10.2.0.0/16`, etc.
- **Public Node IPs**: AKS nodes automatically get public IPs when using VNet (no NAT Gateway needed)
- **NSG Rules**: Automatically configured:
  - Private subnet: Allows all VNet internal communication and outbound internet
  - Database subnet: Only allows DB ports (3306, 5432, 6379) from private subnet
- **Backward Compatible**: Empty `vnet_config = {}` means no VNet is created
- **Cost Savings**: No NAT Gateway cost (~$32-100/month saved)

