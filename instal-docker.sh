#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[33m'
BLUE='\033[36m'
FONT='\033[0m'
GREENBG='\033[42;37m'
REDBG='\033[41;37m'
GRAY='\e[1;30m'
NC='\033[0m' # No Color

# Progress 1: Set up the repository
echo -e "${BLUE}[Progress 1: Set up the repository]${NC}"

# Step 1
echo -e "${YELLOW}[Step 1]Update the apt package index and install packages to allow apt to use a repository over HTTPS:${NC}"
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Step 2
echo -e "${YELLOW}[Step 2] Add Docker’s official GPG key:${NC}"
sudo mkdir -m 0755 -p /etc/apt/keyrings

if [ -f /etc/apt/keyrings/docker.gpg ]; then
  echo -e "${YELLOW}Docker's official GPG key already exists.${NC}"
else
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

# Step 3
echo -e "${YELLOW}[Step 3]Use the following command to set up the repository:${NC}"

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Progress 2: Install Docker Engine
echo -e "${BLUE}[Progress 2: Install Docker Engine]${NC}"

# Step 1
echo -e "${YELLOW}[Step 1]Update the apt package index:${NC}"
sudo apt-get update

# Step 2
echo -e "${YELLOW}[Step 2]Install Docker Engine, containerd, and Docker Compose.${NC}"
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${GREEN}Instalasi berhasil.${NC}"

echo -e "${BLUE}[Progress 3: Post Installation]${NC}"

echo -e "${YELLOW}[Step 1]Create the docker group.${NC} "
sudo groupadd docker

echo -e "${YELLOW}[Step 2]Add current user to the docker group.${NC}"

sudo usermod -aG docker $USER

echo -e "${YELLOW}[Step 3]Logout to apply configuration.${NC}"

logout

vless://f5e9ed39-eeea-4685-8822-4c8dd8457790@backup.xvf.my.id:443?encryption=none&security=tls&type=tcp&host=backup.xvf.my.id&headerType=none&sni=backup.xvf.my.id&flow=xtls-rprx-vision#default_VLESS_TCP/TLS_Vision