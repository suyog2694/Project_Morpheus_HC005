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
const { emergencyService, ambulanceService } = require('../services');

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

// DEV: Cancel all active emergencies + release all ambulances in one call
router.post('/cleanup', async (req, res) => {
  try {
    const cancelled = await emergencyService.cancelAllActive();
    const released  = await ambulanceService.releaseAllAmbulances();
    res.json({ success: true, message: `Cancelled ${cancelled} emergencies, released ${released} ambulances` });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
