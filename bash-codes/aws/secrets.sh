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

if [ -n "$service_name" ]; then
  secret_string_name="$cluster_name-$environment-$namespace-$service_name-$secret_name-secret"
else
  secret_string_name="$cluster_name-$environment-$namespace-$secret_name-secret"
fi

secret_string=```required secret string```

aws secretsmanager create-secret --name "$secret_string_name" --secret-string "$secret_string"


# If the secret string has to be in a key value format then secret string changes as follows
# secret_string ="{username:admin,password:password123}"

# In case of data in a file the above command changes as follows 
# aws secretsmanager create-secret --name "$secret_string_name" --secret-string "$(cat file.txt)"
# where file.txt is the file that contains the secret string.