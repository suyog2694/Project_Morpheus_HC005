/**
 * Ambulance Routes
 * 
 * API endpoints for the Ambulance App (Flutter).
 */

const express = require('express');
const router = express.Router();
const { ambulanceController } = require('../controllers');
const { asyncHandler } = require('../middlewares/errorHandler');
const { validateAmbulance } = require('../middlewares/authMiddleware');

/**
 * GET /api/ambulance
 * Get all ambulances with optional status filter
 * Query: { status? }
 */
router.get('/', asyncHandler(ambulanceController.getAllAmbulances));

/**
 * POST /api/ambulance/register
 * Register a new ambulance crew
 * Body: { driver_name, ambulance_no, driver_phone }
 */
router.post('/register', asyncHandler(ambulanceController.register));

/**
 * POST /api/ambulance/login
 * Login by ambulance plate number + phone
 * Body: { ambulance_no, driver_phone }
 */
router.post('/login', asyncHandler(ambulanceController.login));

/**
 * GET /api/ambulance/:ambulanceId
 * Get ambulance details
 */
router.get('/:ambulanceId', asyncHandler(ambulanceController.getAmbulanceDetails));

/**
 * GET /api/ambulance/:ambulanceId/pending
 * Check for pending emergency assigned to this ambulance
 */
router.get('/:ambulanceId/pending', asyncHandler(ambulanceController.getPendingEmergency));

/**
 * POST /api/ambulance/:ambulanceId/respond
 * Ambulance driver responds to emergency assignment
 * Body: { requestId, decision: 'approve' | 'reject' }
 */
router.post(
  '/:ambulanceId/respond',
  validateAmbulance,
  asyncHandler(ambulanceController.respondToEmergency)
);

/**
 * PUT /api/ambulance/:ambulanceId/location
 * Update ambulance current location
 * Body: { latitude, longitude }
 */
router.put(
  '/:ambulanceId/location',
  validateAmbulance,
  asyncHandler(ambulanceController.updateLocation)
);

/**
 * POST /api/ambulance/arrival
 * Mark arrival at destination
 * Body: { requestId }
 */
router.post('/arrival', asyncHandler(ambulanceController.markArrival));

module.exports = router;
