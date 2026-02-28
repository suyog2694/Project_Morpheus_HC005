/**
 * Application Constants
 * 
 * Centralized configuration values for the emergency coordination system.
 */

// Emergency Request Status Values
const EMERGENCY_STATUS = {
  SEARCHING_AMBULANCE: 'searching_ambulance',
  AMBULANCE_ASSIGNED: 'ambulance_assigned',
  SEARCHING_HOSPITAL: 'searching_hospital',
  HOSPITAL_APPROVED: 'hospital_approved',
  ROUTED_TO_STABILIZATION: 'routed_to_stabilization',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled'
};

// Hospital Request Status Values
const HOSPITAL_REQUEST_STATUS = {
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
  EXPIRED: 'expired'
};

// Ambulance Status Values
const AMBULANCE_STATUS = {
  AVAILABLE: 'Available',
  BUSY: 'Busy'
};

// HTTP Status Codes
const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503
};

// Error Messages
const ERROR_MESSAGES = {
  NO_AMBULANCE_AVAILABLE: 'No ambulances available at this time',
  NO_HOSPITAL_AVAILABLE: 'No hospitals with available beds found',
  INVALID_REQUEST_ID: 'Invalid or missing request ID',
  INVALID_AMBULANCE_ID: 'Invalid or missing ambulance ID',
  INVALID_HOSPITAL_ID: 'Invalid or missing hospital ID',
  INVALID_DECISION: 'Invalid decision value. Must be approve or reject',
  EMERGENCY_NOT_FOUND: 'Emergency request not found',
  AMBULANCE_NOT_FOUND: 'Ambulance not found',
  HOSPITAL_NOT_FOUND: 'Hospital not found',
  HOSPITAL_REQUEST_NOT_FOUND: 'Hospital request not found',
  BEDS_UNAVAILABLE: 'No beds available at this hospital',
  REQUEST_ALREADY_PROCESSED: 'This request has already been processed',
  UNAUTHORIZED_ACCESS: 'Unauthorized access',
  INVALID_API_KEY: 'Invalid or missing API key',
  TRANSACTION_FAILED: 'Transaction failed. Please try again',
  RACE_CONDITION: 'Another hospital has already been approved for this request'
};

// Haversine Formula Constants
const EARTH_RADIUS_KM = 6371;

// Resource Types
const RESOURCE_TYPES = {
  ICU: 'icu',
  BED: 'bed',
  VENTILATOR: 'ventilator'
};

// Bed Alert Threshold (can be overridden by env)
const LOW_BED_THRESHOLD = parseInt(process.env.LOW_BED_THRESHOLD) || 5;

module.exports = {
  EMERGENCY_STATUS,
  HOSPITAL_REQUEST_STATUS,
  AMBULANCE_STATUS,
  HTTP_STATUS,
  ERROR_MESSAGES,
  EARTH_RADIUS_KM,
  RESOURCE_TYPES,
  LOW_BED_THRESHOLD
};
