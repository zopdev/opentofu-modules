# EKS Access Entries Migration Guide

## Overview
This guide helps you migrate from the legacy aws-auth ConfigMap to the new EKS Access Entries API for better security and future-proofing.

## What Changed
- **Before**: Used aws-auth ConfigMap to manage Kubernetes RBAC permissions
- **After**: Using EKS Access Entries API (recommended by AWS)
- **Why**: More secure, managed by AWS, won't break during upgrades

## Migration Steps

### 1. Update Your Variables
Make sure your user `ZopDevStage` is in the appropriate variable:

```hcl
# In your terraform.tfvars or variables
masters = ["ZopDevStage"]  # For admin access
# OR
editors = ["ZopDevStage"]  # For editor access
# OR  
viewers = ["ZopDevStage"]  # For viewer access
```

### 2. Apply the Changes
```bash
cd k8s/aws/auth
terraform init
terraform plan
terraform apply
```

### 3. Verify Access
```bash
# Test your access
kubectl get nodes
kubectl get services -n kube-system
```

## What the New Configuration Does

### Access Entries Created:
- **Users**: Creates EKS access entries for all users in your variables
- **Karpenter Node Role**: Creates access entry for Karpenter if configured
- **Access Policies**: Associates appropriate AWS managed policies

### Permission Levels:
- **masters**: `system:masters` + `AmazonEKSClusterAdminPolicy`
- **editors**: `cluster-editor` + `AmazonEKSClusterEditPolicy`  
- **viewers**: `cluster-viewer` + `AmazonEKSClusterViewPolicy`
- **system_authenticated_***: Same as above but for system users

## Benefits of New Approach

1. **Future-Proof**: Won't break during EKS upgrades
2. **AWS Managed**: Managed by EKS API, not ConfigMap
3. **More Secure**: Better integration with AWS IAM
4. **Auditable**: Better logging and monitoring
5. **Consistent**: Works across all EKS versions

## Troubleshooting

### If Access Still Doesn't Work:
1. Check your user is in the correct variable
2. Verify the access entries were created:
   ```bash
   aws eks list-access-entries --cluster-name <your-cluster>
   ```
3. Check access policies:
   ```bash
   aws eks list-associated-access-policies --cluster-name <your-cluster> --principal-arn arn:aws:iam::<account>:user/ZopDevStage
   ```

### Manual Fix (if needed):
```bash
# Create access entry manually
aws eks create-access-entry \
  --cluster-name <your-cluster> \
  --principal-arn arn:aws:iam::<account>:user/ZopDevStage \
  --type STANDARD

# Associate admin policy
aws eks associate-access-policy \
  --cluster-name <your-cluster> \
  --principal-arn arn:aws:iam::<account>:user/ZopDevStage \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy
```

## Rollback (if needed)
If you need to rollback to aws-auth ConfigMap:
1. Set `create_aws_auth_configmap = true` in main.tf
2. Remove or comment out the access-entries.tf file
3. Apply changes

## Next Steps
1. Test the new configuration
2. Remove any manual aws-auth ConfigMap entries
3. Update your documentation
4. Consider migrating other clusters to this approach