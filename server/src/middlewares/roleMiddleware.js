/**
 * Role-Based Access Control Middleware
 * 
 * Restricts access to routes based on user roles.
 */

const { HTTP_STATUS, ERROR_MESSAGES } = require('../config/constants');
const response = require('../utils/responseFormatter');

/**
 * User roles in the system
 */
const ROLES = {
  PATIENT: 'patient',
  AMBULANCE: 'ambulance',
  HOSPITAL: 'hospital',
  ADMIN: 'admin',
  N8N: 'n8n'
};

/**
 * Check if user has one of the allowed roles
 * 
 * @param {...string} allowedRoles - Roles that are allowed access
 * @returns {Function} Middleware function
 */
const hasRole = (...allowedRoles) => {
  return (req, res, next) => {
    // If no auth is present, deny access
    if (!req.user) {
      return response.unauthorized(res, ERROR_MESSAGES.UNAUTHORIZED_ACCESS);
    }

    // Get role from user metadata or default to patient
    const userRole = req.user.user_metadata?.role || ROLES.PATIENT;

    // Check if user's role is in the allowed roles
    if (!allowedRoles.includes(userRole)) {
      return response.forbidden(res, `Access denied. Required role: ${allowedRoles.join(' or ')}`);
    }

    next();
  };
};

/**
 * Allow only patients
 */
const patientOnly = hasRole(ROLES.PATIENT);

/**
 * Allow only ambulance personnel
 */
const ambulanceOnly = hasRole(ROLES.AMBULANCE);

/**
 * Allow only hospital staff
 */
const hospitalOnly = hasRole(ROLES.HOSPITAL);

/**
 * Allow only admins
 */
const adminOnly = hasRole(ROLES.ADMIN);

/**
 * Allow patients and ambulance
 */
const patientOrAmbulance = hasRole(ROLES.PATIENT, ROLES.AMBULANCE);

/**
 * Allow ambulance and hospital
 */
const ambulanceOrHospital = hasRole(ROLES.AMBULANCE, ROLES.HOSPITAL);

/**
 * Allow all authenticated users
 */
const anyAuthenticated = (req, res, next) => {
  if (!req.user) {
    return response.unauthorized(res, ERROR_MESSAGES.UNAUTHORIZED_ACCESS);
  }
  next();
};

module.exports = {
  ROLES,
  hasRole,
  patientOnly,
  ambulanceOnly,
  hospitalOnly,
  adminOnly,
  patientOrAmbulance,
  ambulanceOrHospital,
  anyAuthenticated
};
