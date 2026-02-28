/**
 * Ambulance Service
 * 
 * Handles ambulance assignment, availability management,
 * and location-based matching.
 */

const { supabase } = require('../config/supabase');
const { AMBULANCE_STATUS, EMERGENCY_STATUS, ERROR_MESSAGES } = require('../config/constants');
const { sortByDistance, findNearest } = require('../utils/distanceCalculator');
const { AppError } = require('../middlewares/errorHandler');

/**
 * Find and assign the nearest available ambulance
 * Uses optimistic locking to prevent race conditions
 * 
 * @param {number} patientLat - Patient latitude
 * @param {number} patientLng - Patient longitude
 * @param {Array} excludeIds - Ambulance IDs to exclude (previously rejected)
 * @returns {Promise<Object|null>} Assigned ambulance or null
 */
const findAndAssignNearestAmbulance = async (patientLat, patientLng, excludeIds = []) => {
  // Fetch all available ambulances
  let query = supabase
    .from('ambulances')
    .select('*')
    .eq('status', AMBULANCE_STATUS.AVAILABLE);

  // Exclude previously rejected ambulances
  if (excludeIds.length > 0) {
    query = query.not('ambulance_id', 'in', `(${excludeIds.join(',')})`);
  }

  const { data: ambulances, error } = await query;

  if (error) {
    console.error('Error fetching ambulances:', error);
    throw new AppError('Failed to fetch ambulances', 500);
  }

  if (!ambulances || ambulances.length === 0) {
    return null;
  }

  // Sort by distance and find nearest
  const sortedAmbulances = sortByDistance(
    ambulances,
    patientLat,
    patientLng,
    'current_latitude',
    'current_longitude'
  );

  // Try to assign ambulances in order of distance
  for (const ambulance of sortedAmbulances) {
    const assigned = await tryAssignAmbulance(ambulance.ambulance_id);
    if (assigned) {
      return {
        ...ambulance,
        distance: ambulance.distance
      };
    }
  }

  return null;
};

/**
 * Try to assign an ambulance using optimistic locking
 * Prevents race conditions when multiple requests try to assign the same ambulance
 * 
 * @param {string} ambulanceId - Ambulance ID to assign
 * @returns {Promise<boolean>} True if assignment successful
 */
const tryAssignAmbulance = async (ambulanceId) => {
  // Use update with WHERE clause for atomic operation
  const { data, error } = await supabase
    .from('ambulances')
    .update({ status: AMBULANCE_STATUS.BUSY })
    .eq('ambulance_id', ambulanceId)
    .eq('status', AMBULANCE_STATUS.AVAILABLE) // Only update if still available
    .select();

  if (error) {
    console.error(`Supabase error assigning ambulance ${ambulanceId}:`, error.message || error);
    return false;
  }

  if (!data || data.length === 0) {
    console.log(`Ambulance ${ambulanceId} already assigned, trying next`);
    return false;
  }

  return true;
};

/**
 * Release an ambulance (mark as available)
 * 
 * @param {string} ambulanceId - Ambulance ID
 * @returns {Promise<Object>} Updated ambulance
 */
const releaseAmbulance = async (ambulanceId) => {
  const { data, error } = await supabase
    .from('ambulances')
    .update({ status: AMBULANCE_STATUS.AVAILABLE })
    .eq('ambulance_id', ambulanceId)
    .select()
    .single();

  if (error) {
    console.error('Error releasing ambulance:', error);
    throw new AppError('Failed to release ambulance', 500);
  }

  return data;
};

/**
 * Release ALL ambulances – reset every row back to Available.
 * Useful when ambulances get stuck in Busy from incomplete test runs.
 *
 * @returns {Promise<number>} Number of ambulances released
 */
const releaseAllAmbulances = async () => {
  const { data, error } = await supabase
    .from('ambulances')
    .update({ status: AMBULANCE_STATUS.AVAILABLE })
    .eq('status', AMBULANCE_STATUS.BUSY)
    .select();

  if (error) {
    console.error('Error releasing all ambulances:', error);
    throw new AppError('Failed to release ambulances', 500);
  }

  return (data && data.length) || 0;
};

/**
 * Get ambulance by ID
 * 
 * @param {string} ambulanceId - Ambulance ID
 * @returns {Promise<Object>} Ambulance data
 */
