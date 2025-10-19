# Todo Application API

A comprehensive Todo Application API built with Node.js, Express, PostgreSQL, Docker, and GitHub Actions CI/CD pipeline with self-hosted runners.

**Repository**: [https://github.com/naimjeem/todo-api-github-actions-self-host](https://github.com/naimjeem/todo-api-github-actions-self-host)

## 🚀 Features

- **RESTful API** with Express.js
- **PostgreSQL Database** with connection pooling
- **JWT Authentication** with secure password hashing
- **Docker Containerization** with multi-stage builds
- **GitHub Actions CI/CD** with automated testing and deployment
- **Rate Limiting** and security middleware
- **Comprehensive Testing** with Jest and Supertest
- **Environment Configuration** for different deployment stages
- **Health Checks** and monitoring endpoints

## 📋 API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (protected)

### Todos
- `GET /api/todos` - Get all todos (protected)
- `GET /api/todos/:id` - Get specific todo (protected)
- `POST /api/todos` - Create new todo (protected)
- `PUT /api/todos/:id` - Update todo (protected)
- `DELETE /api/todos/:id` - Delete todo (protected)
- `PATCH /api/todos/complete-all` - Mark all todos as completed (protected)

### System
- `GET /health` - Health check endpoint
- `GET /` - API information

## 🛠️ Technology Stack

- **Backend**: Node.js, Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: bcryptjs, helmet, cors, rate limiting
- **Testing**: Jest, Supertest
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Code Quality**: ESLint

## 🏗️ Project Structure

```
todo-app-cicd-self-hosted/
├── src/
│   ├── config/
│   │   └── database.js          # Database configuration
│   ├── middleware/
│   │   └── errorHandler.js      # Global error handling
│   ├── routes/
│   │   ├── auth.js              # Authentication routes
│   │   └── todos.js             # Todo routes
│   └── server.js                # Main application file
├── tests/
│   └── app.test.js              # Test suite
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions workflow
├── Dockerfile                   # Docker configuration
├── docker-compose.yml          # Docker Compose configuration
├── package.json                # Node.js dependencies
├── .env.example               # Environment variables template
├── .eslintrc.json             # ESLint configuration
├── .gitignore                 # Git ignore rules
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- Docker and Docker Compose
- PostgreSQL (if running locally without Docker)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd todo-app-cicd-self-hosted
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

4. **Start with Docker Compose**
   ```bash
   docker-compose up -d
   ```

5. **Or run locally**
   ```bash
   # Start PostgreSQL (if not using Docker)
   # Update .env with your database credentials
   
   npm run dev
   ```

### API Usage

1. **Register a new user**
   ```bash
   curl -X POST http://localhost:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "email": "test@example.com",
       "password": "TestPass123"
     }'
   ```

2. **Login**
   ```bash
   curl -X POST http://localhost:3000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "TestPass123"
     }'
   ```

3. **Create a todo** (use token from login response)
   ```bash
   curl -X POST http://localhost:3000/api/todos \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{
       "title": "My first todo",
       "description": "This is my first todo item",
       "priority": "high"
     }'
   ```

## 🐳 Docker

### Build and Run

```bash
# Build the image
docker build -t todo-app .

# Run with environment variables
docker run -p 3000:3000 \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-password \
  todo-app
```

### Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up --build -d
```

## 🧪 Testing

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

## 🔄 CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow that:

1. **Runs on**: `main`, `dev`, `uat` branches
2. **Self-hosted runners**: Configured to use self-hosted runners for better control and performance
3. **Test Job**: Runs linting and tests with PostgreSQL service
4. **Build Job**: Builds and pushes Docker image to Docker Hub (main branch only)
5. **Deploy Job**: Simulates production deployment (main branch only)
6. **Security Scan**: Runs Trivy vulnerability scanner
7. **Notifications**: Provides deployment status notifications

### Self-Hosted Runner Configuration

The pipeline is configured to run on self-hosted runners with labels:
- `self-hosted`
- `linux`
- `x64`

See [SELF-HOSTED-RUNNER-SETUP.md](SELF-HOSTED-RUNNER-SETUP.md) for detailed setup instructions.

### Required Secrets

Add these secrets to your GitHub repository at [https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions](https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions):

- `DOCKERHUB_USERNAME`: Your Docker Hub username
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

### Docker Hub Images

The pipeline will build and push images to Docker Hub:
- **Latest**: `naimjeem/todo-api-github-actions-self-host:latest` (main branch)
- **Dev**: `naimjeem/todo-api-github-actions-self-host:dev` (dev branch)  
- **UAT**: `naimjeem/todo-api-github-actions-self-host:uat` (uat branch)

### Branch Strategy

- **`dev`**: Development branch for feature development
- **`uat`**: User Acceptance Testing branch
- **`main`**: Production branch (triggers full CI/CD pipeline)

## 🔧 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `PORT` | Server port | `3000` |
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | `todoapp` |
| `DB_USER` | Database user | `todo_user` |
| `DB_PASSWORD` | Database password | `todo_password` |
| `JWT_SECRET` | JWT secret key | Required |
| `JWT_EXPIRES_IN` | JWT expiration | `24h` |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window | `900000` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Todos Table
```sql
CREATE TABLE todos (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  due_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🔒 Security Features

- **Password Hashing**: bcryptjs with salt rounds
- **JWT Authentication**: Secure token-based authentication
- **Rate Limiting**: Prevents abuse and DoS attacks
- **CORS Protection**: Configurable cross-origin resource sharing
- **Helmet**: Security headers middleware
- **Input Validation**: Express-validator for request validation
- **SQL Injection Protection**: Parameterized queries with pg

## 📈 Monitoring and Health Checks

- **Health Endpoint**: `/health` provides system status
- **Docker Health Checks**: Built-in container health monitoring
- **Logging**: Morgan HTTP request logger
- **Error Handling**: Comprehensive error handling middleware

## 🚀 Deployment

### Production Deployment

1. **Set up production environment variables**
2. **Deploy PostgreSQL database**
3. **Build and push Docker image**
4. **Deploy using your preferred method**:
   - Kubernetes
   - Docker Swarm
   - Cloud platforms (AWS, GCP, Azure)
   - VPS with Docker

### Self-Hosted Runner Setup

To use self-hosted GitHub Actions runners:

1. **Set up runner on your server**
2. **Configure repository to use self-hosted runners**
3. **Update workflow to use self-hosted labels**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the test cases for usage examples

## 🔄 Version History

- **v1.0.0**: Initial release with full CRUD operations, authentication, Docker support, and CI/CD pipeline
