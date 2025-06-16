#!/bin/bash

# Script to manage the Docker Compose application
# This script handles network creation and service management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Network name
NETWORK_NAME="app_network"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create external network
create_network() {
    print_status "Creating external network: $NETWORK_NAME"
    
    if docker network ls | grep -q "$NETWORK_NAME"; then
        print_warning "Network $NETWORK_NAME already exists"
    else
        docker network create "$NETWORK_NAME"
        print_success "Network $NETWORK_NAME created successfully"
    fi
}

# Function to remove external network
remove_network() {
    print_status "Removing external network: $NETWORK_NAME"
    
    if docker network ls | grep -q "$NETWORK_NAME"; then
        docker network rm "$NETWORK_NAME"
        print_success "Network $NETWORK_NAME removed successfully"
    else
        print_warning "Network $NETWORK_NAME does not exist"
    fi
}

# Function to start database
start_database() {
    print_status "Starting database service..."
    docker compose -f docker compose.db.yml up -d
    print_success "Database service started"
}

# Function to start application services
start_app() {
    print_status "Starting application services..."
    docker compose -f docker compose.app.yml up -d
    print_success "Application services started"
}

# Function to stop database
stop_database() {
    print_status "Stopping database service..."
    docker compose -f docker compose.db.yml down
    print_success "Database service stopped"
}

# Function to stop application services
stop_app() {
    print_status "Stopping application services..."
    docker compose -f docker compose.app.yml down
    print_success "Application services stopped"
}

# Function to show logs
show_logs() {
    local service=$1
    if [ "$service" = "db" ]; then
        docker compose -f docker compose.db.yml logs -f
    elif [ "$service" = "app" ]; then
        docker compose -f docker compose.app.yml logs -f
    else
        print_error "Invalid service. Use 'db' or 'app'"
        exit 1
    fi
}

# Function to show status
show_status() {
    print_status "Checking service status..."
    echo
    echo "=== Network Status ==="
    if docker network ls | grep -q "$NETWORK_NAME"; then
        print_success "Network $NETWORK_NAME exists"
    else
        print_error "Network $NETWORK_NAME does not exist"
    fi
    
    echo
    echo "=== Database Services ==="
    docker compose -f docker compose.db.yml ps
    
    echo
    echo "=== Application Services ==="
    docker compose -f docker compose.app.yml ps
    
    echo
    echo "=== Service Health ==="
    echo "Frontend: http://localhost:80"
    echo "Backend API: http://localhost:8000"
    echo "Backend Health: http://localhost:8000/health"
    echo "Database: localhost:5432"
}

# Function to build services
build_services() {
    print_status "Building all services..."
    docker compose -f docker-compose.db.yml build
    docker compose -f docker-compose.app.yml build
    print_success "All services built successfully"
}

# Function to start all services
start_all() {
    create_network
    start_database
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    sleep 10
    
    start_app
    
    print_success "All services started successfully!"
    echo
    print_status "Application URLs:"
    echo "  Frontend: http://localhost:80"
    echo "  Backend API: http://localhost:8000"
    echo "  Backend Health: http://localhost:8000/health"
}

# Function to stop all services
stop_all() {
    stop_app
    stop_database
    print_success "All services stopped"
}

# Function to restart all services
restart_all() {
    print_status "Restarting all services..."
    stop_all
    start_all
}

# Function to clean up everything
cleanup() {
    print_status "Cleaning up all resources..."
    stop_all
    
    # Remove volumes
    print_status "Removing volumes..."
    docker compose -f docker compose.db.yml down -v
    docker compose -f docker compose.app.yml down -v
    
    # Remove images
    print_status "Removing images..."
    docker compose -f docker compose.db.yml down --rmi all
    docker compose -f docker compose.app.yml down --rmi all
    
    remove_network
    print_success "Cleanup completed"
}

# Main script logic
case "$1" in
    "start")
        start_all
        ;;
    "stop")
        stop_all
        ;;
    "restart")
        restart_all
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "build")
        build_services
        ;;
    "cleanup")
        cleanup
        ;;
    "network")
        case "$2" in
            "create")
                create_network
                ;;
            "remove")
                remove_network
                ;;
            *)
                print_error "Usage: $0 network {create|remove}"
                exit 1
                ;;
        esac
        ;;
    "db")
        case "$2" in
            "start")
                create_network
                start_database
                ;;
            "stop")
                stop_database
                ;;
            *)
                print_error "Usage: $0 db {start|stop}"
                exit 1
                ;;
        esac
        ;;
    "app")
        case "$2" in
            "start")
                start_app
                ;;
            "stop")
                stop_app
                ;;
            *)
                print_error "Usage: $0 app {start|stop}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|build|cleanup|network|db|app}"
        echo
        echo "Commands:"
        echo "  start     - Create network and start all services"
        echo "  stop      - Stop all services"
        echo "  restart   - Restart all services"
        echo "  status    - Show status of all services"
        echo "  logs      - Show logs (specify 'db' or 'app')"
        echo "  build     - Build all Docker images"
        echo "  cleanup   - Stop services and remove all resources"
        echo "  network   - Manage network (create|remove)"
        echo "  db        - Manage database service (start|stop)"
        echo "  app       - Manage application services (start|stop)"
        echo
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs app"
        echo "  $0 network create"
        echo "  $0 db start"
        exit 1
        ;;
esac

