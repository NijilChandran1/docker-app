# Project Structure

```
docker-app/
├── frontend/                    # Angular frontend service
│   ├── src/
│   │   ├── app/
│   │   │   └── app.component.ts
│   │   ├── index.html
│   │   ├── main.ts
│   │   └── styles.css
│   ├── angular.json
│   ├── package.json
│   ├── tsconfig.json
│   ├── tsconfig.app.json
│   ├── Dockerfile
│   └── nginx.conf
├── backend/                     # FastAPI backend service
│   ├── main.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env
├── database/                    # PostgreSQL database service
│   ├── init.sql
│   ├── postgresql.conf
│   ├── pg_hba.conf
│   └── Dockerfile
├── docker-compose.db.yml        # Database compose file
├── docker-compose.app.yml       # Application compose file
├── manage.sh                    # Management script
├── README.md                    # Documentation
└── .dockerignore
```

## Architecture Overview

The application consists of three main services:

1. **Angular Frontend** (Port 80)
   - Built with Angular 17
   - Served by Nginx
   - Communicates with backend via API calls
   - Includes CORS handling and API proxy

2. **FastAPI Backend** (Port 8000)
   - Python FastAPI application
   - SQLAlchemy ORM for database operations
   - CORS enabled for frontend communication
   - Health check endpoints

3. **PostgreSQL Database** (Port 5432)
   - PostgreSQL 15 with Alpine Linux
   - Initialization scripts for sample data
   - Persistent volume storage

## Network Configuration

All services communicate through an external Docker network named `app_network`. This allows:
- Service isolation
- Inter-service communication
- Scalability
- Network security

## Key Features

### Frontend Features
- Responsive design with modern CSS
- HTTP client for API integration
- Error handling and loading states
- Production-ready Nginx configuration

### Backend Features
- RESTful API endpoints
- Database ORM with SQLAlchemy
- Automatic API documentation (FastAPI)
- Health check endpoint
- CORS middleware

### Database Features
- Persistent data storage
- Initialization scripts
- Sample data insertion
- Health checks

## API Endpoints

- `GET /api/data` - Get all data items
- `POST /api/data` - Create new data item
- `GET /api/data/{id}` - Get specific data item
- `GET /health` - Backend health check

## Management Commands

The `manage.sh` script provides comprehensive management:

```bash
./manage.sh start      # Start all services
./manage.sh stop       # Stop all services
./manage.sh status     # Check service status
./manage.sh logs app   # View application logs
./manage.sh logs db    # View database logs
./manage.sh build      # Build all images
./manage.sh cleanup    # Remove all resources
```

## Docker Compose Files

### Database Compose (docker-compose.db.yml)
- PostgreSQL service with custom initialization
- Persistent volume for data storage
- Health checks
- External network connection

### Application Compose (docker-compose.app.yml)
- Frontend and backend services
- Service dependencies
- Port mappings
- Health checks
- External network connection

## Quick Start Instructions

1. Create external network:
   ```bash
   docker network create app_network
   ```

2. Start database:
   ```bash
   docker compose -f docker-compose.db.yml up -d
   ```

3. Start application services:
   ```bash
   docker compose -f docker-compose.app.yml up -d
   ```

4. Access the application:
   - Frontend: http://localhost:80
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

## Data Flow

1. User interacts with Angular frontend (port 80)
2. Frontend makes HTTP requests to backend API (port 8000)
3. Backend processes requests and queries PostgreSQL database (port 5432)
4. Database returns data to backend
5. Backend sends response to frontend
6. Frontend displays data to user

This architecture demonstrates a complete full-stack application with proper separation of concerns and Docker containerization.

