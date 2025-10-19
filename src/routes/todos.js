const jwt = require('jsonwebtoken');
const { body, validationResult, query } = require('express-validator');
const db = require('../config/database');

const router = require('express').Router();

// Middleware to authenticate JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      error: 'Access denied',
      message: 'No token provided'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        error: 'Access denied',
        message: 'Invalid or expired token'
      });
    }
    req.user = user;
    next();
  });
}

// Validation middleware
const validateTodo = [
  body('title')
    .trim()
    .isLength({ min: 1, max: 255 })
    .withMessage('Title must be between 1 and 255 characters'),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Priority must be low, medium, or high'),
  body('due_date')
    .optional()
    .isISO8601()
    .withMessage('Due date must be a valid ISO 8601 date')
];

const validateTodoUpdate = [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 1, max: 255 })
    .withMessage('Title must be between 1 and 255 characters'),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must not exceed 1000 characters'),
  body('completed')
    .optional()
    .isBoolean()
    .withMessage('Completed must be a boolean value'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Priority must be low, medium, or high'),
  body('due_date')
    .optional()
    .isISO8601()
    .withMessage('Due date must be a valid ISO 8601 date')
];

// Apply authentication to all routes
router.use(authenticateToken);

// Get all todos for authenticated user
router.get('/', [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('completed').optional().isBoolean().withMessage('Completed must be a boolean'),
  query('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Priority must be low, medium, or high'),
  query('sort').optional().isIn(['created_at', 'updated_at', 'due_date', 'priority']).withMessage('Invalid sort field')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const userId = req.user.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const completed = req.query.completed;
    const priority = req.query.priority;
    const sort = req.query.sort || 'created_at';
    const sortOrder = req.query.order === 'asc' ? 'ASC' : 'DESC';

    // Build query conditions
    let whereConditions = ['user_id = $1'];
    let queryParams = [userId];
    let paramCount = 1;

    if (completed !== undefined) {
      paramCount++;
      whereConditions.push(`completed = $${paramCount}`);
      queryParams.push(completed);
    }

    if (priority) {
      paramCount++;
      whereConditions.push(`priority = $${paramCount}`);
      queryParams.push(priority);
    }

    const whereClause = whereConditions.join(' AND ');

    // Get total count
    const countQuery = `SELECT COUNT(*) FROM todos WHERE ${whereClause}`;
    const countResult = await db.query(countQuery, queryParams);
    const totalCount = parseInt(countResult.rows[0].count);

    // Get todos
    const todosQuery = `
      SELECT id, title, description, completed, priority, due_date, created_at, updated_at
      FROM todos 
      WHERE ${whereClause}
      ORDER BY ${sort} ${sortOrder}
      LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}
    `;
    
    queryParams.push(limit, offset);
    const todosResult = await db.query(todosQuery, queryParams);

    const todos = todosResult.rows.map(todo => ({
      ...todo,
      due_date: todo.due_date ? todo.due_date.toISOString() : null,
      created_at: todo.created_at.toISOString(),
      updated_at: todo.updated_at.toISOString()
    }));

    res.json({
      todos,
      pagination: {
        page,
        limit,
        totalCount,
        totalPages: Math.ceil(totalCount / limit),
        hasNext: page < Math.ceil(totalCount / limit),
        hasPrev: page > 1
      }
    });
  } catch (error) {
    console.error('Get todos error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to fetch todos'
    });
  }
});

// Get a specific todo
router.get('/:id', async (req, res) => {
  try {
    const userId = req.user.userId;
    const todoId = req.params.id;

    const result = await db.query(
      'SELECT id, title, description, completed, priority, due_date, created_at, updated_at FROM todos WHERE id = $1 AND user_id = $2',
      [todoId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Todo not found',
        message: 'The requested todo does not exist or you do not have permission to access it'
      });
    }

    const todo = result.rows[0];
    res.json({
      ...todo,
      due_date: todo.due_date ? todo.due_date.toISOString() : null,
      created_at: todo.created_at.toISOString(),
      updated_at: todo.updated_at.toISOString()
    });
  } catch (error) {
    console.error('Get todo error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to fetch todo'
    });
  }
});

