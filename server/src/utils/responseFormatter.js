/**
 * Response Formatter Utility
 * 
 * Provides standardized API response structures for consistency
 * across all endpoints.
 */

const { HTTP_STATUS } = require('../config/constants');

/**
 * Format successful response
 * 
 * @param {Object} res - Express response object
 * @param {*} data - Response data
 * @param {string} message - Success message
 * @param {number} statusCode - HTTP status code (default: 200)
 */
const success = (res, data = null, message = 'Success', statusCode = HTTP_STATUS.OK) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString()
  });
};

/**
 * Format created response (201)
 * 
 * @param {Object} res - Express response object
 * @param {*} data - Created resource data
 * @param {string} message - Success message
 */
const created = (res, data = null, message = 'Resource created successfully') => {
  return success(res, data, message, HTTP_STATUS.CREATED);
};

/**
 * Format error response
 * 
 * @param {Object} res - Express response object
 * @param {string} message - Error message
 * @param {number} statusCode - HTTP status code (default: 500)
 * @param {*} errors - Additional error details
 */
const error = (res, message = 'Internal server error', statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR, errors = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString()
  };

  if (errors) {
    response.errors = errors;
  }

  return res.status(statusCode).json(response);
};

/**
 * Format bad request response (400)
 */
const badRequest = (res, message = 'Bad request', errors = null) => {
  return error(res, message, HTTP_STATUS.BAD_REQUEST, errors);
};

/**
 * Format unauthorized response (401)
 */
const unauthorized = (res, message = 'Unauthorized') => {
  return error(res, message, HTTP_STATUS.UNAUTHORIZED);
};

/**
 * Format forbidden response (403)
 */
const forbidden = (res, message = 'Forbidden') => {
  return error(res, message, HTTP_STATUS.FORBIDDEN);
};

/**
 * Format not found response (404)
 */
const notFound = (res, message = 'Resource not found') => {
  return error(res, message, HTTP_STATUS.NOT_FOUND);
};

/**
 * Format conflict response (409)
 */
const conflict = (res, message = 'Resource conflict') => {
  return error(res, message, HTTP_STATUS.CONFLICT);
};

/**
 * Format unprocessable entity response (422)
 */
const unprocessable = (res, message = 'Unprocessable entity', errors = null) => {
  return error(res, message, HTTP_STATUS.UNPROCESSABLE_ENTITY, errors);
};

/**
 * Format service unavailable response (503)
 */
const serviceUnavailable = (res, message = 'Service temporarily unavailable') => {
  return error(res, message, HTTP_STATUS.SERVICE_UNAVAILABLE);
};

/**
 * Format paginated response
 * 
 * @param {Object} res - Express response object
 * @param {Array} data - Array of items
 * @param {number} page - Current page number
 * @param {number} limit - Items per page
 * @param {number} total - Total items count
 * @param {string} message - Success message
 */
const paginated = (res, data, page, limit, total, message = 'Success') => {
  const totalPages = Math.ceil(total / limit);
  
  return res.status(HTTP_STATUS.OK).json({
    success: true,
    message,
    data,
    pagination: {
      page,
      limit,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1
    },
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  success,
  created,
  error,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  unprocessable,
  serviceUnavailable,
  paginated
};
