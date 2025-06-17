# Multi-stage build for Angular with Nginx

# Stage 1: Build the Angular application
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build:prod

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the built application from the build stage
COPY --from=build /app/dist/angular-frontend /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/certs/
COPY certs/nginx-selfsigned.crt /etc/nginx/certs/nginx-selfsigned.crt
COPY certs/nginx-selfsigned.key /etc/nginx/certs/nginx-selfsigned.key
RUN chmod 644 /etc/nginx/certs/nginx-selfsigned.crt /etc/nginx/certs/nginx-selfsigned.key

# Expose port 3000
EXPOSE ${FRONTEND_HTTP_PORT:-3000} ${FRONTEND_HTTPS_PORT:-3000}

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

