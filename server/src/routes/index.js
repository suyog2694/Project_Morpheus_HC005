/**
 * Routes Index
 * 
 * Central routing configuration.
 */

const express = require('express');
const router = express.Router();

const patientRoutes = require('./patientRoutes');
const ambulanceRoutes = require('./ambulanceRoutes');
const hospitalRoutes = require('./hospitalRoutes');

// Mount route modules
router.use('/patient', patientRoutes);
router.use('/ambulance', ambulanceRoutes);
router.use('/hospital', hospitalRoutes);

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Emergency Coordination API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

module.exports = router;
