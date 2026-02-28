/**
 * Distance Calculator Utility
 * 
 * Implements the Haversine formula to calculate the great-circle distance
 * between two points on Earth given their latitude and longitude.
 */

const { EARTH_RADIUS_KM } = require('../config/constants');

/**
 * Convert degrees to radians
 * @param {number} degrees - Angle in degrees
 * @returns {number} Angle in radians
 */
const toRadians = (degrees) => {
  return degrees * (Math.PI / 180);
};

/**
 * Calculate distance between two geographic coordinates using Haversine formula
 * 
 * @param {number} lat1 - Latitude of first point
 * @param {number} lng1 - Longitude of first point
 * @param {number} lat2 - Latitude of second point
 * @param {number} lng2 - Longitude of second point
 * @returns {number} Distance in kilometers
 */
const calculateDistance = (lat1, lng1, lat2, lng2) => {
  // Validate inputs
  if (!isValidCoordinate(lat1, lng1) || !isValidCoordinate(lat2, lng2)) {
    throw new Error('Invalid coordinates provided');
  }

  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);

  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return EARTH_RADIUS_KM * c;
};

/**
 * Validate geographic coordinates
 * 
 * @param {number} lat - Latitude (-90 to 90)
 * @param {number} lng - Longitude (-180 to 180)
 * @returns {boolean} True if coordinates are valid
 */
const isValidCoordinate = (lat, lng) => {
  return (
    typeof lat === 'number' &&
    typeof lng === 'number' &&
    !isNaN(lat) &&
    !isNaN(lng) &&
    lat >= -90 &&
    lat <= 90 &&
    lng >= -180 &&
    lng <= 180
  );
};

/**
 * Sort an array of locations by distance from a reference point
 * 
 * @param {Array} locations - Array of objects with latitude and longitude
 * @param {number} refLat - Reference point latitude
 * @param {number} refLng - Reference point longitude
 * @param {string} latKey - Key name for latitude in location objects
 * @param {string} lngKey - Key name for longitude in location objects
 * @returns {Array} Sorted array with distance property added
 */
const sortByDistance = (locations, refLat, refLng, latKey = 'latitude', lngKey = 'longitude') => {
  return locations
    .map(location => ({
      ...location,
      distance: calculateDistance(
        refLat,
        refLng,
        location[latKey],
        location[lngKey]
      )
    }))
    .sort((a, b) => a.distance - b.distance);
};

/**
 * Find the nearest location from an array
 * 
 * @param {Array} locations - Array of location objects
 * @param {number} refLat - Reference point latitude
 * @param {number} refLng - Reference point longitude
 * @param {string} latKey - Key name for latitude
 * @param {string} lngKey - Key name for longitude
 * @returns {Object|null} Nearest location with distance, or null if empty array
 */
const findNearest = (locations, refLat, refLng, latKey = 'latitude', lngKey = 'longitude') => {
  if (!locations || locations.length === 0) {
    return null;
  }

  const sorted = sortByDistance(locations, refLat, refLng, latKey, lngKey);
  return sorted[0];
};

module.exports = {
  calculateDistance,
  isValidCoordinate,
  sortByDistance,
  findNearest,
  toRadians
};
