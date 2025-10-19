# Running GitHub Actions Locally

This guide shows you how to run your GitHub Actions CI/CD pipeline locally for testing and development.

## 🚀 **Option 1: Using `act` (Recommended)**

`act` is the most popular tool for running GitHub Actions locally. It simulates the GitHub Actions environment using Docker.

### Installation

```bash
# Method 1: Using curl (requires sudo)
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Method 2: Download binary directly
wget https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz
tar -xzf act_Linux_x86_64.tar.gz
sudo mv act /usr/local/bin/

# Method 3: Using package manager (if available)
# Ubuntu/Debian
sudo apt install act

# Or using snap
sudo snap install act
```

### Basic Usage

```bash
# List available workflows
act -l

# Run all workflows
act

# Run specific workflow
act -W .github/workflows/ci-cd.yml

# Run specific job
act -j test

# Run with specific event
act push

# Run with environment variables
act --env-file .env
```

### Configure act for Your Project

Create `.actrc` file:

```bash
# Create act configuration
cat > .actrc << 'EOF'
# Use specific Docker image for runners
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P self-hosted=catthehacker/ubuntu:act-latest

# Set default platform
--platform ubuntu-latest=catthehacker/ubuntu:act-latest
--platform self-hosted=catthehacker/ubuntu:act-latest

# Enable verbose output
-v

# Use local secrets
--secret-file .secrets
EOF
```

### Create Secrets File

```bash
# Create secrets file for local testing
cat > .secrets << 'EOF'
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-token
NODE_ENV=test
DB_HOST=localhost
DB_PORT=5432
DB_NAME=test_todoapp
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=test-secret-key
EOF

# Secure the secrets file
chmod 600 .secrets
```

### Run Your Pipeline Locally

```bash
# Run the complete pipeline
act

# Run only the test job
act -j test

# Run with specific branch (simulate main branch push)
act push -e .github/workflows/ci-cd.yml

# Run with custom environment
act --env NODE_ENV=test --env DB_HOST=localhost
```

---

## 🐳 **Option 2: Using Docker Manually**

Simulate the GitHub Actions steps using Docker containers.

### Test Job Simulation

```bash
# Create a test script
cat > run-tests.sh << 'EOF'
#!/bin/bash

echo "🧪 Running Test Job Simulation..."

# Start PostgreSQL container
echo "Starting PostgreSQL..."
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=test_todoapp \
  -p 5432:5432 \
  postgres:15

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Run tests in Node.js container
echo "Running tests..."
docker run --rm \
  --network host \
  -v $(pwd):/workspace \
  -w /workspace \
  -e NODE_ENV=test \
  -e DB_HOST=localhost \
  -e DB_PORT=5432 \
  -e DB_NAME=test_todoapp \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e JWT_SECRET=test-secret-key \
  node:18-alpine sh -c "
    npm ci &&
    npm run lint &&
    npm test
  "

# Cleanup
echo "Cleaning up..."
docker stop test-postgres
docker rm test-postgres

echo "✅ Test job completed!"
EOF

chmod +x run-tests.sh
./run-tests.sh
```

### Build Job Simulation

```bash
# Create build script
cat > run-build.sh << 'EOF'
#!/bin/bash

echo "🔨 Running Build Job Simulation..."

# Build Docker image
echo "Building Docker image..."
docker build -t todo-app-local .

# Test the built image
echo "Testing built image..."
docker run -d --name test-app \
  -e NODE_ENV=production \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=test-password \
  -e JWT_SECRET=test-secret \
  -p 3000:3000 \
  todo-app-local

# Wait for app to start
sleep 5

# Test health endpoint
echo "Testing health endpoint..."
curl -f http://localhost:3000/health || echo "Health check failed"

# Cleanup
docker stop test-app
docker rm test-app

echo "✅ Build job completed!"
EOF

chmod +x run-build.sh
./run-build.sh
```

---

## 🔧 **Option 3: Using GitHub CLI with Codespaces**

If you have access to GitHub Codespaces, you can run actions there.

### Setup Codespace

```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Login to GitHub
gh auth login

# Create codespace
gh codespace create --repo your-username/your-repo
```

---

## 🧪 **Option 4: Manual Step-by-Step Simulation**

Run each step of your pipeline manually to test locally.

### Step 1: Environment Setup

```bash
# Create local environment script
cat > setup-env.sh << 'EOF'
#!/bin/bash

echo "🔧 Setting up local environment..."

# Install dependencies
npm install

# Set up environment variables
cp env.example .env.local

# Edit environment for local testing
cat > .env.local << 'ENVEOF'
NODE_ENV=test
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=test_todoapp
DB_USER=postgres
DB_PASSWORD=postgres
JWT_SECRET=test-secret-key
JWT_EXPIRES_IN=24h
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
ENVEOF

echo "✅ Environment setup complete!"
EOF

chmod +x setup-env.sh
./setup-env.sh
```

### Step 2: Database Setup

```bash
# Create database setup script
cat > setup-db.sh << 'EOF'
#!/bin/bash

echo "🗄️ Setting up test database..."

# Start PostgreSQL container
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=test_todoapp \
  -p 5432:5432 \
  postgres:15

# Wait for database to be ready
echo "Waiting for database..."
until docker exec test-postgres pg_isready -U postgres; do
  sleep 1
done

echo "✅ Database ready!"
EOF

chmod +x setup-db.sh
./setup-db.sh
```

### Step 3: Run Tests

