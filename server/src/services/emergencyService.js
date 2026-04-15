/**
 * Emergency Service
 *
 * Handles emergency request creation and lifecycle management.
 */

const { supabase } = require('../config/supabase');
const { EMERGENCY_STATUS, ERROR_MESSAGES } = require('../config/constants');
const { AppError } = require('../middlewares/errorHandler');
const { createDispatch } = require('./dispatchService');

/**
 * Create a new emergency request
 *
 * @param {number} patientLat - Patient latitude
 * @param {number} patientLng - Patient longitude
 * @param {string} description - Initial description (optional)
 * @returns {Promise<Object>} Created emergency request
 */
const createEmergencyRequest = async (patientLat, patientLng, description = null) => {
  console.log(`[Emergency] Creating emergency request at (${patientLat}, ${patientLng})`);

  const { data, error } = await supabase
    .from('emergency_requests')
    .insert({
      user_latitude: patientLat,
      user_longitude: patientLng,
      description: description,
      status: EMERGENCY_STATUS.SEARCHING_AMBULANCE,
      created_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    console.error('[Emergency] Error creating emergency request:', error);
    throw new AppError('Failed to create emergency request', 500);
  }

  console.log(`[Emergency] Created emergency request: ${data.request_id}`);

  return data;
};

/**
 * Get emergency request by ID
 * 
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object>} Emergency request data
 */
const getEmergencyRequest = async (requestId) => {
  const { data, error } = await supabase
    .from('emergency_requests')
    .select(`
      *,
      ambulances (*),
      hospitals (*)
    `)
    .eq('request_id', requestId)
    .single();

  if (error || !data) {
    throw new AppError(ERROR_MESSAGES.EMERGENCY_NOT_FOUND, 404);
  }

  return data;
};

/**
 * Update emergency request status
 * 
 * @param {string} requestId - Emergency request ID
 * @param {string} status - New status value
 * @param {Object} additionalFields - Additional fields to update
 * @returns {Promise<Object>} Updated emergency request
 */
const updateEmergencyStatus = async (requestId, status, additionalFields = {}) => {
  const { data, error } = await supabase
    .from('emergency_requests')
    .update({
      status,
      ...additionalFields
    })
    .eq('request_id', requestId)
    .select()
    .single();

  if (error) {
    console.error('Error updating emergency status:', error);
    throw new AppError('Failed to update emergency status', 500);
  }

  return data;
};

/**
 * Assign ambulance to emergency request
 *
 * @param {string} requestId - Emergency request ID
 * @param {string} ambulanceId - Ambulance ID
 * @returns {Promise<Object>} Updated emergency request
 */
const assignAmbulance = async (requestId, ambulanceId) => {
  console.log(`[Emergency] Assigning ambulance ${ambulanceId} to request ${requestId}`);

  const result = await updateEmergencyStatus(requestId, EMERGENCY_STATUS.AMBULANCE_ASSIGNED, {
    ambulance_id: ambulanceId
  });

  // Create dispatch record
  try {
    await createDispatch(requestId, ambulanceId);
    console.log(`[Emergency] Dispatch record created for request ${requestId}`);
  } catch (dispatchError) {
    // Log but don't fail the assignment if dispatch creation fails
    console.error(`[Emergency] Warning: Could not create dispatch record: ${dispatchError.message}`);
  }

  return result;
};

/**
 * Assign hospital to emergency request (transaction-safe)
 * 
 * @param {string} requestId - Emergency request ID
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Object>} Updated emergency request
 */
const assignHospital = async (requestId, hospitalId) => {
  return updateEmergencyStatus(requestId, EMERGENCY_STATUS.HOSPITAL_APPROVED, {
    hospital_id: hospitalId
  });
};

/**
 * Update medical keywords for an emergency request
 * 
 * @param {string} requestId - Emergency request ID
 * @param {Object} medicalData - Extracted medical data from Gemini
 * @returns {Promise<Object>} Updated emergency request
 */
const updateMedicalKeywords = async (requestId, medicalData) => {
  const { data, error } = await supabase
    .from('emergency_requests')
    .update({
      description: medicalData.raw_text,
      medical_keywords: medicalData.keywords,
      severity: medicalData.severity,
      specialties_needed: medicalData.specialties_needed,
      equipment_needed: medicalData.equipment_needed
    })
    .eq('request_id', requestId)
    .select()
    .single();

  if (error) {
    console.error('Error updating medical keywords:', error);
    throw new AppError('Failed to update medical keywords', 500);
  }

  return data;
};

/**
 * Route to stabilization center
 * 
 * @param {string} requestId - Emergency request ID
 * @param {string} centerId - Stabilization center ID
 * @returns {Promise<Object>} Updated emergency request
 */
const routeToStabilization = async (requestId, centerId) => {
  return updateEmergencyStatus(requestId, EMERGENCY_STATUS.ROUTED_TO_STABILIZATION, {
    stabilization_center_id: centerId
  });
};

/**
 * Complete emergency request
 * 
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object>} Updated emergency request
 */
const completeEmergency = async (requestId) => {
  return updateEmergencyStatus(requestId, EMERGENCY_STATUS.COMPLETED);
};

/**
 * Cancel emergency request
 * 
 * @param {string} requestId - Emergency request ID
 * @param {string} reason - Cancellation reason
 * @returns {Promise<Object>} Updated emergency request
 */
const cancelEmergency = async (requestId, reason = null) => {
  return updateEmergencyStatus(requestId, EMERGENCY_STATUS.CANCELLED);
};

/**
 * Get active emergency requests (for monitoring)
 * 
 * @returns {Promise<Array>} Active emergency requests
 */
const getActiveEmergencies = async () => {
  const activeStatuses = [
    EMERGENCY_STATUS.SEARCHING_AMBULANCE,
    EMERGENCY_STATUS.AMBULANCE_ASSIGNED,
    EMERGENCY_STATUS.SEARCHING_HOSPITAL,
    EMERGENCY_STATUS.HOSPITAL_APPROVED,
    EMERGENCY_STATUS.ROUTED_TO_STABILIZATION
  ];

  const { data, error } = await supabase
    .from('emergency_requests')
    .select(`
      *,
      ambulances (*),
      hospitals (*)
    `)
    .in('status', activeStatuses)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching active emergencies:', error);
    throw new AppError('Failed to fetch active emergencies', 500);
  }

  return data || [];
};

