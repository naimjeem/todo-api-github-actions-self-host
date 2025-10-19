const request = require('supertest');
const app = require('../src/server');

describe('Todo API Tests', () => {
  let authToken;
  let userId;

  beforeAll(async () => {
    // Register a test user
    const registerResponse = await request(app)
      .post('/api/auth/register')
      .send({
        username: 'testuser',
        email: 'test@example.com',
        password: 'TestPass123'
      });
    
    authToken = registerResponse.body.token;
    userId = registerResponse.body.user.id;
  });

  describe('Authentication', () => {
    test('POST /api/auth/register - should register a new user', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'newuser',
          email: 'newuser@example.com',
          password: 'NewPass123'
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body.user).toHaveProperty('id');
      expect(response.body.user).toHaveProperty('username');
      expect(response.body.user).toHaveProperty('email');
    });

    test('POST /api/auth/login - should login with valid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'TestPass123'
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
    });

    test('POST /api/auth/login - should reject invalid credentials', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'WrongPassword'
        });

      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('Todos', () => {
    test('GET /api/todos - should get todos for authenticated user', async () => {
      const response = await request(app)
        .get('/api/todos')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('todos');
      expect(response.body).toHaveProperty('pagination');
    });

    test('POST /api/todos - should create a new todo', async () => {
      const todoData = {
        title: 'Test Todo',
        description: 'This is a test todo',
        priority: 'high'
      };

      const response = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(todoData);

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('todo');
      expect(response.body.todo.title).toBe(todoData.title);
      expect(response.body.todo.description).toBe(todoData.description);
      expect(response.body.todo.priority).toBe(todoData.priority);
    });

    test('PUT /api/todos/:id - should update a todo', async () => {
      // First create a todo
      const createResponse = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Todo to Update',
          description: 'Original description'
        });

      const todoId = createResponse.body.todo.id;

      // Update the todo
      const updateResponse = await request(app)
        .put(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Todo',
          completed: true
        });

      expect(updateResponse.status).toBe(200);
      expect(updateResponse.body.todo.title).toBe('Updated Todo');
      expect(updateResponse.body.todo.completed).toBe(true);
    });

    test('DELETE /api/todos/:id - should delete a todo', async () => {
      // First create a todo
      const createResponse = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Todo to Delete',
          description: 'This will be deleted'
        });

      const todoId = createResponse.body.todo.id;

      // Delete the todo
      const deleteResponse = await request(app)
        .delete(`/api/todos/${todoId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(deleteResponse.status).toBe(200);
      expect(deleteResponse.body).toHaveProperty('message');
    });
  });

  describe('Health Check', () => {
    test('GET /health - should return health status', async () => {
      const response = await request(app)
        .get('/health');

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'OK');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
    });
  });

  describe('Error Handling', () => {
    test('GET /api/todos without token - should return 401', async () => {
      const response = await request(app)
        .get('/api/todos');

      expect(response.status).toBe(401);
      expect(response.body).toHaveProperty('error');
    });

    test('GET /api/todos with invalid token - should return 403', async () => {
      const response = await request(app)
        .get('/api/todos')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(403);
      expect(response.body).toHaveProperty('error');
    });

    test('GET /nonexistent - should return 404', async () => {
      const response = await request(app)
        .get('/nonexistent');

      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });
});
