/**
 * API Key Middleware
 * 
 * Validates API keys for webhook endpoints (n8n integration).
 * Provides secure access to automation webhooks.
 */

const { HTTP_STATUS, ERROR_MESSAGES } = require('../config/constants');
const response = require('../utils/responseFormatter');

/**
 * Validate n8n webhook API key
 * Checks both header and query parameter
 */
const validateWebhookApiKey = (req, res, next) => {
  // Get API key from header or query parameter
  const apiKey = req.headers['x-api-key'] || 
                 req.headers['x-webhook-key'] ||
                 req.query.apiKey;

  const validApiKey = process.env.N8N_WEBHOOK_API_KEY;

  // Check if API key is configured
  if (!validApiKey) {
    console.error('N8N_WEBHOOK_API_KEY not configured');
    return response.error(res, 'Webhook authentication not configured', HTTP_STATUS.SERVICE_UNAVAILABLE);
  }

  // Validate the provided API key
  if (!apiKey || apiKey !== validApiKey) {
    console.warn(`Invalid API key attempt from IP: ${req.ip}`);
    return response.unauthorized(res, ERROR_MESSAGES.INVALID_API_KEY);
  }

  // Mark request as webhook origin
  req.isWebhook = true;
  req.webhookSource = 'n8n';

  next();
};

/**
 * Generate a secure API key
 * Utility function for generating new API keys
 * 
 * @param {number} length - Key length (default: 32)
 * @returns {string} Generated API key
 */
const generateApiKey = (length = 32) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  const randomValues = new Uint8Array(length);
  require('crypto').randomFillSync(randomValues);
  
  for (let i = 0; i < length; i++) {
    result += chars[randomValues[i] % chars.length];
  }
  
  return result;
};

/**
 * Rate limiting for webhook endpoints
 * Provides additional protection against abuse
 */
const webhookRateLimit = require('express-rate-limit')({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // 30 requests per minute per IP
  message: {
    success: false,
    message: 'Too many webhook requests, please slow down',
    timestamp: new Date().toISOString()
  },
  standardHeaders: true,
  legacyHeaders: false
});

module.exports = {
  validateWebhookApiKey,
  generateApiKey,
  webhookRateLimit
};