```bash
# Create test runner script
cat > run-local-tests.sh << 'EOF'
#!/bin/bash

echo "🧪 Running local tests..."

# Load environment variables
export $(cat .env.local | xargs)

# Run linting
echo "Running linting..."
npm run lint

# Run tests
echo "Running tests..."
npm test

echo "✅ Tests completed!"
EOF

chmod +x run-local-tests.sh
./run-local-tests.sh
```

### Step 4: Build and Test

```bash
# Create build test script
cat > test-build.sh << 'EOF'
#!/bin/bash

echo "🔨 Testing build process..."

# Build Docker image
docker build -t todo-app-test .

# Test the image
docker run -d --name test-container \
  --env-file .env.local \
  -p 3001:3000 \
  todo-app-test

# Wait for startup
sleep 5

# Test health endpoint
curl -f http://localhost:3001/health && echo "✅ Build test passed!" || echo "❌ Build test failed!"

# Cleanup
docker stop test-container
docker rm test-container

echo "✅ Build test completed!"
EOF

chmod +x test-build.sh
./test-build.sh
```

---

## 🎯 **Complete Local Pipeline Runner**

Create a comprehensive script that runs your entire pipeline locally:

```bash
# Create complete pipeline runner
cat > run-pipeline-local.sh << 'EOF'
#!/bin/bash

set -e

echo "🚀 Running Complete Pipeline Locally"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    docker stop test-postgres 2>/dev/null || true
    docker rm test-postgres 2>/dev/null || true
    docker stop test-app 2>/dev/null || true
    docker rm test-app 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

# Step 1: Environment Setup
print_status "Step 1: Setting up environment..."
npm install
cp env.example .env.local

# Step 2: Database Setup
print_status "Step 2: Setting up test database..."
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=test_todoapp \
  -p 5432:5432 \
  postgres:15

# Wait for database
print_status "Waiting for database to be ready..."
until docker exec test-postgres pg_isready -U postgres; do
  sleep 1
done

# Step 3: Run Tests
print_status "Step 3: Running tests..."
export NODE_ENV=test
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=test_todoapp
export DB_USER=postgres
export DB_PASSWORD=postgres
export JWT_SECRET=test-secret-key

npm run lint
npm test

# Step 4: Build Test
print_status "Step 4: Testing build process..."
docker build -t todo-app-test .

# Step 5: Integration Test
print_status "Step 5: Running integration test..."
docker run -d --name test-app \
  -e NODE_ENV=production \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=postgres \
  -e JWT_SECRET=test-secret \
  -p 3000:3000 \
  todo-app-test

# Wait for app to start
sleep 5

# Test health endpoint
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    print_status "✅ Health check passed!"
else
    print_error "❌ Health check failed!"
    exit 1
fi

print_status "🎉 Pipeline completed successfully!"
print_status "All tests passed and build is working!"

EOF

chmod +x run-pipeline-local.sh
```

---

## 🔍 **Debugging GitHub Actions Locally**

### Debug act Issues

```bash
# Run with verbose output
act -v

# Run with debug output
act --debug

# List available runners
act -l

# Check Docker images
docker images | grep act
```

### Debug Docker Issues

```bash
# Check Docker status
docker ps
docker images

# Check container logs
docker logs test-postgres
docker logs test-app

# Debug network issues
docker network ls
docker network inspect bridge
```

### Debug Application Issues

```bash
# Check application logs
docker logs test-app

# Test database connection
docker exec test-postgres psql -U postgres -d test_todoapp -c "SELECT 1;"

# Test API endpoints
curl -v http://localhost:3000/health
curl -v http://localhost:3000/api/auth/register
```

---

## 📊 **Performance Testing**

### Load Test Your Local Pipeline

```bash
# Create load test script
cat > load-test-local.sh << 'EOF'
#!/bin/bash

echo "📊 Running load test on local application..."

# Start the app
docker run -d --name load-test-app \
  -e NODE_ENV=production \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=postgres \
  -e JWT_SECRET=test-secret \
  -p 3000:3000 \
  todo-app-test

# Wait for startup
sleep 5

# Install artillery if not present
if ! command -v artillery &> /dev/null; then
    npm install -g artillery
fi

# Create load test config
cat > load-test-config.yml << 'CONFIGEOF'
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 30
      arrivalRate: 5
scenarios:
  - name: "Health check"
    requests:
      - get:
          url: "/health"
CONFIGEOF

# Run load test
artillery run load-test-config.yml

# Cleanup
docker stop load-test-app
docker rm load-test-app

echo "✅ Load test completed!"
EOF

chmod +x load-test-local.sh
```

---

## ✅ **Quick Start Commands**

### Immediate Testing

```bash
# Quick test with act (if installed)
act -j test

# Quick test with Docker
docker run --rm -v $(pwd):/workspace -w /workspace node:18-alpine sh -c "npm ci && npm test"

# Quick build test
docker build -t todo-app-test . && docker run --rm -p 3000:3000 todo-app-test
```

### Full Pipeline Test

```bash
# Run complete pipeline simulation
./run-pipeline-local.sh

# Or step by step
./setup-env.sh
./setup-db.sh
./run-local-tests.sh
./test-build.sh
```

---

## 🎯 **Troubleshooting**

### Common Issues

1. **act not found**: Install act using one of the methods above
2. **Docker permission denied**: Add user to docker group
3. **Port already in use**: Change ports or kill existing processes
4. **Database connection failed**: Check if PostgreSQL container is running
5. **Tests failing**: Check environment variables and database setup

### Getting Help

- **act documentation**: https://github.com/nektos/act
- **GitHub Actions docs**: https://docs.github.com/en/actions
- **Docker documentation**: https://docs.docker.com/

Your GitHub Actions pipeline is now ready to run locally! 🚀
