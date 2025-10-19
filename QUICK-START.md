# Quick Start Guide for naimjeem/todo-api-github-actions-self-host

This guide helps you quickly set up and run the Todo API with self-hosted GitHub Actions.

## 🚀 **Repository Information**

- **GitHub Repository**: [https://github.com/naimjeem/todo-api-github-actions-self-host](https://github.com/naimjeem/todo-api-github-actions-self-host)
- **Docker Hub**: `naimjeem/todo-api-github-actions-self-host`
- **Self-hosted runners**: Configured for `self-hosted`, `linux`, `x64`

## ⚡ **Quick Setup (5 minutes)**

### 1. Clone and Setup Repository

```bash
# Clone your repository
git clone https://github.com/naimjeem/todo-api-github-actions-self-host.git
cd todo-api-github-actions-self-host

# Run the setup script
chmod +x setup-naimjeem-repo.sh
./setup-naimjeem-repo.sh
```

### 2. Configure GitHub Secrets

Go to [https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions](https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions) and add:

- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

### 3. Set Up Self-Hosted Runner

```bash
# Follow the detailed guide
cat SELF-HOSTED-RUNNER-SETUP.md

# Or run the quick setup
chmod +x run-actions-local.sh
./run-actions-local.sh
```

### 4. Test Locally

```bash
# Test the application locally
docker-compose up -d

# Test the API
curl http://localhost:3000/health

# Test the pipeline locally
chmod +x simulate-pipeline.sh
./simulate-pipeline.sh
```

## 🔄 **CI/CD Pipeline Flow**

### Branch Strategy
- **`dev`** → Development and testing
- **`uat`** → User Acceptance Testing  
- **`main`** → Production deployment

### Pipeline Jobs
1. **Test Job**: Runs on all branches
   - Linting with ESLint
   - Unit tests with Jest
   - PostgreSQL service integration

2. **Build Job**: Runs on main branch only
   - Builds Docker image
   - Pushes to Docker Hub
   - Multi-platform support (linux/amd64, linux/arm64)

3. **Deploy Job**: Runs on main branch only
   - Simulates production deployment
   - Can be extended for real deployment

4. **Security Scan**: Runs on main branch only
   - Trivy vulnerability scanning
   - SARIF report upload

## 🐳 **Docker Images**

The pipeline creates these images on Docker Hub:

```bash
# Pull the latest image
docker pull naimjeem/todo-api-github-actions-self-host:latest

# Run the application
docker run -p 3000:3000 \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-password \
  naimjeem/todo-api-github-actions-self-host:latest
```

## 🧪 **Testing the Pipeline**

### Test on Dev Branch
```bash
# Make a change
echo "# Test change" >> README.md
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin dev

# Check GitHub Actions
open https://github.com/naimjeem/todo-api-github-actions-self-host/actions
```

### Test on Main Branch
```bash
# Merge to main (triggers full pipeline)
git checkout main
git merge dev
git push origin main

# Check Docker Hub for new image
open https://hub.docker.com/r/naimjeem/todo-api-github-actions-self-host
```

## 🔧 **Local Development**

### Start Development Environment
```bash
# Using Docker Compose
docker-compose up -d

# Or run locally
npm install
cp env.example .env
# Edit .env with your settings
npm run dev
```

### Run Tests
```bash
# Run all tests
npm test

# Run linting
npm run lint

# Run tests in watch mode
npm run test:watch
```

## 📊 **Monitoring**

### GitHub Actions
- **Actions Tab**: [https://github.com/naimjeem/todo-api-github-actions-self-host/actions](https://github.com/naimjeem/todo-api-github-actions-self-host/actions)
- **Workflow Status**: Check pipeline execution and logs

### Docker Hub
- **Repository**: [https://hub.docker.com/r/naimjeem/todo-api-github-actions-self-host](https://hub.docker.com/r/naimjeem/todo-api-github-actions-self-host)
- **Image Tags**: Check latest builds and versions

### Application Health
```bash
# Health check endpoint
curl http://localhost:3000/health

# API documentation
curl http://localhost:3000/
```

## 🚨 **Troubleshooting**

### Common Issues

1. **Pipeline not running**: Check if self-hosted runner is online
2. **Docker build fails**: Verify Docker Hub credentials in secrets
3. **Tests failing**: Check database connection and environment variables
4. **Runner offline**: Restart the self-hosted runner service

### Debug Commands

```bash
# Check runner status
docker ps | grep runner

# Check application logs
docker-compose logs -f todo-app

# Test database connection
docker-compose exec postgres psql -U todo_user -d todoapp
```

## 📚 **Documentation**

- **README.md**: Complete project overview
- **SELF-HOSTED-RUNNER-SETUP.md**: Detailed runner setup
- **RUN-GITHUB-ACTIONS-LOCALLY.md**: Local testing guide
- **DEPLOYMENT.md**: Production deployment guide
- **LOCAL-SETUP.md**: Local development setup

## 🎯 **Next Steps**

1. ✅ Set up self-hosted runner
2. ✅ Configure GitHub secrets
3. ✅ Test the pipeline
4. ✅ Deploy to production
5. 🔄 Monitor and maintain

Your Todo API with self-hosted GitHub Actions is ready! 🚀

**Repository**: [https://github.com/naimjeem/todo-api-github-actions-self-host](https://github.com/naimjeem/todo-api-github-actions-self-host)
