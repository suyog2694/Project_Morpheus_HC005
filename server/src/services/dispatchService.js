/**
 * Dispatch Service
 *
 * Handles emergency_dispatch table operations for tracking
 * the actual dispatch execution between ambulances, hospitals,
 * and emergency requests.
 */

const { supabase } = require('../config/supabase');
const { EMERGENCY_STATUS, HOSPITAL_REQUEST_STATUS } = require('../config/constants');
const { AppError } = require('../middlewares/errorHandler');

/**
 * Create a new dispatch record when ambulance is assigned
 *
 * @param {string} requestId - Emergency request ID
 * @param {number} ambulanceId - Assigned ambulance ID
 * @returns {Promise<Object>} Created dispatch record
 */
const createDispatch = async (requestId, ambulanceId) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .insert({
      request_id: requestId,
      ambulance_id: ambulanceId,
      ambulance_status: 'dispatched',
      dispatched_at: new Date().toISOString()
    })
    .select()
    .single();

  if (error) {
    console.error('[Dispatch] Error creating dispatch record:', error);
    throw new AppError('Failed to create dispatch record', 500);
  }

  console.log(`[Dispatch] Created dispatch record: ${data.dispatch_id} for request ${requestId}, ambulance ${ambulanceId}`);

  return data;
};

/**
 * Update dispatch with hospital assignment
 *
 * @param {string} dispatchId - Dispatch ID
 * @param {number} hospitalId - Hospital ID
 * @returns {Promise<Object>} Updated dispatch record
 */
const assignHospitalToDispatch = async (dispatchId, hospitalId) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .update({
      hospital_id: hospitalId,
      hospital_status: 'assigned'
    })
    .eq('dispatch_id', dispatchId)
    .select()
    .single();

  if (error) {
    console.error('[Dispatch] Error updating dispatch with hospital:', error);
    throw new AppError('Failed to assign hospital to dispatch', 500);
  }

  console.log(`[Dispatch] Updated dispatch ${dispatchId} with hospital ${hospitalId}`);

  return data;
};

/**
 * Update dispatch with stabilization center
 *
 * @param {string} dispatchId - Dispatch ID
 * @param {number} centerId - Stabilization center ID
 * @returns {Promise<Object>} Updated dispatch record
 */
const assignCenterToDispatch = async (dispatchId, centerId) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .update({
      center_id: centerId,
      facility_type: 'stabilization_center'
    })
    .eq('dispatch_id', dispatchId)
    .select()
    .single();

  if (error) {
    console.error('[Dispatch] Error updating dispatch with center:', error);
    throw new AppError('Failed to assign center to dispatch', 500);
  }

  console.log(`[Dispatch] Updated dispatch ${dispatchId} with center ${centerId}`);

  return data;
};

/**
 * Update patient status in dispatch record
 *
 * @param {string} dispatchId - Dispatch ID
 * @param {string} patientStatus - Patient status
 * @returns {Promise<Object>} Updated dispatch record
 */
const updatePatientStatus = async (dispatchId, patientStatus) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .update({ patient_status: patientStatus })
    .eq('dispatch_id', dispatchId)
    .select()
    .single();

  if (error) {
    console.error('[Dispatch] Error updating patient status:', error);
    throw new AppError('Failed to update patient status', 500);
  }

  return data;
};

/**
 * Get dispatch record by request ID
 *
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object|null>} Dispatch record
 */
const getDispatchByRequest = async (requestId) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .select('*')
    .eq('request_id', requestId)
    .single();

  if (error && error.code !== 'PGRST116') { // PGRST116 = no rows found
    console.error('[Dispatch] Error fetching dispatch:', error);
    throw new AppError('Failed to fetch dispatch record', 500);
  }

  return data || null;
};

/**
 * Get dispatch by ID
 *
 * @param {string} dispatchId - Dispatch ID
 * @returns {Promise<Object|null>} Dispatch record
 */
const getDispatchById = async (dispatchId) => {
  const { data, error } = await supabase
    .from('emergency_dispatch')
    .select('*')
    .eq('dispatch_id', dispatchId)
    .single();

  if (error) {
    console.error('[Dispatch] Error fetching dispatch by ID:', error);
    throw new AppError('Failed to fetch dispatch', 500);
  }

  return data;
};

module.exports = {
  createDispatch,
  assignHospitalToDispatch,
  assignCenterToDispatch,
  updatePatientStatus,
  getDispatchByRequest,
  getDispatchById
};
