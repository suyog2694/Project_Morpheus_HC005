/**
 * Middlewares Index
 * 
 * Central export point for all middleware functions.
 */

const { AppError, notFoundHandler, errorHandler, asyncHandler } = require('./errorHandler');
const { optionalAuth, requireAuth, validateAmbulance, validateHospital } = require('./authMiddleware');
const { ROLES, hasRole, patientOnly, ambulanceOnly, hospitalOnly, adminOnly, anyAuthenticated } = require('./roleMiddleware');
const { validateWebhookApiKey, generateApiKey, webhookRateLimit } = require('./apiKeyMiddleware');

module.exports = {
  // Error handling
  AppError,
  notFoundHandler,
  errorHandler,
  asyncHandler,

  // Authentication
  optionalAuth,
  requireAuth,
  validateAmbulance,
  validateHospital,

  // Role-based access
  ROLES,
  hasRole,
  patientOnly,
  ambulanceOnly,
  hospitalOnly,
  adminOnly,
  anyAuthenticated,

  // API key validation
  validateWebhookApiKey,
  generateApiKey,
  webhookRateLimit
};
