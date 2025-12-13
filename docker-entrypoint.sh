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

# Find all files in the assets directory and replace placeholders
# This replaces BOTH the placeholder tokens AND the hardcoded localhost:8103 from build
find /usr/share/caddy/assets -type f -exec sed -i \
  -e "s|__MEDPLUM_BASE_URL__|${MEDPLUM_BASE_URL}|g" \
  -e "s|http://localhost:8103/|${MEDPLUM_BASE_URL}|g" \
  -e "s|__MEDPLUM_CLIENT_ID__|${MEDPLUM_CLIENT_ID}|g" \
  -e "s|__GOOGLE_CLIENT_ID__|${GOOGLE_CLIENT_ID}|g" \
  -e "s|__RECAPTCHA_SITE_KEY__|${RECAPTCHA_SITE_KEY}|g" \
  -e "s|__MEDPLUM_REGISTER_ENABLED__|${MEDPLUM_REGISTER_ENABLED}|g" \
  -e "s|__MEDPLUM_AWS_TEXTRACT_ENABLED__|${MEDPLUM_AWS_TEXTRACT_ENABLED}|g" \
  {} \;

echo "Configuration complete. Starting Caddy..."

# Start Caddy
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
