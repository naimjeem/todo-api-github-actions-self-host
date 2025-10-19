# Todo App CI/CD Configuration

## Branch Protection Rules

### Main Branch (Production)
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Restrict pushes that create files larger than 100MB
- Require linear history

### UAT Branch (User Acceptance Testing)
- Require pull request reviews before merging
- Require status checks to pass before merging
- Allow force pushes (for testing purposes)

### Dev Branch (Development)
- Allow direct pushes
- Require status checks to pass before merging to UAT

## Required Status Checks

### For Main Branch
- Test Job (test)
- Build and Push Job (build-and-push)
- Security Scan Job (security-scan)

### For UAT Branch
- Test Job (test)
- Build and Push Job (build-and-push)

### For Dev Branch
- Test Job (test)

## Environment Variables

### Development
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

### UAT
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

### Production
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

## Docker Hub Configuration

### Image Naming Convention
- `username/todo-app:latest` (main branch)
- `username/todo-app:dev` (dev branch)
- `username/todo-app:uat` (uat branch)
- `username/todo-app:sha-abc123` (specific commit)

### Multi-Platform Builds
- linux/amd64
- linux/arm64

## Security Configuration

### Required Secrets
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token
- `PROD_DB_PASSWORD`: Production database password
- `PROD_JWT_SECRET`: Production JWT secret
- `UAT_DB_PASSWORD`: UAT database password
- `UAT_JWT_SECRET`: UAT JWT secret

### Security Scanning
- Trivy vulnerability scanner
- Dependency vulnerability checks
- Container image scanning
- Code quality checks (ESLint)

## Deployment Strategy

### Blue-Green Deployment
1. Deploy new version to staging environment
2. Run automated tests
3. Switch traffic to new version
4. Monitor for issues
5. Rollback if necessary

### Rolling Deployment
1. Deploy new version to subset of instances
2. Gradually increase traffic to new version
3. Monitor performance and errors
4. Complete rollout or rollback as needed

## Monitoring and Alerting

### Health Checks
- Application health endpoint: `/health`
- Database connectivity checks
- External service dependency checks

### Metrics Collection
- Response time monitoring
- Error rate tracking
- Resource utilization (CPU, Memory)
- Database performance metrics

### Alerting Rules
- High error rate (>5%)
- Slow response times (>2s)
- Database connection failures
- High memory usage (>90%)
- Disk space low (<10% free)

## Backup Strategy

### Database Backups
- Daily automated backups
- Point-in-time recovery capability
- Off-site backup storage
- Backup retention: 30 days

### Application Backups
- Configuration backup
- Environment variable backup
- Docker image versioning
- Infrastructure as Code backup

## Disaster Recovery

### Recovery Time Objective (RTO)
- Development: 4 hours
- UAT: 2 hours
- Production: 1 hour

### Recovery Point Objective (RPO)
- Development: 24 hours
- UAT: 4 hours
- Production: 1 hour

### Recovery Procedures
1. Assess the scope of the incident
2. Activate disaster recovery team
3. Restore from latest backup
4. Verify system functionality
5. Monitor for stability
6. Document lessons learned

## Performance Optimization

### Application Level
- Connection pooling
- Query optimization
- Caching implementation
- Load balancing

### Infrastructure Level
- Auto-scaling configuration
- Resource optimization
- CDN implementation
- Database optimization

## Compliance and Security

### Security Standards
- OWASP Top 10 compliance
- Regular security audits
- Penetration testing
- Vulnerability assessments

### Data Protection
- Encryption at rest
- Encryption in transit
- Access control and authentication
- Audit logging

### Compliance Requirements
- GDPR compliance (if applicable)
- SOC 2 compliance
- Industry-specific regulations
- Data retention policies
