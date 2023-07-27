#!/bin/bash

# Function to check if git is installed
check_git_installed() {
    if command -v git &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install git on CentOS/RHEL
 install_git() {
    echo "Installing Docker..."
    sudo yum update -y
    sudo yum install -y git
    
  
}

# Main script logic
if check_git_installed; then
    echo "git is already installed."
else
    echo "git is not installed. Installing it..."
    install_git
fi
