# Docker Compose Application

This is a complete Docker Compose setup with Angular frontend, FastAPI backend, and PostgreSQL database.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Angular       │    │   FastAPI       │    │   PostgreSQL    │
│   Frontend      │────│   Backend       │────│   Database      │
│   (Port 3000)   │    │   (Port 8001)   │    │   (Port 5432)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  app_network    │
                    │ (External)      │
                    └─────────────────┘
```

## Services

### Frontend (Angular + Nginx)
- **Internal Container Port**: 3000 (configurable)
- **External Host Port**: 443 (HTTPS, configurable), 8080 (HTTP, configurable)
- **Technology**: Angular 17 with Nginx
- **Features**: 
  - Responsive design
  - API integration with backend
  - Production-ready Nginx configuration
  - CORS handling
  - HTTPS enabled with self-signed certificates

### Backend (FastAPI)
- **Internal Container Port**: 8001 (configurable)
- **External Host Port**: 8001 (configurable)
- **Technology**: FastAPI with SQLAlchemy
- **Features**:
  - RESTful API endpoints
  - Database ORM with SQLAlchemy
  - CORS enabled
  - Health check endpoint
  - Automatic API documentation

### Database (PostgreSQL)
- **Internal Container Port**: 5432
- **External Host Port**: 5433 (configurable)
- **Technology**: PostgreSQL 15
- **Features**:
  - Persistent data storage
  - Initialization scripts
  - Custom configuration
  - Health checks

## Quick Start

### Prerequisites
- Docker
- Docker Compose

### Start All Services
```bash
./manage.sh start
```

### Access the Application
- **Frontend**: `https://localhost` (or `https://localhost:443`) - You might need to accept a self-signed certificate warning.
- **Backend API**: `http://localhost:8001`
- **API Documentation**: `http://localhost:8001/docs`
- **Backend Health**: `http://localhost:8001/health`

### Stop All Services
```bash
./manage.sh stop
```

## Port Mapping and Configuration

This setup uses configurable ports for the frontend and backend services. This allows you to run other services on your host machine without port conflicts.

### Frontend Port Mapping
- **Internal Container Port**: The Nginx server inside the `angular_frontend` container listens on port `3000` for both HTTP and HTTPS traffic.
- **External Host Port (HTTPS)**: By default, host port `443` is mapped to the container's internal port `3000` for HTTPS. You can change this by setting the `FRONTEND_HOST_HTTPS_PORT` environment variable.
- **External Host Port (HTTP Redirection)**: By default, host port `8080` is mapped to the container's internal port `3000` for HTTP traffic, which is then redirected to HTTPS. You can change this by setting the `FRONTEND_HOST_HTTP_PORT` environment variable.

**Example: To run frontend on host HTTPS port 8443 and HTTP port 8081:**
```yaml
# In docker-compose.app.yml
services:
  frontend:
    ports:
      - "8443:3000" # Maps host 8443 to container 3000 (HTTPS)
      - "8081:3000" # Maps host 8081 to container 3000 (HTTP redirection)
```
Or by setting environment variables before running `docker compose up`:
```bash
export FRONTEND_HOST_HTTPS_PORT=8443
export FRONTEND_HOST_HTTP_PORT=8081
./manage.sh start
```

### Backend Port Mapping
- **Internal Container Port**: The FastAPI application inside the `fastapi_backend` container listens on port `8001`.
- **External Host Port**: By default, host port `8001` is mapped to the container's internal port `8001`. You can change this by setting the `BACKEND_HOST_PORT` environment variable.

**Example: To run backend on host port 9000:**
```yaml
# In docker-compose.app.yml
services:
  backend:
    ports:
      - "9000:8001" # Maps host 9000 to container 8001
```
Or by setting environment variables before running `docker compose up`:
```bash
export BACKEND_HOST_PORT=9000
./manage.sh start
```

### Database Port Mapping
- **Internal Container Port**: The PostgreSQL database inside the `postgres_test_db` container listens on port `5432`.
- **External Host Port**: By default, host port `5433` is mapped to the container's internal port `5432`. You can change this by modifying `docker-compose.db.yml`.