const getAmbulanceById = async (ambulanceId) => {
  const { data, error } = await supabase
    .from('ambulances')
    .select('*')
    .eq('ambulance_id', ambulanceId)
    .single();

  if (error || !data) {
    throw new AppError(ERROR_MESSAGES.AMBULANCE_NOT_FOUND, 404);
  }

  return data;
};

/**
 * Get ambulance by vehicle number (plate)
 * 
 * @param {string} ambulanceNo - Ambulance plate number (e.g. MH14HG3043)
 * @returns {Promise<Object|null>} Ambulance data or null
 */
const getAmbulanceByNo = async (ambulanceNo) => {
  const { data, error } = await supabase
    .from('ambulances')
    .select('*')
    .eq('ambulance_no', ambulanceNo)
    .single();

  if (error || !data) {
    return null;
  }

  return data;
};

/**
 * Update ambulance location
 * 
 * @param {string} ambulanceId - Ambulance ID
 * @param {number} latitude - New latitude
 * @param {number} longitude - New longitude
 * @returns {Promise<Object>} Updated ambulance
 */
const updateAmbulanceLocation = async (ambulanceId, latitude, longitude) => {
  const { data, error } = await supabase
    .from('ambulances')
    .update({
      current_latitude: latitude,
      current_longitude: longitude,
      location_updated_at: new Date().toISOString()
    })
    .eq('ambulance_id', ambulanceId)
    .select()
    .single();

  if (error) {
    console.error('Error updating ambulance location:', error);
    throw new AppError('Failed to update ambulance location', 500);
  }

  return data;
};

/**
 * Get all ambulances with optional status filter
 * 
 * @param {string} status - Optional status filter
 * @returns {Promise<Array>} List of ambulances
 */
const getAllAmbulances = async (status = null) => {
  let query = supabase
    .from('ambulances')
    .select('*');

  if (status) {
    query = query.eq('status', status);
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error fetching ambulances:', error);
    throw new AppError('Failed to fetch ambulances', 500);
  }

  return data || [];
};

/**
 * Get available ambulances count
 * 
 * @returns {Promise<number>} Count of available ambulances
 */
const getAvailableCount = async () => {
  const { count, error } = await supabase
    .from('ambulances')
    .select('*', { count: 'exact', head: true })
    .eq('status', AMBULANCE_STATUS.AVAILABLE);

  if (error) {
    console.error('Error counting available ambulances:', error);
    return 0;
  }

  return count || 0;
};

/**
 * Register a new ambulance crew
 * Inserts a row into the ambulances table and returns it.
 *
 * @param {string} driverName  - Paramedic / driver full name
 * @param {string} ambulanceNo - Vehicle plate number (e.g. KA-01-HC-005)
 * @param {string} driverPhone - Contact phone number
 * @returns {Promise<Object>} Created ambulance record
 */
const registerAmbulance = async (driverName, ambulanceNo, driverPhone) => {
  // Check if plate already registered
  const existing = await getAmbulanceByNo(ambulanceNo);
  if (existing) {
    throw new AppError('An ambulance with this plate number is already registered', 409);
  }

  const { data, error } = await supabase
    .from('ambulances')
    .insert({
      driver_name: driverName,
      ambulance_no: ambulanceNo,
      contact_number: driverPhone,
      status: AMBULANCE_STATUS.AVAILABLE
    })
    .select()
    .single();

  if (error) {
    console.error('Error registering ambulance:', error);
    throw new AppError('Failed to register ambulance', 500);
  }

  return data;
};

/**
 * Login an ambulance by plate number + phone
 *
 * @param {string} ambulanceNo - Vehicle plate number
 * @param {string} driverPhone - Contact phone number
 * @returns {Promise<Object|null>} Ambulance record or null
 */
const loginAmbulance = async (ambulanceNo, driverPhone) => {
  const { data, error } = await supabase
    .from('ambulances')
    .select('*')
    .eq('ambulance_no', ambulanceNo)
    .eq('contact_number', driverPhone)
    .single();

  if (error || !data) {
    return null;
  }

  return data;
};

module.exports = {
  findAndAssignNearestAmbulance,
  tryAssignAmbulance,
  releaseAmbulance,
  releaseAllAmbulances,
  getAmbulanceById,
  getAmbulanceByNo,
  updateAmbulanceLocation,
  getAllAmbulances,
  getAvailableCount,
  registerAmbulance,
  loginAmbulance
};
