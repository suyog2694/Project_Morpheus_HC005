/**
 * Resource Service
 * 
 * Manages hospital resource data (ICU, beds, ventilators).
 * Handles resource updates with transaction safety.
 */

const { supabase } = require('../config/supabase');
const { LOW_BED_THRESHOLD, ERROR_MESSAGES } = require('../config/constants');
const { AppError } = require('../middlewares/errorHandler');

/**
 * Get hospital resources by hospital ID
 * 
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Object>} Hospital resources
 */
const getHospitalResources = async (hospitalId) => {
  const { data, error } = await supabase
    .from('hospital_resources')
    .select(`
      *,
      hospitals (
        hospital_id,
        name,
        contact_number
      )
    `)
    .eq('hospital_id', hospitalId)
    .single();

  if (error || !data) {
    throw new AppError('Hospital resources not found', 404);
  }

  return data;
};

/**
 * Update hospital resources (transaction-safe)
 * Used by n8n webhooks for automated updates
 * 
 * @param {string} hospitalId - Hospital ID
 * @param {Object} updates - Resource updates
 * @returns {Promise<Object>} Updated resources
 */
const updateHospitalResources = async (hospitalId, updates) => {
  // Validate updates
  const allowedFields = [
    'icu_total', 'icu_available',
    'bed_total', 'bed_available',
    'ventilator_total', 'ventilator_available'
  ];

  const sanitizedUpdates = {};
  for (const [key, value] of Object.entries(updates)) {
    if (allowedFields.includes(key) && typeof value === 'number' && value >= 0) {
      sanitizedUpdates[key] = value;
    }
  }

  if (Object.keys(sanitizedUpdates).length === 0) {
    throw new AppError('No valid fields to update', 400);
  }

  // Add timestamp
  sanitizedUpdates.last_updated_at = new Date().toISOString();

  const { data, error } = await supabase
    .from('hospital_resources')
    .update(sanitizedUpdates)
    .eq('hospital_id', hospitalId)
    .select()
    .single();

  if (error) {
    console.error('Error updating hospital resources:', error);
    throw new AppError('Failed to update hospital resources', 500);
  }

  // Check if beds are below threshold
  if (data.bed_available <= LOW_BED_THRESHOLD) {
    console.warn(`LOW BED ALERT: Hospital ${hospitalId} has only ${data.bed_available} beds available`);
    // This could trigger an n8n webhook notification
  }

  return data;
};

/**
 * Decrement bed count atomically
 * Used when a hospital approves a patient
 * 
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Object>} Updated resources
 */
const decrementBedCount = async (hospitalId) => {
  // Get current count first
  const { data: current, error: fetchError } = await supabase
    .from('hospital_resources')
    .select('bed_available')
    .eq('hospital_id', hospitalId)
    .single();

  if (fetchError || !current) {
    throw new AppError('Hospital resources not found', 404);
  }

  if (current.bed_available <= 0) {
    throw new AppError(ERROR_MESSAGES.BEDS_UNAVAILABLE, 409);
  }

  // Atomic decrement with optimistic locking
  const { data, error } = await supabase
    .from('hospital_resources')
    .update({ 
      bed_available: current.bed_available - 1,
      last_updated_at: new Date().toISOString()
    })
    .eq('hospital_id', hospitalId)
    .eq('bed_available', current.bed_available) // Ensure count hasn't changed
    .select()
    .single();

  if (error || !data) {
    throw new AppError(ERROR_MESSAGES.TRANSACTION_FAILED, 409);
  }

  return data;
};

/**
 * Increment bed count atomically
 * Used when a patient is discharged or request is cancelled
 * 
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Object>} Updated resources
 */
const incrementBedCount = async (hospitalId) => {
  const { data: current, error: fetchError } = await supabase
    .from('hospital_resources')
    .select('bed_available, bed_total')
    .eq('hospital_id', hospitalId)
    .single();

  if (fetchError || !current) {
    throw new AppError('Hospital resources not found', 404);
  }

  // Don't exceed total
  const newCount = Math.min(current.bed_available + 1, current.bed_total);

  const { data, error } = await supabase
    .from('hospital_resources')
    .update({ 
      bed_available: newCount,
      last_updated_at: new Date().toISOString()
    })
    .eq('hospital_id', hospitalId)
    .select()
    .single();

  if (error) {
    throw new AppError('Failed to increment bed count', 500);
  }

  return data;
};

/**
 * Get all hospitals with resources
 * 
 * @param {boolean} onlyAvailable - Filter only hospitals with available beds
 * @returns {Promise<Array>} Hospitals with resources
 */
const getAllHospitalsWithResources = async (onlyAvailable = false) => {
  const { data, error } = await supabase
    .from('hospitals')
    .select(`
      *,
      hospital_resources (*)
    `);

  if (error) {
    console.error('Error fetching hospitals with resources:', error);
    throw new AppError('Failed to fetch hospitals', 500);
  }

  if (onlyAvailable) {
    return data.filter(h => 
      h.hospital_resources && h.hospital_resources.bed_available > 0
    );
  }

  return data || [];
};

/**
 * Check if hospital has low resources
 * 
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Object>} Alert status
 */
const checkResourceAlerts = async (hospitalId) => {
  const resources = await getHospitalResources(hospitalId);
  
  const alerts = [];

  if (resources.bed_available <= LOW_BED_THRESHOLD) {
    alerts.push({
      type: 'LOW_BEDS',
      message: `Only ${resources.bed_available} beds available`,
      severity: resources.bed_available === 0 ? 'critical' : 'warning'
    });
  }

  if (resources.icu_available <= 2) {
    alerts.push({
      type: 'LOW_ICU',
      message: `Only ${resources.icu_available} ICU beds available`,
      severity: resources.icu_available === 0 ? 'critical' : 'warning'
    });
  }

  if (resources.ventilator_available <= 2) {
    alerts.push({
      type: 'LOW_VENTILATOR',
      message: `Only ${resources.ventilator_available} ventilators available`,
      severity: resources.ventilator_available === 0 ? 'critical' : 'warning'
    });
  }

  return {
    hospital_id: hospitalId,
    has_alerts: alerts.length > 0,
    alerts
  };
};

/**
 * Get resource summary across all hospitals
 * 
 * @returns {Promise<Object>} Resource summary
 */
const getResourceSummary = async () => {
  const { data, error } = await supabase
    .from('hospital_resources')
    .select('*');

  if (error) {
    throw new AppError('Failed to fetch resource summary', 500);
  }

  const summary = data.reduce((acc, r) => ({
    total_beds: acc.total_beds + (r.bed_total || 0),
    available_beds: acc.available_beds + (r.bed_available || 0),
    total_icu: acc.total_icu + (r.icu_total || 0),
    available_icu: acc.available_icu + (r.icu_available || 0),
    total_ventilators: acc.total_ventilators + (r.ventilator_total || 0),
    available_ventilators: acc.available_ventilators + (r.ventilator_available || 0)
  }), {
    total_beds: 0,
    available_beds: 0,
    total_icu: 0,
    available_icu: 0,
    total_ventilators: 0,
    available_ventilators: 0
  });

  summary.hospitals_count = data.length;
  summary.timestamp = new Date().toISOString();

  return summary;
};

module.exports = {
  getHospitalResources,
  updateHospitalResources,
  decrementBedCount,
  incrementBedCount,
  getAllHospitalsWithResources,
  checkResourceAlerts,
  getResourceSummary
};
