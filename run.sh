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
    watch_changes
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


# Reset Volumes 
reset_volumes() {
    check_docker_compose_exists
    echo "Resetting Docker volumes..."
    docker-compose -f docker-compose.dev.yaml down -v
    if [[ $? -ne 0 ]]; then
        print_error "Failed to reset Docker volumes. Please check the Docker Compose file."
        exit 1
    fi
}


migration_update() {
    check_docker_compose_exists
    echo "Running database migrations..."
    docker exec -it plutarch_server mvn -e liquibase:update \
        -Dliquibase.url=${DATABASE_URL} \
        -Dliquibase.username=${DATABASE_USER} \
        -Dliquibase.password=${DATABASE_PASSWORD} \
        -Dliquibase.driver=org.postgresql.Driver \
        -Dliquibase.changeLogFile="db/changelog/db.changelog-master.xml"
    if [[ $? -ne 0 ]]; then
        print_error "Database migration failed. Please check the database connection and try again."
        exit 1
    else 
        echo "Database migrations completed successfully."
        exit 0
    fi
}

migration_generate() {
    check_docker_compose_exists
    echo "Generating database migration..."
    docker exec -it plutarch_server mvn -e liquibase:diffChangeLog \
        -Dliquibase.url=${DATABASE_URL} \
        -Dliquibase.username=${DATABASE_USER} \
        -Dliquibase.password=${DATABASE_PASSWORD} \
        -Dliquibase.driver=org.postgresql.Driver \
        -Dliquibase.diffChangeLogFile="server/src/main/resources/db/changelog/diff-changelog.xml" \
        -Dliquibase.referenceUrl=${LIQUI_REFERENCE_URL} \
        -Dliquibase.referenceDriver=${LIQUI_REFERENCE_DRIVER} 
    if [[ $? -ne 0 ]]; then
        print_error "Database migration generation failed. Please check the database connection and try again."
        exit 1
    else 
        echo "Database migration generation completed successfully."
        exit 0
    fi
}

watch_changes() {
    echo "Watching for changes in the source code..."
    while inotifywait -r -e modify,create,delete ./server/src/main; do
        check_docker_compose_exists
        echo "Changes detected. Compiling source code..."
        docker exec -it plutarch_server mvn clean compile
        if [[ $? -ne 0 ]]; then
            print_error "Compilation failed. Please check the source code for errors."
        else
            echo "Source code compiled successfully."
        fi
    done 
}

# Help function
help() {
    local padded_help_message
    local padded_version_message
    local padded_migration_update_message
    local padded_migration_generate_message
    local padded_start_message
    local padded_stop_message
    local padded_build_message
    local padded_reset_message
    local pad_length=40
    padded_help_message=$(pad "Show this help message" $pad_length)
    padded_version_message=$(pad "Show version information" $pad_length)
    padded_migration_update_message=$(pad "Run database migrations" $pad_length)
    padded_migration_generate_message=$(pad "Generate database migration" $pad_length)
    padded_start_message=$(pad "Start Docker containers" $pad_length)
    padded_stop_message=$(pad "Stop Docker containers" $pad_length)
    padded_build_message=$(pad "Build Docker image" $pad_length)
    padded_reset_message=$(pad "Reset Docker volumes" $pad_length)
    echo "Usage: run.sh [options]"
    echo "Options:"
    echo -e "\t--help, -h\t\t$padded_help_message"
    echo -e "\t--version, -v\t\t$padded_version_message"
    echo -e "\tbuild\t\t\t$padded_build_message"
    echo -e "\tstart\t\t\t$padded_start_message"
    echo -e "\tstop\t\t\t$padded_stop_message"
    echo -e "\tmigration:update\t$padded_migration_update_message"
    echo -e "\tmigration:generate\t$padded_migration_generate_message"
    echo -e "\treset\t\t\t$padded_reset_message"
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
        
        reset)
            reset_volumes
            ;;
        
        migration:update)
            migration_update
            ;;
        
        migration:generate)
            migration_generate
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
