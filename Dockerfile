# Build stage
FROM node:20-alpine AS build

WORKDIR /build

# Clone the Medplum repository
RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/medplum/medplum.git .

# Install dependencies and build the app
RUN npm ci && \
    npm run build -- --filter=@medplum/app

# Runtime stage
FROM caddy:2-alpine

# Copy the built app
COPY --from=build /build/packages/app/dist /usr/share/caddy

# Create Caddyfile
RUN echo ':3000 {' > /etc/caddy/Caddyfile && \
    echo '  root * /usr/share/caddy' >> /etc/caddy/Caddyfile && \
    echo '  encode gzip' >> /etc/caddy/Caddyfile && \
    echo '  file_server' >> /etc/caddy/Caddyfile && \
    echo '  try_files {path} /index.html' >> /etc/caddy/Caddyfile && \
    echo '  header /assets/* {' >> /etc/caddy/Caddyfile && \
    echo '    Cache-Control "public, max-age=31536000, immutable"' >> /etc/caddy/Caddyfile && \
    echo '  }' >> /etc/caddy/Caddyfile && \
    echo '}' >> /etc/caddy/Caddyfile

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/docker-entrypoint.sh"]
