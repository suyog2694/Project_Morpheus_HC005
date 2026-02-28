/**
 * Stabilization Service
 * 
 * Handles fallback routing to stabilization centers
 * when no hospital beds are available.
 */

const { supabase } = require('../config/supabase');
const { EMERGENCY_STATUS, ERROR_MESSAGES } = require('../config/constants');
const { findNearest, sortByDistance } = require('../utils/distanceCalculator');
const { AppError } = require('../middlewares/errorHandler');

/**
 * Find and assign the nearest stabilization center
 * 
 * @param {string} requestId - Emergency request ID
 * @param {number} patientLat - Patient latitude
 * @param {number} patientLng - Patient longitude
 * @returns {Promise<Object>} Stabilization assignment result
 */
const findNearestStabilizationCenter = async (requestId, patientLat, patientLng) => {
  // Fetch all stabilization centers
  const { data: centers, error } = await supabase
    .from('stabilization_centers')
    .select('*');

  if (error) {
    console.error('Error fetching stabilization centers:', error);
    throw new AppError('Failed to fetch stabilization centers', 500);
  }

  if (!centers || centers.length === 0) {
    console.error('No stabilization centers configured in the system');
    throw new AppError('No stabilization centers available', 503);
  }

  // Find the nearest stabilization center
  const nearestCenter = findNearest(
    centers,
    patientLat,
    patientLng,
    'latitude',
    'longitude'
  );

  // Update emergency request with stabilization center assignment
  const { data: updatedRequest, error: updateError } = await supabase
    .from('emergency_requests')
    .update({
      status: EMERGENCY_STATUS.ROUTED_TO_STABILIZATION,
      stabilization_center_id: nearestCenter.center_id
    })
    .eq('request_id', requestId)
    .select()
    .single();

  if (updateError) {
    console.error('Error updating emergency request:', updateError);
    throw new AppError('Failed to route to stabilization center', 500);
  }

  console.log(`Request ${requestId} routed to stabilization center ${nearestCenter.center_id}`);

  return {
    success: true,
    message: 'Routed to stabilization center',
    is_stabilization: true,
    stabilization_center: {
      id: nearestCenter.center_id,
      name: nearestCenter.name,
      latitude: nearestCenter.latitude,
      longitude: nearestCenter.longitude,
      contact_number: nearestCenter.contact_number,
      distance: nearestCenter.distance
    }
  };
};

/**
 * Get all stabilization centers
 * 
 * @returns {Promise<Array>} List of stabilization centers
 */
const getAllStabilizationCenters = async () => {
  const { data, error } = await supabase
    .from('stabilization_centers')
    .select('*')
    .order('name');

  if (error) {
    console.error('Error fetching stabilization centers:', error);
    throw new AppError('Failed to fetch stabilization centers', 500);
  }

  return data || [];
};

/**
 * Get stabilization center by ID
 * 
 * @param {string} centerId - Stabilization center ID
 * @returns {Promise<Object>} Stabilization center data
 */
const getStabilizationCenterById = async (centerId) => {
  const { data, error } = await supabase
    .from('stabilization_centers')
    .select('*')
    .eq('center_id', centerId)
    .single();

  if (error || !data) {
    throw new AppError('Stabilization center not found', 404);
  }

  return data;
};

/**
 * Get stabilization centers sorted by distance from a point
 * 
 * @param {number} lat - Reference latitude
 * @param {number} lng - Reference longitude
 * @returns {Promise<Array>} Sorted stabilization centers
 */
const getCentersByDistance = async (lat, lng) => {
  const centers = await getAllStabilizationCenters();
  
  return sortByDistance(centers, lat, lng, 'latitude', 'longitude');
};

module.exports = {
  findNearestStabilizationCenter,
  getAllStabilizationCenters,
  getStabilizationCenterById,
  getCentersByDistance
};
