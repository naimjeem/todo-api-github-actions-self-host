# Deployment Guide

This guide covers deploying the Todo Application API using different methods and environments.

## 🚀 Deployment Methods

### 1. Docker Compose (Recommended for Development/Testing)

```bash
# Clone the repository
git clone <repository-url>
cd todo-app-cicd-self-hosted

# Copy environment file
cp env.example .env

# Edit environment variables
nano .env

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f todo-app
```

### 2. Docker (Single Container)

```bash
# Build image
docker build -t todo-app .

# Run with environment variables
docker run -d \
  --name todo-app \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-secure-password \
  -e JWT_SECRET=your-jwt-secret \
  todo-app
```

### 3. Kubernetes Deployment

Create `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: todo-app
  template:
    metadata:
      labels:
        app: todo-app
    spec:
      containers:
      - name: todo-app
        image: your-dockerhub-username/todo-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DB_HOST
          value: "postgres-service"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: todo-app-service
spec:
  selector:
    app: todo-app
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s-deployment.yaml
```

## 🔧 Environment-Specific Configurations

### Development Environment

```bash
NODE_ENV=development
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=todoapp_dev
DB_USER=todo_user
DB_PASSWORD=dev_password
JWT_SECRET=dev-secret-key
JWT_EXPIRES_IN=24h
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=1000
```

### UAT Environment

```bash
NODE_ENV=production
PORT=3000
DB_HOST=uat-db-host
DB_PORT=5432
DB_NAME=todoapp_uat
DB_USER=todo_user
DB_PASSWORD=uat_secure_password
JWT_SECRET=uat-jwt-secret-key
JWT_EXPIRES_IN=12h
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=500
```

### Production Environment

```bash
NODE_ENV=production
PORT=3000
DB_HOST=prod-db-host
DB_PORT=5432
DB_NAME=todoapp_prod
DB_USER=todo_user
DB_PASSWORD=prod_very_secure_password
JWT_SECRET=prod-super-secure-jwt-secret-key
JWT_EXPIRES_IN=8h
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=200
```

## 🗄️ Database Setup

### PostgreSQL Setup

1. **Install PostgreSQL**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install postgresql postgresql-contrib
   
   # CentOS/RHEL
   sudo yum install postgresql-server postgresql-contrib
   ```

2. **Create Database and User**
   ```sql
   -- Connect as postgres user
   sudo -u postgres psql
   
   -- Create database
   CREATE DATABASE todoapp;
   
   -- Create user
   CREATE USER todo_user WITH PASSWORD 'secure_password';
   
   -- Grant privileges
   GRANT ALL PRIVILEGES ON DATABASE todoapp TO todo_user;
   
   -- Exit
   \q
   ```

3. **Configure PostgreSQL**
   ```bash
   # Edit postgresql.conf
   sudo nano /etc/postgresql/15/main/postgresql.conf
   
   # Edit pg_hba.conf
   sudo nano /etc/postgresql/15/main/pg_hba.conf
   ```

## 🔐 Security Considerations

### 1. Environment Variables
- Never commit `.env` files to version control
- Use strong, unique passwords for each environment
- Rotate JWT secrets regularly
- Use environment-specific configurations

### 2. Database Security
- Use strong passwords
- Limit database access to application servers only
- Enable SSL/TLS connections
- Regular security updates

### 3. Application Security
- Enable HTTPS in production
- Use reverse proxy (nginx) for SSL termination
- Implement proper firewall rules
- Regular security audits

### 4. Docker Security
- Use non-root users in containers
- Scan images for vulnerabilities
- Keep base images updated
- Use multi-stage builds

## 📊 Monitoring and Logging

### 1. Health Checks
```bash
# Check application health
curl http://localhost:3000/health

# Docker health check
docker inspect --format='{{.State.Health.Status}}' todo-app
```

### 2. Logging
```bash
# View application logs
docker-compose logs -f todo-app

# View database logs
docker-compose logs -f postgres
```

### 3. Monitoring Setup
- Set up Prometheus for metrics collection
- Configure Grafana for visualization
- Implement log aggregation (ELK stack)
- Set up alerting for critical issues

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   ```bash
   # Check database status
   docker-compose ps postgres
   
   # Check database logs
   docker-compose logs postgres
   
   # Test connection
   docker-compose exec postgres psql -U todo_user -d todoapp
   ```

2. **Application Won't Start**
   ```bash
   # Check application logs
   docker-compose logs todo-app
   
   # Check environment variables
   docker-compose exec todo-app env
   
   # Restart application
   docker-compose restart todo-app
   ```

3. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :3000
   
   # Kill process using port
   sudo kill -9 <PID>
   ```

### Performance Optimization

1. **Database Optimization**
   - Add appropriate indexes
   - Optimize queries
   - Configure connection pooling
   - Monitor slow queries

2. **Application Optimization**
   - Enable gzip compression
   - Implement caching (Redis)
   - Optimize Docker images
   - Use CDN for static assets

## 🔄 CI/CD Pipeline Deployment

### GitHub Actions Secrets

Add these secrets to your GitHub repository:

1. Go to repository Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token
   - `PROD_DB_PASSWORD`: Production database password
   - `PROD_JWT_SECRET`: Production JWT secret

### Self-Hosted Runner Setup

1. **Install Runner**
   ```bash
   # Download runner
   mkdir actions-runner && cd actions-runner
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
   ```

2. **Configure Runner**
   ```bash
   ./config.sh --url https://github.com/your-username/your-repo --token YOUR_TOKEN
   ```

3. **Install Service**
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

### Deployment Automation

The CI/CD pipeline automatically:
1. Runs tests on all branches
2. Builds and pushes Docker images on main branch
3. Deploys to production environment
4. Runs security scans
5. Sends deployment notifications

## 📈 Scaling Considerations

### Horizontal Scaling
- Use load balancer (nginx, HAProxy)
- Implement session affinity if needed
- Use external database
- Implement caching layer

### Vertical Scaling
- Increase container resources
- Optimize database performance
- Use faster storage (SSD)
- Implement connection pooling

### Database Scaling
- Read replicas for read-heavy workloads
- Database sharding for large datasets
- Connection pooling
- Query optimization

## 🆘 Support and Maintenance

### Regular Maintenance Tasks
- Update dependencies regularly
- Monitor security advisories
- Backup database regularly
- Review and rotate secrets
- Monitor application performance
- Update Docker images

### Backup Strategy
```bash
# Database backup
pg_dump -h localhost -U todo_user todoapp > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
psql -h localhost -U todo_user todoapp < backup_file.sql
```

### Disaster Recovery
- Maintain off-site backups
- Document recovery procedures
- Test recovery processes regularly
- Implement monitoring and alerting
- Have rollback procedures ready
