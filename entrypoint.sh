#!/bin/sh
set -e

echo "=========================================="
echo "Starting entrypoint script"
echo "MEDPLUM_BASE_URL: ${MEDPLUM_BASE_URL}"
echo "=========================================="

# Find the actual location of files
echo "Searching for files to replace..."
find / -name "*.js" -type f 2>/dev/null | head -10 || true

# Try multiple possible locations
for dir in /usr/share/nginx/html /usr/src/medplum /app; do
  if [ -d "$dir" ]; then
    echo "Found directory: $dir"
    echo "Contents:"
    ls -la "$dir" || true

    # Search for any JS files that might contain the base URL
    echo "Searching for localhost:8103 references in $dir..."
    grep -r "localhost:8103" "$dir" 2>/dev/null | head -5 || echo "No localhost:8103 found in $dir"

    # Try to replace in all files
    find "$dir" -type f \( -name "*.js" -o -name "*.json" -o -name "*.html" \) -exec sed -i \
      -e "s|__MEDPLUM_BASE_URL__|${MEDPLUM_BASE_URL}|g" \
      -e "s|__MEDPLUM_CLIENT_ID__|${MEDPLUM_CLIENT_ID}|g" \
      -e "s|__GOOGLE_CLIENT_ID__|${GOOGLE_CLIENT_ID}|g" \
      -e "s|__RECAPTCHA_SITE_KEY__|${RECAPTCHA_SITE_KEY}|g" \
      -e "s|__MEDPLUM_REGISTER_ENABLED__|${MEDPLUM_REGISTER_ENABLED}|g" \
      -e "s|__MEDPLUM_AWS_TEXTRACT_ENABLED__|${MEDPLUM_AWS_TEXTRACT_ENABLED}|g" \
      -e "s|http://localhost:8103|${MEDPLUM_BASE_URL}|g" \
      {} \; 2>/dev/null || echo "Could not modify files in $dir"
  fi
done

echo "=========================================="
echo "Environment variable replacement complete"
echo "=========================================="

# Get the original entrypoint/cmd from the base image
exec node /usr/src/medplum/packages/app/dist/index.js
