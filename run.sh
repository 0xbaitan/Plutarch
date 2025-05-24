#!/bin/bash

# Utility function to pad strings
pad() {
    local string="$1"
    local length="$2"
    printf "%-${length}s" "$string"
}


# Print error message
print_error() {
    local message="$1"
    echo -e "\e[31mError: $message\e[0m"
}

# Load environment variables from a .env file
load_env_file() {
    local env_file=".env"
    if [[ -e "$env_file" ]]; then
        echo "Loading environment variables from $env_file"
        set -o allexport
        source "$env_file"
        set +o allexport
    else
        echo "No .env file found. Skipping environment variable loading."
    fi
}


# Check if Docker is installed
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker to proceed."
        exit 1
    fi
}

# Check Dockerfile.dev exists
check_docker_compose_exists() {
    check_docker_installed
    local docker_compose_file="docker-compose.dev.yaml"
    if [[ ! -f "$docker_compose_file" ]]; then
        print_error "Docker Compose file '$docker_compose_file' does not exist."
        echo "Please ensure you have a valid Docker Compose file in the current directory."
        exit 1
    fi
}

# Build Docker image using Docker Compose
build_docker() {
    check_docker_compose_exists
    echo "Building Docker..."
    docker-compose -f docker-compose.dev.yaml build
    if [[ $? -ne 0 ]]; then
        print_error "Docker build failed. Please check the Dockerfile and try again."
        exit 1
    fi
}

# Start Docker containers using Docker Compose
start_docker() {
    check_docker_compose_exists
    echo "Starting Docker containers..."
    docker-compose -f docker-compose.dev.yaml up -d
    if [[ $? -ne 0 ]]; then
        print_error "Failed to start Docker containers. Please check the Docker Compose file."
        exit 1
    fi
}

# Stop Docker containers using Docker Compose
stop_docker() {
    check_docker_compose_exists
    echo "Stopping Docker containers..."
    docker-compose -f docker-compose.dev.yaml down
    if [[ $? -ne 0 ]]; then
        print_error "Failed to stop Docker containers. Please check the Docker Compose file."
        exit 1
    fi
}

# Help function
help() {
    local padded_help_message
    local padded_version_message
    padded_help_message=$(pad "Show this help message" 20)
    padded_version_message=$(pad "Show version information" 20)
    echo "Usage: run.sh [options]"
    echo "Options:"
    echo -e "\t--help, -h\t$padded_help_message"
    echo -e "\t--version, -v\t$padded_version_message"
    echo
    exit 0
}

# Version function
version() {
    echo "run.sh version 1.0"
    exit 0
}

# Main function to handle command line arguments
main() {
    load_env_file
    case "$1" in
        --help|-h)
            help
            ;;
        --version|-v)
            version
            ;;
        build)
            build_docker
            ;;
        start)
            start_docker
            ;;
        stop)
            stop_docker
            ;;
        *)
            print_error "Invalid option entered"
            echo "Use --help or -h for usage information."
            exit 1
            ;;
    esac
    exit 0
}


main "$@"
