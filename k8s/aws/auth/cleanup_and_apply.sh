#!/bin/bash

# Cleanup and Apply EKS Access Entries
# This script helps clean up the old aws-auth module and apply the new configuration

echo "🧹 Cleaning up old aws-auth module references..."

# Remove any old module references from state
echo "Removing old module references from Terraform state..."
terraform state list | grep "module.aws_auth" | xargs -r terraform state rm

# Initialize Terraform
echo "🔄 Initializing Terraform..."
terraform init

# Plan the changes
echo "📋 Planning changes..."
terraform plan

# Apply the changes
echo "🚀 Applying EKS Access Entries configuration..."
terraform apply

echo "✅ Migration complete! Your EKS cluster now uses Access Entries API."
echo "🔍 Test your access with: kubectl get nodes"