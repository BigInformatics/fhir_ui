# Build stage
FROM node:20-alpine AS build

WORKDIR /build

# Clone the Medplum repository
RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/medplum/medplum.git .

# Build the app (uses .env.defaults with localhost:8103)
RUN npm ci && \
    npm run build -- --filter=@medplum/app

# Runtime stage
FROM caddy:2-alpine

# Copy the built app
COPY --from=build /build/packages/app/dist /usr/share/caddy/html

# Copy Medplum's official entrypoint and adapt for Caddy
COPY --from=build /build/packages/app/docker-entrypoint.sh /tmp/medplum-entrypoint.sh

# Create our entrypoint that uses Medplum's logic but for Caddy
RUN cat /tmp/medplum-entrypoint.sh | \
    sed 's|/usr/share/nginx/html|/usr/share/caddy/html|g' | \
    sed 's|exec nginx -g.*|exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile|g' \
    > /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh && \
    rm /tmp/medplum-entrypoint.sh

# Create Caddyfile
COPY <<EOF /etc/caddy/Caddyfile
:3000 {
  root * /usr/share/caddy/html
  encode gzip
  file_server
  try_files {path} /index.html
  header /assets/* {
    Cache-Control "public, max-age=31536000, immutable"
  }
}
EOF

EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
