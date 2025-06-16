# Docker Compose Application

This is a complete Docker Compose setup with Angular frontend, FastAPI backend, and PostgreSQL database.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Angular       │    │   FastAPI       │    │   PostgreSQL    │
│   Frontend      │────│   Backend       │────│   Database      │
│   (Port 80)     │    │   (Port 8000)   │    │   (Port 5432)   │
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
- **Port**: 80
- **Technology**: Angular 17 with Nginx
- **Features**: 
  - Responsive design
  - API integration with backend
  - Production-ready Nginx configuration
  - CORS handling

### Backend (FastAPI)
- **Port**: 8000
- **Technology**: FastAPI with SQLAlchemy
- **Features**:
  - RESTful API endpoints
  - Database ORM with SQLAlchemy
  - CORS enabled
  - Health check endpoint
  - Automatic API documentation

### Database (PostgreSQL)
- **Port**: 5432
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
- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

### Stop All Services
```bash
./manage.sh stop
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

### Backend (.env)
```
DATABASE_URL=postgresql://postgres:password@database:5432/appdb
PYTHONPATH=/app
```

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
2. **Port conflicts**: Check if ports 80, 8000, or 5432 are in use
3. **Database connection**: Ensure database is fully started before backend
4. **CORS issues**: Check backend CORS configuration

### Logs
```bash
# View all application logs
./manage.sh logs app

# View database logs
./manage.sh logs db

# View specific service logs
docker-compose -f docker-compose.app.yml logs frontend
docker-compose -f docker-compose.app.yml logs backend
docker-compose -f docker-compose.db.yml logs database
```

### Health Checks
```bash
# Check backend health
curl http://localhost:8000/health

# Check frontend
curl http://localhost:80

# Check database connection
docker exec postgres_db pg_isready -U postgres -d appdb
```

