#!/bin/bash

# Variables
echo Enter the Domain Name:
read DOMAIN_NAME
echo Enter the Hosted Zone Name:
read HOSTED_ZONE_NAME

# Set the AWS profile and region
echo Enter the AWS PROFILE:
read AWS_PROFILE
echo Enter the AWS REGION:
read AWS_REGION

# Create the hosted zone
HOSTED_ZONE_ID=$(aws route53 create-hosted-zone \
    --name $HOSTED_ZONE_NAME \
    --caller-reference $(uuidgen) \
    --hosted-zone-config Comment="Hosted zone for $DOMAIN_NAME" \
    --query "HostedZone.Id" \
    --output text \
    --profile $AWS_PROFILE \
    --region $AWS_REGION
)

# Retrieve the nameservers for the hosted zone
NAMESERVERS=$(aws route53 get-hosted-zone \
  --id "$HOSTED_ZONE_ID" \
  --query 'DelegationSet.NameServers' \
  --output text
)

# Output the results
echo "Hosted Zone created with ID: $HOSTED_ZONE_ID"
echo "Nameservers:"
echo "$NAMESERVERS"