/**
 * Error Handler Middleware
 * 
 * Centralized error handling for the entire application.
 * Catches all errors and formats them consistently.
 */

const { HTTP_STATUS } = require('../config/constants');

/**
 * Custom Application Error class
 */
class AppError extends Error {
  constructor(message, statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR, errors = null) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    this.errors = errors;

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Not Found Error Handler
 * Catches requests to undefined routes
 */
const notFoundHandler = (req, res, next) => {
  const error = new AppError(
    `Route ${req.originalUrl} not found`,
    HTTP_STATUS.NOT_FOUND
  );
  next(error);
};

/**
 * Global Error Handler
 * Processes all errors and sends appropriate responses
 */
const errorHandler = (err, req, res, next) => {
  // Default error values
  err.statusCode = err.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR;
  err.status = err.status || 'error';

  // Log error in development
  if (process.env.NODE_ENV === 'development') {
    console.error('Error:', {
      message: err.message,
      stack: err.stack,
      statusCode: err.statusCode
    });
  } else {
    // Log only essential info in production
    if (!err.isOperational) {
      console.error('Unexpected Error:', err);
    }
  }

  // Handle specific error types
  let error = { ...err };
  error.message = err.message;

  // Supabase/PostgreSQL errors
  if (err.code) {
    error = handleDatabaseError(err);
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    error = handleValidationError(err);
  }

  // JSON parsing errors
  if (err.type === 'entity.parse.failed') {
    error = new AppError('Invalid JSON payload', HTTP_STATUS.BAD_REQUEST);
  }

  // Send response
  const response = {
    success: false,
    message: error.message || 'Something went wrong',
    timestamp: new Date().toISOString()
  };

  // Include stack trace in development
  if (process.env.NODE_ENV === 'development') {
    response.stack = err.stack;
  }

  // Include additional errors if present
  if (error.errors) {
    response.errors = error.errors;
  }

  res.status(error.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR).json(response);
};

/**
 * Handle PostgreSQL/Supabase database errors
 */
const handleDatabaseError = (err) => {
  switch (err.code) {
    case '23505': // Unique violation
      return new AppError('Duplicate entry detected', HTTP_STATUS.CONFLICT);
    case '23503': // Foreign key violation
      return new AppError('Referenced record does not exist', HTTP_STATUS.BAD_REQUEST);
    case '23502': // Not null violation
      return new AppError('Required field is missing', HTTP_STATUS.BAD_REQUEST);
    case '42P01': // Undefined table
      return new AppError('Database configuration error', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    case 'PGRST116': // No rows returned (Supabase)
      return new AppError('Resource not found', HTTP_STATUS.NOT_FOUND);
    default:
      return new AppError('Database error occurred', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
};

/**
 * Handle validation errors
 */
const handleValidationError = (err) => {
  const errors = Object.values(err.errors || {}).map(e => e.message);
  return new AppError('Validation failed', HTTP_STATUS.BAD_REQUEST, errors);
};

/**
 * Async handler wrapper
 * Catches async errors and passes them to error handler
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  AppError,
  notFoundHandler,
  errorHandler,
  asyncHandler
};
