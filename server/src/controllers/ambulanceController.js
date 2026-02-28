/**
 * Ambulance Controller
 * 
 * Handles ambulance-facing API endpoints.
 * Thin layer that delegates to services.
 */

const { emergencyService, ambulanceService, hospitalMatcher } = require('../services');
const response = require('../utils/responseFormatter');
const { EMERGENCY_STATUS, ERROR_MESSAGES, HTTP_STATUS } = require('../config/constants');

/**
 * POST /api/ambulance/:ambulanceId/respond
 * Ambulance driver approves or rejects an emergency assignment
 */
const respondToEmergency = async (req, res, next) => {
  try {
    const { ambulanceId } = req.params;
    const { requestId, decision } = req.body;

    // Validate inputs
    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    if (!['approve', 'reject'].includes(decision)) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_DECISION);
    }

    // Get the emergency request
    const emergency = await emergencyService.getEmergencyRequest(requestId);

    // Verify this ambulance is assigned to this request
    if (emergency.ambulance_id !== ambulanceId) {
      return response.forbidden(res, 'This ambulance is not assigned to this request');
    }

    if (decision === 'approve') {
      // Update status to searching_hospital
      const updatedEmergency = await emergencyService.updateEmergencyStatus(
        requestId,
        EMERGENCY_STATUS.SEARCHING_HOSPITAL
      );

      // Trigger hospital matching
      const matchResult = await hospitalMatcher.matchHospitals(
        requestId,
        emergency.user_latitude,
        emergency.user_longitude
      );

      return response.success(res, {
        request_id: requestId,
        status: updatedEmergency.status,
        hospital_matching: matchResult
      }, 'Emergency accepted, searching for hospital');

    } else {
      // Reject: Release current ambulance and find next one
      await ambulanceService.releaseAmbulance(ambulanceId);

      // Find next nearest ambulance (excluding this one)
      const nextAmbulance = await ambulanceService.findAndAssignNearestAmbulance(
        emergency.user_latitude,
        emergency.user_longitude,
        [ambulanceId] // Exclude rejected ambulance
      );

      if (!nextAmbulance) {
        // No more ambulances available
        return response.error(
          res,
          ERROR_MESSAGES.NO_AMBULANCE_AVAILABLE,
          HTTP_STATUS.SERVICE_UNAVAILABLE,
          { request_id: requestId }
        );
      }

      // Assign new ambulance
      const updatedEmergency = await emergencyService.assignAmbulance(
        requestId,
        nextAmbulance.ambulance_id
      );

      return response.success(res, {
        request_id: requestId,
        status: updatedEmergency.status,
        new_ambulance: {
          ambulance_id: nextAmbulance.ambulance_id,
          driver_name: nextAmbulance.driver_name,
          ambulance_no: nextAmbulance.ambulance_no,
          distance_km: nextAmbulance.distance?.toFixed(2)
        }
      }, 'Rejection processed, new ambulance assigned');
    }

  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/ambulance/arrival
 * Mark ambulance arrival at destination (hospital or stabilization center)
 */
const markArrival = async (req, res, next) => {
  try {
    const { requestId } = req.body;

    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    // Get emergency request
    const emergency = await emergencyService.getEmergencyRequest(requestId);

    // Verify status allows completion
    const allowedStatuses = [
      EMERGENCY_STATUS.HOSPITAL_APPROVED,
      EMERGENCY_STATUS.ROUTED_TO_STABILIZATION
    ];

    if (!allowedStatuses.includes(emergency.status)) {
      return response.badRequest(res, `Cannot mark arrival for status: ${emergency.status}`);
    }

    // Release the ambulance
    if (emergency.ambulance_id) {
      await ambulanceService.releaseAmbulance(emergency.ambulance_id);
    }

    // Complete the emergency
    const completed = await emergencyService.completeEmergency(requestId);

    // TODO: Trigger n8n webhook for completion notification
    // This would be done via an HTTP call to n8n

    return response.success(res, {
      request_id: completed.request_id,
      status: completed.status,
      completed_at: completed.completed_at,
      destination_type: emergency.hospital_id ? 'hospital' : 'stabilization_center',
      destination_id: emergency.hospital_id || emergency.stabilization_center_id
    }, 'Arrival confirmed, emergency completed');

  } catch (error) {
    next(error);
  }
};

/**
 * PUT /api/ambulance/:ambulanceId/location
 * Update ambulance current location
 */
const updateLocation = async (req, res, next) => {
  try {
    const { ambulanceId } = req.params;
    const { latitude, longitude } = req.body;

    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
      return response.badRequest(res, 'Valid latitude and longitude are required');
    }

    const updated = await ambulanceService.updateAmbulanceLocation(
      ambulanceId,
      latitude,
      longitude
    );

    return response.success(res, {
      ambulance_id: updated.ambulance_id,
      current_latitude: updated.current_latitude,
      current_longitude: updated.current_longitude,
      location_updated_at: updated.location_updated_at
    }, 'Location updated');

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/ambulance/:ambulanceId
 * Get ambulance details
 */
const getAmbulanceDetails = async (req, res, next) => {
  try {
    const { ambulanceId } = req.params;

    const ambulance = await ambulanceService.getAmbulanceById(ambulanceId);

    return response.success(res, ambulance);

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/ambulance
 * Get all ambulances with optional status filter
 */
const getAllAmbulances = async (req, res, next) => {
  try {
    const { status } = req.query;

    const ambulances = await ambulanceService.getAllAmbulances(status);

    return response.success(res, {
      count: ambulances.length,
      ambulances
    });

  } catch (error) {
    next(error);
  }
};

module.exports = {
  respondToEmergency,
  markArrival,
  updateLocation,
  getAmbulanceDetails,
  getAllAmbulances
};