**Example: To run database on host port 5434:**
```yaml
# In docker-compose.db.yml
services:
  database:
    ports:
      - "5434:5432" # Maps host 5434 to container 5432
```

## Management Commands

The `manage.sh` script provides convenient commands to manage the application:

```bash
# Start all services
./manage.sh start

# Stop all services
./manage.sh stop

# Restart all services
./manage.sh restart

# Check status
./manage.sh status

# View logs
./manage.sh logs app    # Application logs
./manage.sh logs db     # Database logs

# Build images
./manage.sh build

# Clean up everything
./manage.sh cleanup

# Manage network
./manage.sh network create
./manage.sh network remove

# Manage individual services
./manage.sh db start
./manage.sh db stop
./manage.sh app start
./manage.sh app stop
```

## Docker Compose Files

### docker-compose.db.yml
Contains the PostgreSQL database service with:
- Custom initialization scripts
- Persistent volume storage
- Health checks
- Custom configuration

### docker-compose.app.yml
Contains the frontend and backend services with:
- Service dependencies
- Health checks
- Port mappings
- Environment variables

## Network Configuration

The application uses an external Docker network named `app_network` that must be created before starting the services. This allows for:
- Service isolation
- Inter-service communication
- Scalability
- Network security

## Environment Variables

### Backend (`backend/.env`)
```
DATABASE_URL=postgresql://postgres:password@database:5432/appdb
PYTHONPATH=/app
```

### Backend (Docker Compose `docker-compose.app.yml`)
- `BACKEND_HOST_PORT`: Host port for the backend (default: 8001)
- `BACKEND_PORT`: Internal container port for the backend (default: 8001)

### Frontend (Docker Compose `docker-compose.app.yml`)
- `FRONTEND_HOST_HTTPS_PORT`: Host port for HTTPS access to frontend (default: 443)
- `FRONTEND_HOST_HTTP_PORT`: Host port for HTTP access to frontend (default: 8080)
- `FRONTEND_HTTP_PORT`: Internal container port for HTTP redirection (default: 3000)
- `FRONTEND_HTTPS_PORT`: Internal container port for HTTPS (default: 3000)

### Database
```
POSTGRES_DB=appdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
```

## API Endpoints

### GET /api/data
Returns all data items from the database.

### POST /api/data
Creates a new data item.

### GET /api/data/{id}
Returns a specific data item by ID.

### GET /health
Health check endpoint for the backend service.

## Development

### Frontend Development
The Angular application is located in the `frontend/` directory and includes:
- Modern Angular 17 setup
- HTTP client for API communication
- Responsive CSS styling
- Production build configuration

### Backend Development
The FastAPI application is located in the `backend/` directory and includes:
- SQLAlchemy ORM models
- Pydantic data validation
- CORS middleware
- Database initialization
- Health check endpoints

### Database Development
The PostgreSQL setup is located in the `database/` directory and includes:
- Initialization SQL scripts
- Custom PostgreSQL configuration
- Authentication settings
- Performance tuning

## Production Considerations

1. **Security**: Update default passwords and use environment variables
2. **SSL/TLS**: Configure HTTPS for production deployment
3. **Monitoring**: Add logging and monitoring solutions
4. **Backup**: Implement database backup strategies
5. **Scaling**: Consider using Docker Swarm or Kubernetes for scaling

## Troubleshooting

### Common Issues

1. **Network not found**: Run `./manage.sh network create`
2. **Port conflicts**: Check if configured ports are in use
3. **Database connection**: Ensure database is fully started before backend
4. **CORS issues**: Check backend CORS configuration
5. **SSL Certificate Errors**: Ensure certificates are correctly generated and copied into the frontend container. Run `./manage.sh cleanup` and re-generate certificates before building.

### Logs
```bash
# View all application logs
./manage.sh logs app

# View database logs
./manage.sh logs db

# View specific service logs
docker compose -f docker-compose.app.yml logs frontend
docker compose -f docker-compose.app.yml logs backend
docker compose -f docker-compose.db.yml logs database
```

### Health Checks
```bash
# Check backend health
curl http://localhost:8001/health

# Check frontend
curl https://localhost

# Check database connection
docker exec postgres_test_db pg_isready -U postgres -d appdb
```

