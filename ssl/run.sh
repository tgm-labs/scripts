#!/bin/bash

# Check installed dependencies
check_dependencies() {
    echo "Checking dependencies..."

    DEPENDENCIES=("nginx" "certbot" "jq" "curl")
    for dep in "${DEPENDENCIES[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "$dep is not installed. Please install $dep before proceeding."
            return 1
        else
            echo "$dep is installed."
        fi
    done
}

# Install Nginx and Certbot
install_nginx_certbot() {
    echo "Installing Nginx and Certbot..."
    sudo apt-get update
    sudo apt-get install -y nginx certbot python3-certbot-nginx
    echo "Nginx and Certbot installation completed."
}

# Remove Nginx and Certbot
remove_nginx_certbot() {
    echo "Removing Nginx and Certbot..."
    sudo systemctl stop nginx
    sudo apt-get --purge remove nginx-common -y
    sudo apt-get --purge remove nginx* -y
    sudo apt-get autoremove

    sudo apt-get remove --purge certbot python3-certbot-nginx -y
    sudo apt-get autoremove
    sudo rm -rf /etc/nginx /etc/letsencrypt
    sudo rm -rf /var/lib/letsencrypt
    sudo rm -rf /var/log/letsencrypt

    echo "Nginx and Certbot removal completed."
}

# Reload configuration files
reload_configuration() {
    local config_url="https://raw.githubusercontent.com/tgm-labs/scripts/main/ssl/config.json"
    local config_file="/tmp/nginx_config.json"

    # Download the configuration file from the remote URL
    if ! curl -s -o "$config_file" "$config_url"; then
        echo "Failed to download configuration file from: $config_url"
        return 1
    fi

    if [ ! -f "$config_file" ]; then
        echo "Configuration file not found: $config_file"
        return 1
    fi

    local email=$(jq -r '.email' "$config_file")
    local domains=$(jq -c '.domains[]' "$config_file")

    # Remove existing Nginx configuration files and symbolic links
    sudo rm -f /etc/nginx/conf.d/*.conf
    sudo unlink /etc/nginx/sites-enabled/*

    # Loop through the domains and add each reverse proxy configuration
    while IFS= read -r domain_data; do
        local domain=$(echo "$domain_data" | jq -r '.domain')
        local external_port=$(echo "$domain_data" | jq -r '.external_port')
        local container_port=$(echo "$domain_data" | jq -r '.container_port')

        # SSL certificate path
        SSL_CERT_PATH="/etc/letsencrypt/live/$domain/fullchain.pem"
        SSL_KEY_PATH="/etc/letsencrypt/live/$domain/privkey.pem"

        # Check if the SSL certificate exists
        if [ ! -f "$SSL_CERT_PATH" ]; then
            echo "SSL certificate does not exist for $domain, obtaining certificate..."
            if sudo certbot --nginx -d "$domain" --non-interactive --agree-tos --email "$email"; then
                echo "Successfully obtained SSL certificate."
            else
                echo "Failed to obtain SSL certificate for $domain, please check the error log."
                continue
            fi
        else
            echo "SSL certificate already exists for $domain."
        fi

        # Configure Nginx
        NGINX_CONF="/etc/nginx/conf.d/$domain-$container_port.conf"

        echo "Creating Nginx configuration file: $NGINX_CONF"

        # Create the configuration file
        echo "server {
listen $external_port;
server_name $domain;
return 301 https://\$host\$request_uri;
location / {
    proxy_pass http://localhost:$container_port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
}" | sudo tee "$NGINX_CONF" > /dev/null

        echo "server {
listen 443 ssl;
server_name $domain;

ssl_certificate $SSL_CERT_PATH;
ssl_certificate_key $SSL_KEY_PATH;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
ssl_prefer_server_ciphers on;

location / {
    proxy_pass http://localhost:$container_port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
}" | sudo tee -a "$NGINX_CONF" > /dev/null

        # Activate the configuration and reload Nginx
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
        if sudo nginx -t; then
            sudo systemctl reload nginx
            echo "Nginx configuration succeeded and has been reloaded."
        else
            echo "Nginx configuration error, please check the configuration file."
            continue
        fi
    done <<< "$domains"
}

# Main menu
while true; do
    echo "Please choose an action:"

    check_dependencies

    if ! command -v nginx &> /dev/null || ! command -v certbot &> /dev/null; then
        echo "1) Install Nginx and Certbot"
    else
        echo "1) Reload Configuration Files"
        echo "2) Remove Certbot and Nginx"
    fi

    echo "9) Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            if ! command -v nginx &> /dev/null || ! command -v certbot &> /dev/null; then
                install_nginx_certbot
            else
                reload_configuration
            fi
            ;;
        2)
            remove_nginx_certbot
            ;;
        9)
            echo "Exiting program."
            break
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done