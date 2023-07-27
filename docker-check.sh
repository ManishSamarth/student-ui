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
install_docker_centos() {
    echo "Installing Docker..."
    sudo yum update -y
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
}

# Main script logic
if check_docker_installed; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Installing it..."
    install_docker_centos
fi
