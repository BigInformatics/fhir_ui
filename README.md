# UI from Medplum App Package

A custom Docker image for the [Medplum App](https://github.com/medplum/medplum/tree/main/packages/app) - web interface for managing the FHIR server.

## Overview

This repository builds a Docker image of the Medplum app from source, using Caddy as the web server. The image supports runtime configuration through environment variables, making it easy to deploy across different environments.

## Features

- Built from official Medplum source
- Caddy web server

## Quick Start

### Using Pre-built Image from GitHub Container Registry

```bash
docker run -p 3000:3000 \
  -e MEDPLUM_BASE_URL="your-fhir-url-here" \
  -e MEDPLUM_CLIENT_ID="your-client-id" \
  ghcr.io/biginformatics/fhir_ui:latest
```

### Using Docker Compose

1. Set your environment variables (either in `.env` file or export them):

```bash
export MEDPLUM_BASE_URL="your-fhir-url-here"
export MEDPLUM_CLIENT_ID="your-client-id"
export GOOGLE_CLIENT_ID="your-google-client-id"
export RECAPTCHA_SITE_KEY="your-recaptcha-key"
export MEDPLUM_REGISTER_ENABLED="true"
export MEDPLUM_AWS_TEXTRACT_ENABLED="false"
```

2. Start the service:

```bash
docker compose up -d
```

The app will be available at `http://localhost:3000`

## Configuration

### Required Environment Variables (For the Medplum App)

- `MEDPLUM_BASE_URL` - The base URL of your Medplum/FHIR server
  - **MUST include protocol (http:// or https://) AND trailing slash**
  - Example: `https://fhir.example.com/`
  - Example: `http://localhost:8103/`
- `MEDPLUM_CLIENT_ID` - OAuth client ID for authentication

### Optional Environment Variables (For the Medplum App)

- `GOOGLE_CLIENT_ID` - Google OAuth client ID (for Google sign-in)
- `RECAPTCHA_SITE_KEY` - reCAPTCHA site key (defaults to test key)
- `MEDPLUM_REGISTER_ENABLED` - Enable user registration (default: `true`)
- `MEDPLUM_AWS_TEXTRACT_ENABLED` - Enable AWS Textract features (default: `true`)

## Building from Source

### Local Build

```bash
docker build -t fhir-ui:local .
```

### GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds and publishes the image to GitHub Container Registry (ghcr.io) on every push to the `main` branch.

The workflow:
- Builds the image from Medplum source
- Pushes to `ghcr.io/biginformatics/fhir_ui:latest`
- Tags images with branch names and commit SHAs
- Uses build cache for faster builds

## Architecture

### Multi-Stage Build

1. **Build Stage**: Uses Node.js to clone Medplum repository, install dependencies, and build the app
2. **Runtime Stage**: Uses Caddy Alpine image to serve the built static files

### Runtime Configuration

The entrypoint script (`docker-entrypoint.sh`) runs before starting Caddy and:
1. Sets default values for any missing environment variables
2. Searches for placeholder tokens in the built JavaScript files
3. Replaces placeholders with actual environment variable values
4. Starts Caddy web server

### Directory Structure

```
/usr/share/caddy/          # Web root directory
├── assets/                # Compiled JavaScript/CSS (placeholders replaced here)
├── img/                   # Static images
└── index.html             # Main HTML file
```

## Development

### Testing Locally

Build and run locally with your environment variables:

```bash
docker build -t fhir-ui:test .
docker run -p 3000:3000 \
  -e MEDPLUM_BASE_URL="http://localhost:8103" \
  fhir-ui:test
```

### Viewing Logs

```bash
docker compose logs -f medplum-app
```

You should see output like:
```
Configuring Medplum app...
MEDPLUM_BASE_URL: your-fhir-url-here
Configuration complete. Starting Caddy...
```

## Deployment

### Server Deployment

1. Ensure environment variables are set on your server
2. Pull the latest image:
   ```bash
   docker compose pull
   ```
3. Restart the service:
   ```bash
   docker compose up -d
   ```

### Health Checks

The service includes a health check that verifies Caddy is responding on port 3000:
- Interval: 10 seconds
- Timeout: 5 seconds
- Retries: 5

## Troubleshooting

### Mixed content errors or malformed URLs (http://https//...)

This indicates `MEDPLUM_BASE_URL` is not formatted correctly. Common mistakes:
- ❌ `fhir.example.com` (missing protocol)
- ❌ `https://fhir.example.com` (missing trailing slash)
- ✅ `https://fhir.example.com/` (correct format)

The Medplum client validates that the base URL starts with `http` and automatically ensures trailing slash.

### App connects to wrong server

Check that `MEDPLUM_BASE_URL` is correctly set and the container logs show the correct value during startup.

### Container fails to start

Check logs with `docker compose logs medplum-app` to see if there are any configuration errors.

### Changes to environment variables not taking effect

The container needs to be recreated (not just restarted) for environment variable changes:
```bash
docker compose up -d --force-recreate
```

## License

This project builds from the [Medplum project](https://github.com/medplum/medplum), which is licensed under Apache 2.0.

## Links

- [Medplum Documentation](https://www.medplum.com/docs)
- [Medplum GitHub](https://github.com/medplum/medplum)
- [FHIR Specification](https://www.hl7.org/fhir/)
