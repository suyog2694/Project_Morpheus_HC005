/**
 * Hospital Controller
 * 
 * Handles hospital dashboard API endpoints.
 * Manages hospital responses to emergency requests.
 */

const { hospitalMatcher, resourceService, emergencyService } = require('../services');
const response = require('../utils/responseFormatter');
const { ERROR_MESSAGES, HTTP_STATUS, HOSPITAL_REQUEST_STATUS } = require('../config/constants');

/**
 * GET /api/hospital/active-requests/:hospitalId
 * Get pending emergency requests for a specific hospital
 */
const getActiveRequests = async (req, res, next) => {
  try {
    const { hospitalId } = req.params;

    if (!hospitalId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_HOSPITAL_ID);
    }

    const pendingRequests = await hospitalMatcher.getPendingRequestsForHospital(hospitalId);

    return response.success(res, {
      hospital_id: hospitalId,
      pending_count: pendingRequests.length,
      requests: pendingRequests.map(req => ({
        hospital_request_id: req.id,
        request_id: req.request_id,
        priority_order: req.priority_order,
        distance_km: req.distance_km?.toFixed(2),
        requested_at: req.requested_at,
        emergency: {
          patient_location: {
            latitude: req.emergency_requests?.user_latitude,
            longitude: req.emergency_requests?.user_longitude
          },
          description: req.emergency_requests?.description,
          severity: req.emergency_requests?.severity,
          medical_keywords: req.emergency_requests?.medical_keywords,
          created_at: req.emergency_requests?.created_at
        }
      }))
    });

  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/hospital/respond
 * Hospital approves or rejects an emergency request
 * Transaction-safe with race condition handling
 */
const respondToRequest = async (req, res, next) => {
  try {
    const { hospitalRequestId, decision } = req.body;

    if (!hospitalRequestId) {
      return response.badRequest(res, 'Hospital request ID is required');
    }

    if (!['approve', 'reject'].includes(decision)) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_DECISION);
    }

    // Get the hospital request
    const hospitalRequest = await hospitalMatcher.getHospitalRequestById(hospitalRequestId);

    // Check if already processed
    if (hospitalRequest.status !== HOSPITAL_REQUEST_STATUS.PENDING) {
      return response.conflict(res, ERROR_MESSAGES.REQUEST_ALREADY_PROCESSED);
    }

    if (decision === 'approve') {
      try {
        const result = await hospitalMatcher.processHospitalApproval(
          hospitalRequestId,
          hospitalRequest.hospital_id,
          hospitalRequest.request_id
        );

        return response.success(res, {
          status: 'approved',
          request_id: hospitalRequest.request_id,
          hospital: result.hospital,
          beds_remaining: result.bed_remaining
        }, 'Emergency request approved successfully');

      } catch (error) {
        // Handle race condition errors gracefully
        if (error.statusCode === HTTP_STATUS.CONFLICT) {
          return response.conflict(res, error.message);
        }
        throw error;
      }

    } else {
      // Process rejection
      const result = await hospitalMatcher.processHospitalRejection(
        hospitalRequestId,
        hospitalRequest.request_id
      );

      if (result.is_stabilization) {
        return response.success(res, {
          status: 'rejected',
          routed_to_stabilization: true,
          stabilization_center: result.stabilization_center
        }, 'Rejected. Patient routed to stabilization center');
      }

      return response.success(res, {
        status: 'rejected',
        next_hospital: result.next_hospital ? {
          hospital_id: result.next_hospital.hospital_id,
          name: result.next_hospital.name
        } : null
      }, 'Rejection processed');
    }

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/hospital/:hospitalId/resources
 * Get hospital resource information
 */
const getHospitalResources = async (req, res, next) => {
  try {
    const { hospitalId } = req.params;

    if (!hospitalId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_HOSPITAL_ID);
    }

    const resources = await resourceService.getHospitalResources(hospitalId);

    return response.success(res, {
      hospital_id: hospitalId,
      hospital_name: resources.hospitals?.name,
      resources: {
        icu: {
          total: resources.icu_total,
          available: resources.icu_available
        },
        beds: {
          total: resources.bed_total,
          available: resources.bed_available
        },
        ventilators: {
          total: resources.ventilator_total,
          available: resources.ventilator_available
        }
      },
      last_updated_at: resources.last_updated_at
    });

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/hospital/all
 * Get all hospitals with their resources
 */
const getAllHospitals = async (req, res, next) => {
  try {
    const { available_only } = req.query;

    const hospitals = await resourceService.getAllHospitalsWithResources(
      available_only === 'true'
    );

    return response.success(res, {
      count: hospitals.length,
      hospitals: hospitals.map(h => ({
        hospital_id: h.hospital_id,
        name: h.name,
        latitude: h.latitude,
        longitude: h.longitude,
        contact_number: h.contact_number,
        resources: h.hospital_resources ? {
          beds_available: h.hospital_resources.bed_available,
          beds_total: h.hospital_resources.bed_total,
          icu_available: h.hospital_resources.icu_available,
          ventilators_available: h.hospital_resources.ventilator_available
        } : null
      }))
    });

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/hospital/resource-summary
 * Get aggregate resource summary across all hospitals
 */
const getResourceSummary = async (req, res, next) => {
  try {
    const summary = await resourceService.getResourceSummary();

    return response.success(res, summary);

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/hospital/:hospitalId/alerts
 * Check resource alerts for a hospital
 */
const checkAlerts = async (req, res, next) => {
  try {
    const { hospitalId } = req.params;

    if (!hospitalId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_HOSPITAL_ID);
    }

    const alerts = await resourceService.checkResourceAlerts(hospitalId);

    return response.success(res, alerts);

  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/hospital/emergencies
 * Get all active emergencies for the hospital dashboard to display
 */
const getActiveEmergencies = async (req, res, next) => {
  try {
    const emergencies = await emergencyService.getActiveEmergencies();

    return response.success(res, {
      count: emergencies.length,
      emergencies: emergencies.map(e => ({
        request_id: e.request_id,
        description: e.description,
        patient_lat: e.user_latitude,
        patient_lng: e.user_longitude,
        severity: e.severity,
        medical_keywords: e.medical_keywords,
        status: e.status,
        created_at: e.created_at,
        ambulance: e.ambulances ? {
          ambulance_id: e.ambulances.ambulance_id,
          driver_name: e.ambulances.driver_name,
          ambulance_no: e.ambulances.ambulance_no
        } : null
      }))
    });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/hospital/emergencies/:requestId/accept
 * Hospital accepts an emergency — updates status to hospital_approved
 */
const acceptEmergency = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const { hospital_id } = req.body;

    if (!requestId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_REQUEST_ID);
    }

    const emergency = await emergencyService.getEmergencyRequest(requestId);

    // Only allow accepting if ambulance is assigned or searching hospital
    const allowed = [
      EMERGENCY_STATUS.AMBULANCE_ASSIGNED,
      EMERGENCY_STATUS.SEARCHING_HOSPITAL
    ];
    if (!allowed.includes(emergency.status)) {
      return response.badRequest(res, `Cannot accept emergency with status: ${emergency.status}`);
    }

    const updated = await emergencyService.assignHospital(
      requestId,
      hospital_id || null
    );

    return response.success(res, {
      request_id: updated.request_id,
      status: updated.status
    }, 'Emergency accepted by hospital');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getActiveRequests,
  respondToRequest,
  getHospitalResources,
  getAllHospitals,
  getResourceSummary,
  checkAlerts,
  getActiveEmergencies,
  acceptEmergency
};
