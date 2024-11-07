#! /bin/bash
echo Enter the Cluter Name:
read cluster_name
echo Enter the Service Environment :
read environment
echo Enter the Namespace:
read namespace
echo Enter the Service Name:
read service_name
echo Enter the Secret Name:
read secret_name
echo Enter the Secret Value:
read secret_data


if [ -n "$service_name" ]; then
  secret_string_name="$cluster_name-$environment-$namespace-$service_name-$secret_name-secret"
else
  secret_string_name="$cluster_name-$environment-$namespace-$secret_name-secret"
fi


gcloud secrets create "$secret_string_name" --replication-policy="automatic"
echo -n "$secret_data" | \
    gcloud secrets versions add "$secret_string_name" --data-file=-

# If we have secret-string data  in a file called my_secret.txt in same directory
# gcloud secrets create "$secret_string_name" --data-file my_secret.txt

# If the secret string is in form of key value pair 
# gcloud secrets create "$secret_string_name" \
#     --replication-policy="automatic" \
#     --data-file=<(echo -n '{"username":"my-username","password":"my-password","other_key":"other_value"}')
