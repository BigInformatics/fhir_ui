# Build stage
FROM medplum/medplum-app:latest AS build

# Runtime stage with nginx
FROM nginx:alpine

# Copy built assets from medplum-app
COPY --from=build /usr/share/nginx/html /usr/share/nginx/html

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
