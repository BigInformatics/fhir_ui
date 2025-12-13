#!/bin/sh
set -e

# Defaults - will be overridden by environment variables passed to container
: ${MEDPLUM_BASE_URL:="http://localhost:8103/"}
: ${MEDPLUM_CLIENT_ID:=""}
: ${GOOGLE_CLIENT_ID:=""}
: ${RECAPTCHA_SITE_KEY:=""}
: ${MEDPLUM_REGISTER_ENABLED:="true"}
: ${MEDPLUM_AWS_TEXTRACT_ENABLED:="true"}

echo "Configuring Medplum app..."
echo "MEDPLUM_BASE_URL: ${MEDPLUM_BASE_URL}"

# Validate MEDPLUM_BASE_URL format
if [ -n "$MEDPLUM_BASE_URL" ] && ! echo "$MEDPLUM_BASE_URL" | grep -q "^http"; then
  echo "ERROR: MEDPLUM_BASE_URL must start with http:// or https://"
  echo "Current value: ${MEDPLUM_BASE_URL}"
  echo "Example correct format: https://fhir.example.com/"
  exit 1
fi

# Find all files in the assets directory and replace placeholders
# This replaces BOTH the placeholder tokens AND the hardcoded localhost:8103 from build
# Handle all variations: with/without protocol, with/without trailing slash
# Also show what we're actually replacing for debugging
echo "Searching for localhost:8103 in assets..."
grep -r "localhost:8103" /usr/share/caddy/assets/ | head -3 || echo "No localhost:8103 found"

find /usr/share/caddy/assets -type f -exec sed -i \
  -e "s|__MEDPLUM_BASE_URL__|${MEDPLUM_BASE_URL}|g" \
  -e "s|baseUrl:\"http://localhost:8103/\"|baseUrl:\"${MEDPLUM_BASE_URL}\"|g" \
  -e "s|http://localhost:8103/|${MEDPLUM_BASE_URL}|g" \
  -e "s|http://localhost:8103|${MEDPLUM_BASE_URL}|g" \
  -e "s|localhost:8103/|${MEDPLUM_BASE_URL}|g" \
  -e "s|localhost:8103|${MEDPLUM_BASE_URL}|g" \
  -e "s|__MEDPLUM_CLIENT_ID__|${MEDPLUM_CLIENT_ID}|g" \
  -e "s|__GOOGLE_CLIENT_ID__|${GOOGLE_CLIENT_ID}|g" \
  -e "s|__RECAPTCHA_SITE_KEY__|${RECAPTCHA_SITE_KEY}|g" \
  -e "s|__MEDPLUM_REGISTER_ENABLED__|${MEDPLUM_REGISTER_ENABLED}|g" \
  -e "s|__MEDPLUM_AWS_TEXTRACT_ENABLED__|${MEDPLUM_AWS_TEXTRACT_ENABLED}|g" \
  {} \;

echo "After replacement, checking for localhost:8103..."
grep -r "localhost:8103" /usr/share/caddy/assets/ | head -3 || echo "Successfully replaced all localhost:8103 instances"

echo "Configuration complete. Starting Caddy..."

# Start Caddy
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
