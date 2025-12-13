#!/bin/bash
# Debug script to check what's in the deployed container

echo "=== Checking environment variables ==="
docker exec <your-container-name> sh -c 'echo "MEDPLUM_BASE_URL: $MEDPLUM_BASE_URL"'

echo ""
echo "=== Checking for localhost:8103 in built files ==="
docker exec <your-container-name> sh -c 'grep -r "localhost:8103" /usr/share/caddy/assets/ | head -5'

echo ""
echo "=== Checking for your domain in built files ==="
docker exec <your-container-name> sh -c 'grep -r "fhir.biginformatics.com" /usr/share/caddy/assets/ | head -5'

echo ""
echo "=== Checking entrypoint script ==="
docker exec <your-container-name> cat /docker-entrypoint.sh | grep -A2 "s|http://localhost:8103"
