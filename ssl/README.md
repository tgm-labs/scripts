# README for Nginx and Certbot Reverse Proxy Setup

## Introduction

This script automates the setup and management of a reverse proxy configuration using Nginx and Certbot. It allows you to easily configure multiple domains and subdomains with SSL support, routing traffic to different containers based on domain and port configurations.

## Features

- **Automatic installation** of Nginx and Certbot.
- **Reverse proxy configuration** for multiple domains and subdomains.
- **SSL certificate management** using Let's Encrypt via Certbot.
- **Automatic SSL renewal** management.
- **Support for dynamic port and domain configurations**.

## Configuration File

The configuration file is a JSON file that specifies the email for SSL certificate registration and a list of domains with their associated ports. Here is an example configuration:

```json
{
    "email": "tgm.bet@outlook.com",
    "domains": [
        {
            "domain": "tgm.bet",
            "external_port": 80,
            "container_port": 8080
        },
        {
            "domain": "tgm.bet",
            "external_port": 7080,
            "container_port": 8081
        },
        {
            "domain": "api.tgm.bet",
            "external_port": 80,
            "container_port": 8071
        }
    ]
}
```

### Key Points:
- **Domain**: The domain or subdomain for which the reverse proxy is configured.
- **External Port**: The port on the server that listens for incoming traffic. **Domains must have unique external ports** to avoid conflicts.
- **Container Port**: The port on the container or backend service to which the traffic is forwarded.

## Usage Instructions

### 1. Install
```bash
bash <(curl -s https://raw.githubusercontent.com/tgm-labs/scripts/main/ssl/run.sh)
```

### 2. Menu Options
1. **Install Nginx and Certbot**: If Nginx or Certbot are not yet installed, this option will be used to install these two packages.
   - **Nginx** is a high-performance HTTP and reverse proxy server.
   - **Certbot** is an automated tool for obtaining free SSL/TLS certificates from Let's Encrypt and automatically configuring the web server to use these certificates.
2. **Reload Configuration Files**: Reloads Nginx configuration files without restarting the entire service. This is typically used to apply configuration changes without interrupting current connections.
3. **Remove Certbot and Nginx**: Uninstalls Certbot and Nginx, removing related configuration files and services.
4. **Disable Automatic SSL Renewal**: If automatic SSL certificate renewal is enabled, this option provides the ability to disable that feature. This usually involves removing or modifying the script or hooks used to automatically update the certificate before it expires.
5. **Enable Automatic SSL Renewal**: If automatic SSL certificate renewal is not yet enabled, this option provides the ability to enable that feature. This sets up a hook script to reload the Nginx configuration after the certificate renewal, making the new certificate effective.
6. **Stop Nginx and Certbot Services**: Stops running Nginx and Certbot services.

### 3. Important Notes

- **Port Conflicts**: If multiple domains share the same external port, they must be distinct domains (e.g., `tgm.bet` and `api.tgm.bet`). If the domain is the same, ensure that each uses a unique external port (e.g., `80` and `7080` for `tgm.bet`).
- **SSL Certificates**: The script automatically obtains and renews SSL certificates using the email provided in the configuration file.

### 4. Example Scenario

For the provided configuration, the script will:

- Create a reverse proxy for `tgm.bet` on external port `80`, routing to `8080`.
- Create a reverse proxy for `tgm.bet` on external port `7080`, routing to `8081`.
- Create a reverse proxy for `api.tgm.bet` on external port `80`, routing to `8082`.

In this scenario, `tgm.bet` uses two different external ports (`80` and `7080`) for two services, while `api.tgm.bet` can share the external port `80` with `tgm.bet` since it is a different subdomain.

## Troubleshooting

- **Nginx Configuration Errors**: If Nginx fails to reload after applying configurations, review the error messages and check for port conflicts or syntax errors in the configuration files.
- **SSL Certificate Issues**: If Certbot fails to obtain an SSL certificate, ensure that your domain's DNS is correctly configured and that the domain points to your server's IP address.