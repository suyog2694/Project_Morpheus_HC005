/**
 * Authentication Middleware
 * 
 * Validates incoming requests for authentication.
 * Ready for JWT integration.
 */

const { HTTP_STATUS, ERROR_MESSAGES } = require('../config/constants');
const { supabase } = require('../config/supabase');
const response = require('../utils/responseFormatter');

/**
 * Optional authentication - allows request through but attaches user if token present
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.split(' ')[1];
    
    // Verify token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      req.user = null;
      return next();
    }

    req.user = user;
    next();
  } catch (error) {
    req.user = null;
    next();
  }
};

/**
 * Required authentication - blocks request if not authenticated
 */
const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return response.unauthorized(res, ERROR_MESSAGES.UNAUTHORIZED_ACCESS);
    }

    const token = authHeader.split(' ')[1];

    // Verify token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return response.unauthorized(res, ERROR_MESSAGES.UNAUTHORIZED_ACCESS);
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error.message);
    return response.unauthorized(res, ERROR_MESSAGES.UNAUTHORIZED_ACCESS);
  }
};

/**
 * Validate ambulance identity
 * Checks if the ambulance ID in the route params matches an existing ambulance
 */
const validateAmbulance = async (req, res, next) => {
  try {
    const ambulanceId = req.params.ambulanceId || req.body.ambulanceId;

    if (!ambulanceId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_AMBULANCE_ID);
    }

    const { data: ambulance, error } = await supabase
      .from('ambulances')
      .select('*')
      .eq('ambulance_id', ambulanceId)
      .single();

    if (error || !ambulance) {
      return response.notFound(res, ERROR_MESSAGES.AMBULANCE_NOT_FOUND);
    }

    req.ambulance = ambulance;
    next();
  } catch (error) {
    console.error('Ambulance validation error:', error.message);
    return response.error(res, 'Failed to validate ambulance');
  }
};

/**
 * Validate hospital identity
 * Checks if the hospital ID matches an existing hospital
 */
const validateHospital = async (req, res, next) => {
  try {
    const hospitalId = req.params.hospitalId || req.body.hospitalId;

    if (!hospitalId) {
      return response.badRequest(res, ERROR_MESSAGES.INVALID_HOSPITAL_ID);
    }

    const { data: hospital, error } = await supabase
      .from('hospitals')
      .select('*')
      .eq('hospital_id', hospitalId)
      .single();

    if (error || !hospital) {
      return response.notFound(res, ERROR_MESSAGES.HOSPITAL_NOT_FOUND);
    }

    req.hospital = hospital;
    next();
  } catch (error) {
    console.error('Hospital validation error:', error.message);
    return response.error(res, 'Failed to validate hospital');
  }
};

module.exports = {
  optionalAuth,
  requireAuth,
  validateAmbulance,
  validateHospital
};
