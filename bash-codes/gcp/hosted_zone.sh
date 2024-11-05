
# Set your project ID, domain name and dns name
echo Enter the GCP Project ID :
read PROJECT_ID
echo Enter the Hosted Zone Name :
read HOSTED_ZONE_NAME
echo Enter the DNS Name :
read DNS_NAME

# Create a new DNS zone in Google Cloud DNS
gcloud dns managed-zones create $HOSTED_ZONE_NAME \
--description "Hosted Zone for $PROJECT_ID which is used by Terraform" \
--dns-name $DNS_NAME \
--visibility=public \
--project $PROJECT_ID


# Get the list of name servers for the new zone
NAME_SERVERS=$(gcloud dns managed-zones describe $HOSTED_ZONE_NAME --project=$PROJECT_ID --format="value(nameServers)")

# Print the name servers to the console
echo "Add the following NS records to your domain registrar's DNS configuration"
echo "$NAME_SERVERS"
