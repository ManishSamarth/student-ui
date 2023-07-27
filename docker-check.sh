#!/bin/bash

# Function to check if Docker is installed
check_docker_installed() {
    if command -v docker &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install Docker on CentOS/RHEL
install_docker() {
    echo "Installing Docker..."
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker jenkins || sudo usermod -aG docker ec2-user
}

# Main script logic
if check_docker_installed; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing it..."
    install_docker
fi
