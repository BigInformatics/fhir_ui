FROM medplum/medplum-app:latest

# Copy entrypoint script (must be executable before COPY)
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
