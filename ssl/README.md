# README for Nginx and Certbot Reverse Proxy Setup

## Introduction

This script automates the setup and management of a reverse proxy configuration using Nginx and Certbot. It simplifies configuring multiple domains and subdomains with SSL support, routing traffic to different containers based on domain and port configurations.

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
To install and configure Nginx and Certbot, run the following command:
```bash
bash <(curl -s https://raw.githubusercontent.com/tgm-labs/scripts/main/ssl/run.sh)
```

### 2. Menu Options
1. **Install Nginx and Certbot**: Installs Nginx and Certbot if they are not already installed.
   - **Nginx**: High-performance HTTP and reverse proxy server.
   - **Certbot**: Automated tool for obtaining and configuring SSL/TLS certificates from Let's Encrypt.

2. **Reload Configuration Files**: Reloads Nginx configuration files to apply changes without restarting the service.

3. **Remove Certbot and Nginx**: Uninstalls Certbot and Nginx, removing related configuration files and services.

4. **Disable Automatic SSL Renewal**: Disables automatic SSL certificate renewal if it is currently enabled.

5. **Enable Automatic SSL Renewal**: Enables automatic SSL certificate renewal, setting up a hook script to reload Nginx configuration after renewal.

6. **Stop Nginx and Certbot Services**: Stops the Nginx and Certbot services.

### 3. Important Notes

- **Port Conflicts**: Ensure that each domain has a unique external port if using the same domain or subdomain with multiple configurations. For example, `tgm.bet` can use ports `80` and `7080` for different services, while `api.tgm.bet` can also use port `80` since it is a different subdomain.

- **SSL Certificates**: The script automatically obtains and renews SSL certificates using the email provided in the configuration file.

### 4. Example Scenario

For the provided configuration, the script will:

- Set up a reverse proxy for `tgm.bet` on external port `80`, routing traffic to port `8080`.
- Set up a reverse proxy for `tgm.bet` on external port `7080`, routing traffic to port `8081`.
- Set up a reverse proxy for `api.tgm.bet` on external port `80`, routing traffic to port `8071`.

In this scenario, `tgm.bet` uses two different external ports (`80` and `7080`) for different services, while `api.tgm.bet` shares the external port `80` with `tgm.bet` since it is a different subdomain.

## Troubleshooting

- **Nginx Configuration Errors**: If Nginx fails to reload, check the error messages and verify configuration syntax and port allocations.

- **SSL Certificate Issues**: If Certbot fails to obtain or renew certificates, ensure your domain's DNS settings are correct and that the domain points to your server's IP address.