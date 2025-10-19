# Local Development Setup Guide

This guide shows you how to run the Todo Application pipeline locally for development and testing.

## 🚀 **Option 1: Run Application Locally (Recommended)**

### Prerequisites
- ✅ Node.js 18+ (you have v22.20.0)
- ✅ npm (you have 10.9.3)
- PostgreSQL or Docker

### Quick Setup Steps

```bash
# 1. Install dependencies
npm install

# 2. Set up environment variables
cp env.example .env

# 3. Edit .env file with your database settings
nano .env
```

### Environment Configuration (.env)
```bash
NODE_ENV=development
PORT=3000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=todoapp
DB_USER=todo_user
DB_PASSWORD=todo_password

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=24h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### Start the Application

```bash
# Option A: With Docker Compose (includes PostgreSQL)
docker-compose up -d

# Option B: Run locally (requires PostgreSQL installed)
npm run dev
```

### Test the API

```bash
# Health check
curl http://localhost:3000/health

# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123"
  }'
```

---

## 🐳 **Option 2: Run with Docker Compose (Easiest)**

### Prerequisites
- Docker
- Docker Compose

### Setup Steps

```bash
# 1. Start all services (app + database + redis)
docker-compose up -d

# 2. Check if services are running
docker-compose ps

# 3. View logs
docker-compose logs -f todo-app

# 4. Test the application
curl http://localhost:3000/health
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

---

## 🧪 **Option 3: Run Tests Locally**

### Prerequisites
- Node.js 18+
- PostgreSQL (or Docker)

### Setup Test Environment

```bash
# 1. Install dependencies
npm install

# 2. Set up test database
# Option A: Use Docker
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=test_todoapp \
  -p 5432:5432 \
  postgres:15

# Option B: Install PostgreSQL locally
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres createdb test_todoapp
```

### Run Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run linting
npm run lint

# Fix linting issues
npm run lint:fix
```

---

## 🔧 **Option 4: Simulate CI/CD Pipeline Locally**

### Using act (GitHub Actions locally)

```bash
# 1. Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# 2. Run the pipeline locally
act

# 3. Run specific job
act -j test

# 4. Run with specific event
act push
```

### Using Docker to simulate pipeline steps

```bash
# 1. Test job simulation
docker run --rm -v $(pwd):/workspace -w /workspace node:18-alpine sh -c "
  npm ci &&
  npm run lint &&
  npm test
"

# 2. Build job simulation
docker build -t todo-app-local .

# 3. Run the built image
docker run -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=your-password \
  todo-app-local
```

---

## 🗄️ **Database Setup Options**

### Option A: Docker PostgreSQL (Recommended)

```bash
# Start PostgreSQL with Docker
docker run -d --name todo-postgres \
  -e POSTGRES_DB=todoapp \
  -e POSTGRES_USER=todo_user \
  -e POSTGRES_PASSWORD=todo_password \
  -p 5432:5432 \
  postgres:15

# Connect to database
docker exec -it todo-postgres psql -U todo_user -d todoapp
```

### Option B: Local PostgreSQL Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql
CREATE DATABASE todoapp;
CREATE USER todo_user WITH PASSWORD 'todo_password';
GRANT ALL PRIVILEGES ON DATABASE todoapp TO todo_user;
\q
```

### Option C: Use Docker Compose (All-in-one)

```bash
# This starts app + database + redis
docker-compose up -d
```

---

## 🔍 **Debugging and Monitoring**

### Application Logs

```bash
# Docker Compose logs
docker-compose logs -f todo-app

# Docker container logs
docker logs -f todo-app

# Local development logs (if running with npm run dev)
# Logs will appear in terminal
```

### Database Connection Test

```bash
# Test PostgreSQL connection
psql -h localhost -p 5432 -U todo_user -d todoapp

# Or with Docker
docker exec -it todo-postgres psql -U todo_user -d todoapp
```

### Health Checks

```bash
# Application health
curl http://localhost:3000/health

# Database health (if using Docker)
docker exec todo-postgres pg_isready -U todo_user -d todoapp
```

---

## 🚨 **Troubleshooting Common Issues**

### 1. Port Already in Use

```bash
# Check what's using port 3000
sudo lsof -i :3000

# Kill the process
sudo kill -9 <PID>

# Or use a different port
PORT=3001 npm run dev
```

### 2. Database Connection Failed

```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Check Docker container
docker ps | grep postgres

# Test connection
telnet localhost 5432
```

### 3. Permission Issues

```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm

# Fix Docker permissions
sudo usermod -aG docker $USER
# Logout and login again
```

### 4. Node Modules Issues

```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

## 📊 **Performance Testing**

### Load Testing with Artillery

```bash
# Install Artillery
npm install -g artillery

# Create load test config
cat > load-test.yml << EOF
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 60
      arrivalRate: 10
scenarios:
  - name: "Health check"
    requests:
      - get:
          url: "/health"
EOF

# Run load test
artillery run load-test.yml
```

### API Testing with curl

```bash
# Create a test script
cat > test-api.sh << 'EOF'
#!/bin/bash

BASE_URL="http://localhost:3000"

echo "Testing Todo API..."

# Health check
echo "1. Health check:"
curl -s "$BASE_URL/health" | jq .

# Register user
echo "2. Register user:"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123"
  }')

echo "$REGISTER_RESPONSE" | jq .

# Extract token
TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token')

# Create todo
echo "3. Create todo:"
curl -s -X POST "$BASE_URL/api/todos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Test Todo",
    "description": "This is a test todo",
    "priority": "high"
  }' | jq .

echo "API test completed!"
EOF

chmod +x test-api.sh
./test-api.sh
```

---

## 🎯 **Quick Start Commands**

### For Immediate Testing

```bash
# Clone and setup
git clone <your-repo>
cd todo-app-cicd-self-hosted

# Quick start with Docker Compose
docker-compose up -d

# Test the API
curl http://localhost:3000/health

# Stop when done
docker-compose down
```

### For Development

```bash
# Setup development environment
npm install
cp env.example .env
# Edit .env with your settings

# Start PostgreSQL with Docker
docker run -d --name dev-postgres \
  -e POSTGRES_DB=todoapp \
  -e POSTGRES_USER=todo_user \
  -e POSTGRES_PASSWORD=todo_password \
  -p 5432:5432 \
  postgres:15

# Start the application
npm run dev
```

### For Testing

```bash
# Run tests
npm test

# Run linting
npm run lint

# Run everything
npm run lint && npm test
```

---

## ✅ **Verification Checklist**

- [ ] Node.js 18+ installed
- [ ] npm dependencies installed
- [ ] Environment variables configured
- [ ] Database running (PostgreSQL or Docker)
- [ ] Application starts without errors
- [ ] Health endpoint responds
- [ ] API endpoints work
- [ ] Tests pass
- [ ] Linting passes

Your Todo Application is now ready for local development! 🚀
