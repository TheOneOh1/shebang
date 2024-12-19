#!/bin/bash

# Docker Installation Script
# Supports: Ubuntu, Debian, CentOS, Rocky Linux
# Description: Automated Docker installation script for various Linux distributions

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_message "$RED" "Error: This script must be run as root or with sudo privileges"
        exit 1
    fi
}

# Detect Linux distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION_ID=$VERSION_ID
    else
        print_message "$RED" "Error: Cannot detect Linux distribution"
        exit 1
    fi
}

# Check if Docker is already installed
check_docker() {
    if command -v docker &> /dev/null; then
        print_message "$GREEN" "---------------------------------------------"
        print_message "$GREEN" "Docker is already installed"
        docker --version
        print_message "$GREEN" "---------------------------------------------"
        exit 0
    fi
}

# Install Docker on Debian/Ubuntu
install_docker_debian() {
    print_message "$YELLOW" "Installing Docker on Debian/Ubuntu..."

    # Remove old versions if they exist
    apt remove -y docker docker-engine docker.io containerd runc &> /dev/null

    # Update package index
    apt update &> /dev/null || {
        print_message "$RED" "Failed to update package index"
        exit 1
    }

    # Install prerequisites
    print_message "$YELLOW" "Installing prerequisites..."
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release &> /dev/null || {
        print_message "$RED" "Failed to install prerequisites"
        exit 1
    }

    # Add Docker's official GPG key
    print_message "$YELLOW" "Adding Docker's GPG key..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index again
    apt update &> /dev/null

    # Install Docker
    print_message "$YELLOW" "Installing Docker..."
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &> /dev/null || {
        print_message "$RED" "Failed to install Docker"
        exit 1
    }
}

# Install Docker on CentOS/Rocky Linux
install_docker_rhel() {
    print_message "$YELLOW" "Installing Docker on CentOS/Rocky Linux..."

    # Remove old versions if they exist
    yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine &> /dev/null

    # Install prerequisites
    print_message "$YELLOW" "Installing prerequisites..."
    yum install -y yum-utils &> /dev/null || {
        print_message "$RED" "Failed to install prerequisites"
        exit 1
    }

    # Add Docker repository
    yum-config-manager --add-repo https://download.docker.com/linux/${DISTRO}/docker-ce.repo &> /dev/null

    # Install Docker
    print_message "$YELLOW" "Installing Docker..."
    yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &> /dev/null || {
        print_message "$RED" "Failed to install Docker"
        exit 1
    }
}

# Configure Docker service
configure_docker() {
    print_message "$YELLOW" "Configuring Docker service..."
    systemctl start docker || {
        print_message "$RED" "Failed to start Docker service"
        exit 1
    }
    systemctl enable docker || {
        print_message "$RED" "Failed to enable Docker service"
        exit 1
    }
}

# Main installation function
install_docker() {
    case $DISTRO in
        "ubuntu"|"debian")
            install_docker_debian
            ;;
        "centos"|"rocky"|"rhel")
            install_docker_rhel
            ;;
        *)
            print_message "$RED" "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac

    configure_docker
    print_message "$GREEN" "\nDocker has been successfully installed and enabled!"
    docker --version
}

# Main script execution
main() {
    check_root
    detect_distribution
    check_docker
    install_docker
}

main