// Create a new todo
router.post('/', validateTodo, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const userId = req.user.userId;
    const { title, description, priority, due_date } = req.body;

    const result = await db.query(
      'INSERT INTO todos (user_id, title, description, priority, due_date) VALUES ($1, $2, $3, $4, $5) RETURNING id, title, description, completed, priority, due_date, created_at, updated_at',
      [userId, title, description || null, priority || 'medium', due_date || null]
    );

    const todo = result.rows[0];
    res.status(201).json({
      message: 'Todo created successfully',
      todo: {
        ...todo,
        due_date: todo.due_date ? todo.due_date.toISOString() : null,
        created_at: todo.created_at.toISOString(),
        updated_at: todo.updated_at.toISOString()
      }
    });
  } catch (error) {
    console.error('Create todo error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to create todo'
    });
  }
});

// Update a todo
router.put('/:id', validateTodoUpdate, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const userId = req.user.userId;
    const todoId = req.params.id;
    const { title, description, completed, priority, due_date } = req.body;

    // Check if todo exists and belongs to user
    const existingTodo = await db.query(
      'SELECT id FROM todos WHERE id = $1 AND user_id = $2',
      [todoId, userId]
    );

    if (existingTodo.rows.length === 0) {
      return res.status(404).json({
        error: 'Todo not found',
        message: 'The requested todo does not exist or you do not have permission to modify it'
      });
    }

    // Build update query dynamically
    const updateFields = [];
    const updateValues = [];
    let paramCount = 0;

    if (title !== undefined) {
      paramCount++;
      updateFields.push(`title = $${paramCount}`);
      updateValues.push(title);
    }

    if (description !== undefined) {
      paramCount++;
      updateFields.push(`description = $${paramCount}`);
      updateValues.push(description);
    }

    if (completed !== undefined) {
      paramCount++;
      updateFields.push(`completed = $${paramCount}`);
      updateValues.push(completed);
    }

    if (priority !== undefined) {
      paramCount++;
      updateFields.push(`priority = $${paramCount}`);
      updateValues.push(priority);
    }

    if (due_date !== undefined) {
      paramCount++;
      updateFields.push(`due_date = $${paramCount}`);
      updateValues.push(due_date);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        error: 'No fields to update',
        message: 'At least one field must be provided for update'
      });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    updateValues.push(todoId, userId);

    const updateQuery = `
      UPDATE todos 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramCount + 1} AND user_id = $${paramCount + 2}
      RETURNING id, title, description, completed, priority, due_date, created_at, updated_at
    `;

    const result = await db.query(updateQuery, updateValues);
    const todo = result.rows[0];

    res.json({
      message: 'Todo updated successfully',
      todo: {
        ...todo,
        due_date: todo.due_date ? todo.due_date.toISOString() : null,
        created_at: todo.created_at.toISOString(),
        updated_at: todo.updated_at.toISOString()
      }
    });
  } catch (error) {
    console.error('Update todo error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to update todo'
    });
  }
});

// Delete a todo
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.user.userId;
    const todoId = req.params.id;

    const result = await db.query(
      'DELETE FROM todos WHERE id = $1 AND user_id = $2 RETURNING id',
      [todoId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: 'Todo not found',
        message: 'The requested todo does not exist or you do not have permission to delete it'
      });
    }

    res.json({
      message: 'Todo deleted successfully'
    });
  } catch (error) {
    console.error('Delete todo error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to delete todo'
    });
  }
});

// Mark all todos as completed
router.patch('/complete-all', async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      'UPDATE todos SET completed = true, updated_at = CURRENT_TIMESTAMP WHERE user_id = $1 AND completed = false RETURNING COUNT(*)',
      [userId]
    );

    const updatedCount = parseInt(result.rows[0].count);

    res.json({
      message: 'All todos marked as completed',
      updatedCount
    });
  } catch (error) {
    console.error('Complete all todos error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to complete all todos'
    });
  }
});

module.exports = router;
