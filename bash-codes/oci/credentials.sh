#!/bin/bash
CONFIG_FILE=~/.oci/config
CREDENTIALS_FILE="oci_credentials.json"
LOGS_FILE="logs.txt"

log_error() {
    local error_message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $error_message" >> "$LOGS_FILE"
}

log_actual_error() {
    local full_output="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$full_output" | grep -E "(Traceback|File \"|oci\.exceptions\.|ServiceError:|ERROR:|Exception:)" >> "$LOGS_FILE.tmp"
    if [ -s "$LOGS_FILE.tmp" ]; then
        echo "[$timestamp] Error details:" >> "$LOGS_FILE"
        cat "$LOGS_FILE.tmp" >> "$LOGS_FILE"
        echo "" >> "$LOGS_FILE"
    fi
    rm -f "$LOGS_FILE.tmp"
}

handle_quota_error() {
    local error_output="$1"
    local quota_error=""
    quota_error=$(echo "$error_output" | grep -o '"detail":"[^"]*quota limit[^"]*"' | sed 's/"detail":"//; s/"$//')
    if [ -z "$quota_error" ]; then
        quota_error=$(echo "$error_output" | grep -o "You can not create ApiKey as maximum quota limit of [0-9]* has been reached")
    fi
    if [ -z "$quota_error" ]; then
        quota_error=$(echo "$error_output" | grep -i "quota.*limit.*reached" | head -1)
    fi
    if [ -n "$quota_error" ]; then
        echo "   $quota_error"
        echo "   Delete an existing API key before creating a new one:"
        echo "   - OCI Console → Identity & Security → Users → API Keys"
        return 0
    fi
    return 1
}

run_bootstrap() {
    local profile="$1"
    echo "Starting OCI CLI Bootstrap with profile: $profile"
    temp_output=$(mktemp)
    oci setup bootstrap --profile-name "$profile" 2>&1 | tee "$temp_output"
    exit_code=${PIPESTATUS[0]}
    full_output=$(cat "$temp_output")
    rm -f "$temp_output"
    if [ $exit_code -ne 0 ]; then
        echo "❌ OCI Bootstrap failed!"
        log_actual_error "$full_output"
        if handle_quota_error "$full_output"; then
            log_error "Quota Error: $quota_error"
        else
            log_error "Bootstrap failed with exit code $exit_code"
        fi
        exit 1
    fi
    echo "✅ Bootstrap completed successfully with profile: $profile"
}

if ! command -v oci &> /dev/null; then
    echo "OCI CLI not found! Please install OCI CLI first."
    exit 1
fi
if ! command -v openssl &> /dev/null; then
    echo "OpenSSL not found! Please install OpenSSL first."
    exit 1
fi

echo "🧩 Checking OCI Config Profiles..."
profiles=($(grep '^\[' "$CONFIG_FILE" 2>/dev/null | sed 's/\[\(.*\)\]/\1/'))
if [ ${#profiles[@]} -eq 0 ]; then
     echo "🔧 No profiles found. Creating default profile..."
     run_bootstrap "DEFAULT"  
     profile="DEFAULT"
else
    echo "📁 Available OCI config profiles:"
    select opt in "${profiles[@]}" "Create new profile"; do
        if [[ "$REPLY" -gt 0 && "$REPLY" -le ${#profiles[@]} ]]; then
            profile="${profiles[$REPLY-1]}"
            echo "✅ Selected profile: $profile"
            break
        elif [[ "$opt" == "Create new profile" ]]; then
            read -p "Enter new profile name: " new_profile
            run_bootstrap "$new_profile"
            profile="$new_profile"
            break
        else
            echo "❌ Invalid option. Try again."
        fi
    done
fi

extract_value() {
    awk -v profile="[$profile]" -F '=' '
    $0 == profile {found=1; next}
    found && NF == 2 && $1 ~ /^[ \t]*'"$1"'[ \t]*$/ {
        gsub(/^[ \t]+|[ \t]+$/, "", $2)
        print $2
        exit
    }' "$CONFIG_FILE"
}

user_ocid=$(extract_value "user")
fingerprint=$(extract_value "fingerprint")
key_file=$(extract_value "key_file")
tenancy_ocid=$(extract_value "tenancy")
region=$(extract_value "region")

if [ -z "$key_file" ]; then
    error_msg="Private key file path is empty in config"
    echo "$error_msg"
    log_error "$error_msg"
    exit 1
fi
if [ ! -f "$key_file" ]; then
    error_msg="Private key file not found at $key_file"
    echo "$error_msg"
    log_error "$error_msg"
    exit 1
fi

echo "Converting private key to RSA PRIVATE KEY format..."
echo "Enter the passphrase used during bootstrap if prompted"
rsa_key_content=$(openssl rsa -in "$key_file" -traditional 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Key appears encrypted. Please enter passphrase:"
    rsa_key_content=$(openssl rsa -in "$key_file" -traditional 2>&1)
    if [ $? -ne 0 ]; then
        error_msg="OpenSSL failed to convert key. Please check and try again."
        echo "$error_msg"
        log_error "$error_msg"
        log_error "OpenSSL error: $rsa_key_content"
        exit 1
    fi
fi

escaped_key_content=$(echo "$rsa_key_content" | awk '{printf "%s\\n", $0}')
echo ""
echo "📋 Extracted OCI Configuration:"
echo "User OCID: $user_ocid"
echo "Fingerprint: $fingerprint"
echo "Tenancy OCID: $tenancy_ocid"
echo "Region: $region"
echo "Private Key: [EXTRACTED]"
cat <<EOF > "$CREDENTIALS_FILE"
{
  "tenancy_ocid": "$tenancy_ocid",
  "user_ocid": "$user_ocid",
  "fingerprint": "$fingerprint",
  "private_key": "$escaped_key_content",
  "region": "$region"
}
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ OCI credentials successfully stored in $CREDENTIALS_FILE"
    echo "📝 Logs are available in $LOGS_FILE"
else
    error_msg="Failed to create credentials file $CREDENTIALS_FILE"
    echo "$error_msg"
    log_error "$error_msg"
    exit 1
fi 