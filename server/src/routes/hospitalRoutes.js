/**
 * Hospital Routes
 * 
 * API endpoints for the Hospital Dashboard (React).
 */

const express = require('express');
const router = express.Router();
const { hospitalController } = require('../controllers');
const { asyncHandler } = require('../middlewares/errorHandler');
const { validateHospital } = require('../middlewares/authMiddleware');

/**
 * GET /api/hospital/all
 * Get all hospitals with resources
 * Query: { available_only? }
 */
router.get('/all', asyncHandler(hospitalController.getAllHospitals));

/**
 * GET /api/hospital/resource-summary
 * Get aggregate resource summary across all hospitals
 */
router.get('/resource-summary', asyncHandler(hospitalController.getResourceSummary));

/**
 * POST /api/hospital/respond
 * Hospital responds to emergency request (approve/reject)
 * Transaction-safe with race condition handling
 * Body: { hospitalRequestId, decision: 'approve' | 'reject' }
 */
router.post('/respond', asyncHandler(hospitalController.respondToRequest));

/**
 * GET /api/hospital/active-requests/:hospitalId
 * Get pending emergency requests for a hospital
 */
router.get(
  '/active-requests/:hospitalId',
  asyncHandler(hospitalController.getActiveRequests)
);

/**
 * GET /api/hospital/:hospitalId/resources
 * Get hospital resource information
 */
router.get(
  '/:hospitalId/resources',
  asyncHandler(hospitalController.getHospitalResources)
);

/**
 * GET /api/hospital/:hospitalId/alerts
 * Check resource alerts for a hospital
 */
router.get(
  '/:hospitalId/alerts',
  asyncHandler(hospitalController.checkAlerts)
);

module.exports = router;
