#!/bin/bash
# Update the instance and install nginx
sudo yum update -y
sudo amazon-linux-extras install nginx1.12 -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Go
wget https://dl.google.com/go/go1.19.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Clone the silly-demo application
git clone https://github.com/mseheda/golang-demo.git /home/ec2-user/golang-demo
cd /home/ec2-user/golang-demo

# Build the application for Linux
GOOS=linux GOARCH=amd64 go build -o golang-demo
chmod +x golang-demo

# Start the application in the background
./golang-demo &

# Configure nginx as a reverse proxy for the application
sudo tee /etc/nginx/conf.d/golang-demo.conf > /dev/null <<EOL
server {
    listen 80;
    location / {
        proxy_pass http://localhost:8080;  # app runs on port 8080
    }
}
EOL

# Restart nginx
sudo systemctl restart nginx
