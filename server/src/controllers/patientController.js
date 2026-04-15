/**
 * Patient Controller
 *
 * Handles patient-facing API endpoints.
 * Thin layer that delegates to services.
 */

const { emergencyService, ambulanceService, hospitalMatcher } = require('../services');
const { extractMedicalKeywords } = require('../utils/geminiExtractor');
const { isValidCoordinate } = require('../utils/distanceCalculator');
const response = require('../utils/responseFormatter');
const { EMERGENCY_STATUS, ERROR_MESSAGES, HTTP_STATUS } = require('../config/constants');
const { emitNewAssignment, emitRequestUpdate } = require('../socket/socketManager');

/**
 * POST /api/patient/emergency
 * Create a new emergency request and assign nearest ambulance
 */
const createEmergency = async (req, res, next) => {
  try {
    const { patient_lat, patient_lng, description } = req.body;

    // Validate coordinates
    if (!isValidCoordinate(patient_lat, patient_lng)) {
      return response.badRequest(res, 'Invalid or missing patient coordinates');
    }

    console.log(`[Patient] Emergency request created at (${patient_lat}, ${patient_lng})`);

    // Step 1: Create emergency request
    const emergency = await emergencyService.createEmergencyRequest(
      patient_lat,
      patient_lng,
      description
    );

    console.log(`[Patient] Emergency created: ${emergency.request_id}, searching for ambulance...`);

    // Step 2: Find and assign nearest ambulance
    const ambulance = await ambulanceService.findAndAssignNearestAmbulance(
      patient_lat,
      patient_lng
    );

    if (!ambulance) {
      console.log(`[Patient] No ambulances available for request ${emergency.request_id}`);
      return response.error(
        res,
        ERROR_MESSAGES.NO_AMBULANCE_AVAILABLE,
        HTTP_STATUS.SERVICE_UNAVAILABLE
      );
    }

    console.log(`[Patient] Found ambulance ${ambulance.ambulance_id} for request ${emergency.request_id}`);

    // Step 3: Update emergency with ambulance assignment (this also creates dispatch record)
    const updatedEmergency = await emergencyService.assignAmbulance(
      emergency.request_id,
      ambulance.ambulance_id
    );

    console.log(`[Patient] Ambulance ${ambulance.ambulance_id} assigned to request ${emergency.request_id}`);

    // Step 4: Emit Socket.IO event to notify ambulance driver
    const assignmentData = {
      request_id: emergency.request_id,
      patient_latitude: patient_lat,
      patient_longitude: patient_lng,
      description: description || '',
      severity: emergency.severity || 'medium'
    };

    emitNewAssignment(ambulance.ambulance_id, assignmentData);

    // Also emit status update to patient
    emitRequestUpdate(emergency.request_id, {
      status: EMERGENCY_STATUS.AMBULANCE_ASSIGNED,
      ambulance: {
        ambulance_id: ambulance.ambulance_id,
        driver_name: ambulance.driver_name,
        ambulance_no: ambulance.ambulance_no
      }
    });

    return response.created(res, {
      request_id: updatedEmergency.request_id,
      status: updatedEmergency.status,
      ambulance: {
        ambulance_id: ambulance.ambulance_id,
        driver_name: ambulance.driver_name,
        ambulance_no: ambulance.ambulance_no,
        current_latitude: ambulance.current_latitude,
        current_longitude: ambulance.current_longitude,
        distance_km: ambulance.distance?.toFixed(2)
      }
    }, 'Emergency created and ambulance assigned');

  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/patient/:requestId/condition
 * Update patient condition and extract medical keywords using Gemini
 */
const updateCondition = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const { condition_text } = req.body;

    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    if (!condition_text || typeof condition_text !== 'string') {
      return response.badRequest(res, 'Condition text is required');
    }

    // Get current emergency status
    const emergency = await emergencyService.getEmergencyRequest(requestId);

    // Extract medical keywords using Gemini
    const medicalData = await extractMedicalKeywords(condition_text);

    // Update emergency request with keywords
    const updatedEmergency = await emergencyService.updateMedicalKeywords(
      requestId,
      medicalData
    );

    // If ambulance already approved, trigger hospital matching
    let hospitalMatchResult = null;
    if (emergency.status === EMERGENCY_STATUS.AMBULANCE_ASSIGNED || 
        emergency.status === EMERGENCY_STATUS.SEARCHING_HOSPITAL) {
      hospitalMatchResult = await hospitalMatcher.matchHospitals(
        requestId,
        emergency.user_latitude,
        emergency.user_longitude
      );
    }

    return response.success(res, {
      request_id: requestId,
      medical_data: {
        keywords: medicalData.keywords,
        severity: medicalData.severity,
        specialties_needed: medicalData.specialties_needed,
        equipment_needed: medicalData.equipment_needed
      },
      hospital_matching: hospitalMatchResult
    }, 'Condition updated successfully');

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/patient/:requestId/status
 * Get current status of an emergency request
 */
const getEmergencyStatus = async (req, res, next) => {
  try {
    const { requestId } = req.params;

    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    const emergency = await emergencyService.getEmergencyRequest(requestId);

    return response.success(res, {
      request_id: emergency.request_id,
      status: emergency.status,
      created_at: emergency.created_at,
      ambulance: emergency.ambulances,
      hospital: emergency.hospitals,
      medical_keywords: emergency.medical_keywords,
      severity: emergency.severity
    });

  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/patient/:requestId/cancel
 * Cancel an emergency request
 */
const cancelEmergency = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const { reason } = req.body;

    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    const emergency = await emergencyService.getEmergencyRequest(requestId);

    // Release ambulance if assigned
    if (emergency.ambulance_id) {
      await ambulanceService.releaseAmbulance(emergency.ambulance_id);
    }

    // Cancel the emergency
    const cancelled = await emergencyService.cancelEmergency(requestId, reason);

    return response.success(res, {
      request_id: cancelled.request_id,
      status: cancelled.status,
      cancelled_at: cancelled.cancelled_at
    }, 'Emergency cancelled successfully');

  } catch (error) {
    next(error);
  }
};

module.exports = {
  createEmergency,
  updateCondition,
  getEmergencyStatus,
  cancelEmergency
};
