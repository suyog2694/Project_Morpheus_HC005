/**
 * Patient Routes
 * 
 * API endpoints for the Patient App (Flutter).
 */

const express = require('express');
const router = express.Router();
const { patientController } = require('../controllers');
const { asyncHandler } = require('../middlewares/errorHandler');

/**
 * POST /api/patient/emergency
 * Create new emergency request and assign ambulance
 * Body: { patient_lat, patient_lng, description? }
 */
router.post('/emergency', asyncHandler(patientController.createEmergency));

/**
 * POST /api/patient/:requestId/condition
 * Update patient condition with medical keywords extraction
 * Body: { condition_text }
 */
router.post('/:requestId/condition', asyncHandler(patientController.updateCondition));

/**
 * GET /api/patient/:requestId/status
 * Get current status of an emergency request
 */
router.get('/:requestId/status', asyncHandler(patientController.getEmergencyStatus));

/**
 * POST /api/patient/:requestId/cancel
 * Cancel an emergency request
 * Body: { reason? }
 */
router.post('/:requestId/cancel', asyncHandler(patientController.cancelEmergency));

module.exports = router;
