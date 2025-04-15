#!/bin/bash

DOMAIN_NAME="d15ee92f-8947-4cd0-b1eb-da285cca94dc.zop.dev"

if [ -z "$DOMAIN_NAME" ]; then
  echo "Usage: ./check_grafana_ready.sh <your-domain>"
  exit 1
fi

echo "🔍 Checking Grafana readiness for domain: $DOMAIN_NAME"

for i in {1..30}; do
  echo "⏳ Attempt $i: Checking Grafana login page..."
  RESPONSE=$(curl -sk https://grafana.$DOMAIN_NAME/login || true)

  if echo "$RESPONSE" | grep -q '<title>Grafana</title>'; then
    echo "✅ Grafana login page is reachable."

    echo "🔐 Checking TLS certificate for domain grafana.$DOMAIN_NAME..."
    CERT_HOSTNAME=$(echo | openssl s_client -connect grafana.$DOMAIN_NAME:443 -servername grafana.$DOMAIN_NAME 2>/dev/null \
      | openssl x509 -noout -subject | grep -o 'CN=.*' | cut -d= -f2)

    if echo "$CERT_HOSTNAME" | grep -q "$DOMAIN_NAME"; then
      echo "✅ TLS certificate is valid for grafana.$DOMAIN_NAME (CN: $CERT_HOSTNAME)"
      exit 0
    else
      echo "❌ Certificate CN mismatch. Got CN: $CERT_HOSTNAME, expected to include $DOMAIN_NAME"
    fi
  else
    echo "❌ Grafana UI not ready yet."
  fi

  echo "⏳ Waiting 10s before retrying..."
  sleep 10
done

echo "❌ Grafana was not ready after 30 attempts."
exit 1
