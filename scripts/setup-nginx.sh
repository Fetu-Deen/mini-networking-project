#!/bin/bash
# Update the package repository
dnf update -y

# Install Nginx
dnf install nginx -y

# Start Nginx and enable it to run on system boot
systemctl start nginx
systemctl enable nginx

# Optional: Create a custom test page
echo "<h1>Hello from Amazon Linux 2023 Nginx Server</h1>" > /usr/share/nginx/html/index.html
