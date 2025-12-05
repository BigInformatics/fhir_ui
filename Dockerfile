FROM medplum/medplum-app:latest

# Only static ENV here if needed
ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /usr/src/medplum

EXPOSE 3000

