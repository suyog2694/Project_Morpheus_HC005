/**
 * Server Entry Point
 * 
 * Real-Time Emergency Ambulance-Hospital Coordination System
 * 
 * Initializes environment, tests database connection,
 * and starts the Express server.
 */

// Load environment variables FIRST
require('dotenv').config();

const app = require('./src/app');
const { testConnection } = require('./src/config/supabase');

// Server configuration
const PORT = process.env.PORT || 8000;
const NODE_ENV = process.env.NODE_ENV || 'development';

/**
 * Start the server with initialization checks
 */
const startServer = async () => {
  console.log('==========================================');
  console.log('Emergency Coordination System - Starting');
  console.log('==========================================');
  console.log(`Environment: ${NODE_ENV}`);
  console.log(`Port: ${PORT}`);
  console.log('');

  // Test database connection
  console.log('Testing database connection...');
  const dbConnected = await testConnection();
  
  if (!dbConnected) {
    console.error('');
    console.error('⚠️  WARNING: Database connection failed');
    console.error('Server will start but database operations will fail');
    console.error('Please check your SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
    console.error('');
  }

  // Start Express server
  const server = app.listen(PORT, () => {
    console.log('==========================================');
    console.log(`✓ Server running on port ${PORT}`);
    console.log(`✓ API endpoint: http://localhost:${PORT}/api`);
    console.log(`✓ Webhook endpoint: http://localhost:${PORT}/webhook`);
    console.log('==========================================');
    console.log('');
    console.log('Available Routes:');
    console.log('  Patient App:');
    console.log('    POST /api/patient/emergency');
    console.log('    POST /api/patient/:requestId/condition');
    console.log('    GET  /api/patient/:requestId/status');
    console.log('');
    console.log('  Ambulance App:');
    console.log('    POST /api/ambulance/:ambulanceId/respond');
    console.log('    POST /api/ambulance/arrival');
    console.log('    PUT  /api/ambulance/:ambulanceId/location');
    console.log('');
    console.log('  Hospital Dashboard:');
    console.log('    GET  /api/hospital/active-requests/:hospitalId');
    console.log('    POST /api/hospital/respond');
    console.log('    GET  /api/hospital/:hospitalId/resources');
    console.log('');
    console.log('  Webhooks (n8n):');
    console.log('    POST /webhook/update-bed-count');
    console.log('    POST /webhook/low-bed-alert');
    console.log('==========================================');
  });

  // Graceful shutdown handling
  const gracefulShutdown = (signal) => {
    console.log(`\n${signal} received. Shutting down gracefully...`);
    server.close(() => {
      console.log('Server closed');
      process.exit(0);
    });

    // Force shutdown after 10 seconds
    setTimeout(() => {
      console.error('Could not close connections in time, forcefully shutting down');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
  process.on('SIGINT', () => gracefulShutdown('SIGINT'));

  // Handle unhandled promise rejections
  process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  });

  // Handle uncaught exceptions
  process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    gracefulShutdown('UNCAUGHT_EXCEPTION');
  });
};

// Start the server
startServer().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});