/**
 * Get pending emergency assigned to a specific ambulance
 * 
 * @param {string} ambulanceId - Ambulance ID
 * @returns {Promise<Object|null>} Pending emergency or null
 */
const getPendingForAmbulance = async (ambulanceId) => {
  const { data, error } = await supabase
    .from('emergency_requests')
    .select('*')
    .eq('ambulance_id', ambulanceId)
    .in('status', [
      EMERGENCY_STATUS.AMBULANCE_ASSIGNED,
      EMERGENCY_STATUS.SEARCHING_AMBULANCE
    ])
    .order('created_at', { ascending: false })
    .limit(1);

  if (error) {
    console.error('Error fetching pending emergency:', error);
    return null;
  }

  return (data && data.length > 0) ? data[0] : null;
};

/**
 * Cancel ALL active emergencies (bulk cleanup for development/testing).
 * @returns {Promise<number>} Number of cancelled records
 */
const cancelAllActive = async () => {
  const activeStatuses = [
    EMERGENCY_STATUS.SEARCHING_AMBULANCE,
    EMERGENCY_STATUS.AMBULANCE_ASSIGNED,
    EMERGENCY_STATUS.SEARCHING_HOSPITAL,
    EMERGENCY_STATUS.HOSPITAL_APPROVED,
    EMERGENCY_STATUS.ROUTED_TO_STABILIZATION
  ];

  const { data, error } = await supabase
    .from('emergency_requests')
    .update({ status: EMERGENCY_STATUS.CANCELLED })
    .in('status', activeStatuses)
    .select();

  if (error) {
    console.error('Error cancelling all active emergencies:', error);
    throw new AppError('Failed to cancel active emergencies', 500);
  }

  return (data && data.length) || 0;
};

module.exports = {
  createEmergencyRequest,
  getEmergencyRequest,
  updateEmergencyStatus,
  assignAmbulance,
  assignHospital,
  updateMedicalKeywords,
  routeToStabilization,
  completeEmergency,
  cancelEmergency,
  cancelAllActive,
  getActiveEmergencies,
  getPendingForAmbulance
};
