#!/bin/bash

# Set your AWS CLI profile
echo Enter the AWS PROFILE:
read AWS_PROFILE

# Set the name of the bucket you want to create
echo Enter the Bucket Name:
read BUCKET_NAME

# Set the region for the bucket
echo Enter the Bucker Region:
read BUCKET_REGION

# Create the bucket
aws s3api create-bucket --bucket $BUCKET_NAME --profile $AWS_PROFILE --region $BUCKET_REGION --create-bucket-configuration LocationConstraint=$BUCKET_REGION
