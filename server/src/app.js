/**
 * Express Application Configuration
 * 
 * Real-Time Emergency Ambulance-Hospital Coordination System
 * 
 * Configures Express app with:
 * - Security middleware (helmet, cors)
 * - Request parsing (JSON)
 * - Rate limiting
 * - API routes
 * - Webhook endpoints
 * - Centralized error handling
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Import routes and webhooks
const routes = require('./routes');
const { n8nWebhooks } = require('./webhooks');

// Import middleware
const { notFoundHandler, errorHandler } = require('./middlewares/errorHandler');

// Create Express app
const app = express();

// ===========================================
// Security Middleware
// ===========================================

// Helmet - Secure HTTP headers
app.use(helmet());

// CORS - Cross-Origin Resource Sharing
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.ALLOWED_ORIGINS?.split(',') 
    : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key', 'X-Webhook-Key']
}));

// ===========================================
// Request Parsing
// ===========================================

// Parse JSON requests
app.use(express.json({ limit: '10mb' }));

// Parse URL-encoded bodies
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ===========================================
// Rate Limiting
// ===========================================

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // 100 requests per window
  message: {
    success: false,
    message: 'Too many requests, please try again later',
    timestamp: new Date().toISOString()
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Apply rate limiting to API routes
app.use('/api', apiLimiter);

// ===========================================
// Request Logging (Development)
// ===========================================

if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} | ${req.method} ${req.path}`);
    next();
  });
}

// ===========================================
// Routes
// ===========================================

// API routes
app.use('/api', routes);

// Webhook routes (n8n integration)
app.use('/webhook', n8nWebhooks);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Emergency Coordination API',
    version: '1.0.0',
    endpoints: {
      api: '/api',
      health: '/api/health',
      webhooks: '/webhook'
    },
    documentation: '/api/docs'
  });
});

// ===========================================
// Error Handling
// ===========================================

// 404 handler - must come after all routes
app.use(notFoundHandler);

// Global error handler - must be LAST middleware
app.use(errorHandler);

module.exports = app;
