#!/bin/bash

# Set the project ID in which you want to create the bucket
echo Enter GCP Project ID :
read PROJECT_ID

# Set the name of the bucket you want to create
echo Enter GCS Bucket Name to store the state files :
read BUCKET_NAME

# Set the location of the bucket
echo Enter GCS Bucket location :
read BUCKET_LOCATION

# Create the bucket
gsutil mb -b on -p $PROJECT_ID -l $BUCKET_LOCATION gs://$BUCKET_NAME
