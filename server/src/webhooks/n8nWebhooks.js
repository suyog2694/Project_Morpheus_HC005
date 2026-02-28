/**
 * N8N Webhooks
 * 
 * Webhook endpoints for n8n automation integration.
 * Secured with API key authentication.
 */

const express = require('express');
const router = express.Router();
const { resourceService } = require('../services');
const { validateWebhookApiKey, webhookRateLimit } = require('../middlewares/apiKeyMiddleware');
const { asyncHandler } = require('../middlewares/errorHandler');
const response = require('../utils/responseFormatter');
const { LOW_BED_THRESHOLD } = require('../config/constants');

// Apply rate limiting and API key validation to all webhook routes
router.use(webhookRateLimit);
router.use(validateWebhookApiKey);

/**
 * POST /webhook/update-bed-count
 * Update hospital bed count from n8n automation
 * Body: { hospital_id, bed_available?, bed_total?, icu_available?, icu_total?, ventilator_available?, ventilator_total? }
 */
router.post('/update-bed-count', asyncHandler(async (req, res) => {
  const { hospital_id, ...updates } = req.body;

  if (!hospital_id) {
    return response.badRequest(res, 'Hospital ID is required');
  }

  const validUpdates = {};
  const allowedFields = [
    'bed_available', 'bed_total',
    'icu_available', 'icu_total',
    'ventilator_available', 'ventilator_total'
  ];

  for (const [key, value] of Object.entries(updates)) {
    if (allowedFields.includes(key) && typeof value === 'number') {
      validUpdates[key] = value;
    }
  }

  if (Object.keys(validUpdates).length === 0) {
    return response.badRequest(res, 'No valid fields to update');
  }

  const updated = await resourceService.updateHospitalResources(hospital_id, validUpdates);

  // Check for alerts
  const alerts = await resourceService.checkResourceAlerts(hospital_id);

  return response.success(res, {
    hospital_id,
    updated_resources: updated,
    alerts: alerts.alerts
  }, 'Resources updated successfully');
}));

/**
 * POST /webhook/low-bed-alert
 * Trigger low bed alert notification from n8n
 * Body: { hospital_id, threshold? }
 */
router.post('/low-bed-alert', asyncHandler(async (req, res) => {
  const { hospital_id, threshold = LOW_BED_THRESHOLD } = req.body;

  if (!hospital_id) {
    return response.badRequest(res, 'Hospital ID is required');
  }

  const resources = await resourceService.getHospitalResources(hospital_id);

  const alertData = {
    hospital_id,
    hospital_name: resources.hospitals?.name,
    current_beds: resources.bed_available,
    threshold,
    is_critical: resources.bed_available === 0,
    is_warning: resources.bed_available > 0 && resources.bed_available <= threshold,
    timestamp: new Date().toISOString()
  };

  if (resources.bed_available <= threshold) {
    console.warn(`LOW BED ALERT: Hospital ${hospital_id} has ${resources.bed_available} beds`);
    
    // In production, this would trigger notifications
    // - Push notification to admin dashboard
    // - Email alerts to hospital staff
    // - SMS to emergency coordinators
    
    return response.success(res, {
      alert_triggered: true,
      ...alertData
    }, 'Low bed alert triggered');
  }

  return response.success(res, {
    alert_triggered: false,
    ...alertData
  }, 'Bed count above threshold');
}));

/**
 * POST /webhook/sync-resources
 * Bulk sync hospital resources from external system
 * Body: { hospitals: [{ hospital_id, bed_available, icu_available, ventilator_available }] }
 */
router.post('/sync-resources', asyncHandler(async (req, res) => {
  const { hospitals } = req.body;

  if (!Array.isArray(hospitals) || hospitals.length === 0) {
    return response.badRequest(res, 'Hospitals array is required');
  }

  const results = {
    success: [],
    failed: []
  };

  for (const hospital of hospitals) {
    try {
      if (!hospital.hospital_id) {
        results.failed.push({
          hospital_id: null,
          error: 'Missing hospital_id'
        });
        continue;
      }

      const updates = {};
      if (typeof hospital.bed_available === 'number') {
        updates.bed_available = hospital.bed_available;
      }
      if (typeof hospital.icu_available === 'number') {
        updates.icu_available = hospital.icu_available;
      }
      if (typeof hospital.ventilator_available === 'number') {
        updates.ventilator_available = hospital.ventilator_available;
      }

      if (Object.keys(updates).length > 0) {
        await resourceService.updateHospitalResources(hospital.hospital_id, updates);
        results.success.push(hospital.hospital_id);
      }
    } catch (error) {
      results.failed.push({
        hospital_id: hospital.hospital_id,
        error: error.message
      });
    }
  }

  return response.success(res, {
    total_processed: hospitals.length,
    successful: results.success.length,
    failed: results.failed.length,
    details: results
  }, 'Sync completed');
}));

/**
 * GET /webhook/resource-status
 * Get current resource status for all hospitals
 * Used by n8n for monitoring workflows
 */
router.get('/resource-status', asyncHandler(async (req, res) => {
  const summary = await resourceService.getResourceSummary();
  const hospitals = await resourceService.getAllHospitalsWithResources(false);

  // Identify critical hospitals (zero beds)
  const criticalHospitals = hospitals.filter(h => 
    h.hospital_resources?.bed_available === 0
  );

  // Identify warning hospitals (low beds)
  const warningHospitals = hospitals.filter(h => 
    h.hospital_resources?.bed_available > 0 && 
    h.hospital_resources?.bed_available <= LOW_BED_THRESHOLD
  );

  return response.success(res, {
    summary,
    critical_hospitals: criticalHospitals.map(h => ({
      hospital_id: h.hospital_id,
      name: h.name,
      beds_available: h.hospital_resources?.bed_available
    })),
    warning_hospitals: warningHospitals.map(h => ({
      hospital_id: h.hospital_id,
      name: h.name,
      beds_available: h.hospital_resources?.bed_available
    })),
    system_status: criticalHospitals.length === hospitals.length ? 'critical' :
                   criticalHospitals.length > 0 ? 'degraded' : 'healthy'
  });
}));

/**
 * POST /webhook/emergency-completion
 * Webhook called when emergency is completed
 * Body: { request_id, completed_at, destination_type, destination_id }
 */
router.post('/emergency-completion', asyncHandler(async (req, res) => {
  const { request_id, completed_at, destination_type, destination_id } = req.body;

  if (!request_id) {
    return response.badRequest(res, 'Request ID is required');
  }

  // Log completion for analytics
  console.log(`Emergency ${request_id} completed at ${completed_at}`);
  console.log(`Destination: ${destination_type} (${destination_id})`);

  // In production, this could:
  // - Update analytics dashboards
  // - Trigger follow-up workflows
  // - Send completion notifications
  
  return response.success(res, {
    acknowledged: true,
    request_id,
    processed_at: new Date().toISOString()
  }, 'Completion webhook processed');
}));

module.exports = router;
