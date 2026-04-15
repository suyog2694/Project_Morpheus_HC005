/**
 * Hospital Matcher Service
 *
 * Core service for hospital matching, approval flow, and
 * transaction-safe bed allocation. Handles race conditions
 * when multiple hospitals respond simultaneously.
 */

const { supabase } = require('../config/supabase');
const {
  EMERGENCY_STATUS,
  HOSPITAL_REQUEST_STATUS,
  ERROR_MESSAGES,
  HTTP_STATUS
} = require('../config/constants');
const { sortByDistance } = require('../utils/distanceCalculator');
const { AppError } = require('../middlewares/errorHandler');
const stabilizationService = require('./stabilizationService');
const { emitHospitalNewRequest, emitAmbulanceHospitalAssignment, emitRequestUpdate } = require('../socket/socketManager');

/**
 * Match and notify hospitals for an emergency request
 * Creates hospital_requests for all eligible hospitals sorted by distance
 *
 * @param {string} requestId - Emergency request ID
 * @param {number} patientLat - Patient latitude
 * @param {number} patientLng - Patient longitude
 * @param {string} description - Patient's initial description
 * @param {string} severity - Extracted severity (optional)
 * @returns {Promise<Object>} Matching result
 */
const matchHospitals = async (requestId, patientLat, patientLng, description = '', severity = 'medium') => {
  console.log(`[HospitalMatcher] Finding hospitals for request ${requestId} at (${patientLat}, ${patientLng})`);

  // Fetch hospitals with available beds
  const { data: hospitalsWithResources, error: fetchError } = await supabase
    .from('hospitals')
    .select(`
      *,
      hospital_resources (
        icu_available,
        bed_available,
        ventilator_available,
        last_updated_at
      )
    `);

  if (fetchError) {
    console.error('[HospitalMatcher] Error fetching hospitals:', fetchError);
    throw new AppError('Failed to fetch hospitals', 500);
  }

  // Filter hospitals with available beds
  const eligibleHospitals = hospitalsWithResources.filter(hospital => {
    const resources = hospital.hospital_resources;
    return resources && resources.bed_available > 0;
  });

  if (eligibleHospitals.length === 0) {
    console.log(`[HospitalMatcher] No hospitals with available beds for request ${requestId}`);
    // Trigger stabilization fallback
    return await stabilizationService.findNearestStabilizationCenter(
      requestId,
      patientLat,
      patientLng
    );
  }

  // Sort hospitals by distance
  const sortedHospitals = sortByDistance(
    eligibleHospitals,
    patientLat,
    patientLng,
    'latitude',
    'longitude'
  );

  console.log(`[HospitalMatcher] Found ${sortedHospitals.length} eligible hospitals for request ${requestId}`);

  // Create hospital_requests for all eligible hospitals
  const hospitalRequests = sortedHospitals.map((hospital, index) => ({
    request_id: requestId,
    hospital_id: hospital.hospital_id,
    status: HOSPITAL_REQUEST_STATUS.PENDING,
    priority_order: index + 1,
    requested_at: new Date().toISOString(),
    distance_km: hospital.distance
  }));

  const { error: insertError } = await supabase
    .from('hospital_requests')
    .insert(hospitalRequests);

  if (insertError) {
    console.error('[HospitalMatcher] Error creating hospital requests:', insertError);
    throw new AppError('Failed to create hospital requests', 500);
  }

  // Update emergency request status
  await supabase
    .from('emergency_requests')
    .update({ status: EMERGENCY_STATUS.SEARCHING_HOSPITAL })
    .eq('request_id', requestId);

  console.log(`[HospitalMatcher] Created ${hospitalRequests.length} hospital requests for request ${requestId}`);

  // Emit Socket.IO events to each hospital
  sortedHospitals.forEach((hospital, index) => {
    const requestData = {
      request_id: requestId,
      patient_latitude: patientLat,
      patient_longitude: patientLng,
      description: description,
      severity: severity,
      medical_keywords: [],
      distance_km: hospital.distance,
      priority_order: index + 1
    };

    emitHospitalNewRequest(hospital.hospital_id, requestData);
    console.log(`[HospitalMatcher] Notified hospital ${hospital.hospital_id} via Socket.IO`);
  });

  return {
    success: true,
    message: 'Hospital matching initiated',
    hospitals_contacted: hospitalRequests.length,
    first_hospital: sortedHospitals[0]
  };
};

/**
 * Process hospital approval with transaction-safe bed decrement
 * Prevents race conditions when multiple hospitals try to approve simultaneously
 * 
 * @param {string} hospitalRequestId - Hospital request ID
 * @param {string} hospitalId - Hospital ID
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object>} Approval result
 */
const processHospitalApproval = async (hospitalRequestId, hospitalId, requestId) => {
  // Start a transaction-like operation
  // Step 1: Check if any hospital has already been approved for this request
  const { data: existingApproval, error: checkError } = await supabase
    .from('hospital_requests')
    .select('*')
    .eq('request_id', requestId)
    .eq('status', HOSPITAL_REQUEST_STATUS.APPROVED)
    .single();

  if (existingApproval) {
    throw new AppError(ERROR_MESSAGES.RACE_CONDITION, HTTP_STATUS.CONFLICT);
  }

  // Step 2: Check current bed availability
  const { data: resources, error: resourceError } = await supabase
    .from('hospital_resources')
    .select('*')
    .eq('hospital_id', hospitalId)
    .single();

  if (resourceError || !resources) {
    throw new AppError('Hospital resources not found', 404);
  }

  if (resources.bed_available <= 0) {
    throw new AppError(ERROR_MESSAGES.BEDS_UNAVAILABLE, HTTP_STATUS.CONFLICT);
  }

  // Step 3: Atomically decrement bed count and approve
  // Using a conditional update to prevent race conditions
  const { data: updatedResources, error: decrementError } = await supabase
    .from('hospital_resources')
    .update({ 
      bed_available: resources.bed_available - 1,
      last_updated_at: new Date().toISOString()
    })
    .eq('hospital_id', hospitalId)
    .eq('bed_available', resources.bed_available) // Optimistic lock
    .select()
    .single();

  if (decrementError || !updatedResources) {
    // Another request modified the bed count - potential race condition
    throw new AppError(ERROR_MESSAGES.TRANSACTION_FAILED, HTTP_STATUS.CONFLICT);
  }

  // Step 4: Mark the hospital request as approved
  const { error: approveError } = await supabase
    .from('hospital_requests')
    .update({ 
      status: HOSPITAL_REQUEST_STATUS.APPROVED,
      responded_at: new Date().toISOString()
    })
    .eq('id', hospitalRequestId)
    .eq('status', HOSPITAL_REQUEST_STATUS.PENDING); // Only if still pending

  if (approveError) {
    // Rollback bed decrement
    await supabase
      .from('hospital_resources')
      .update({ 
        bed_available: resources.bed_available,
        last_updated_at: new Date().toISOString()
      })
      .eq('hospital_id', hospitalId);

    throw new AppError(ERROR_MESSAGES.REQUEST_ALREADY_PROCESSED, HTTP_STATUS.CONFLICT);
  }

  // Step 5: Expire all other pending hospital requests
  await supabase
    .from('hospital_requests')
    .update({ 
      status: HOSPITAL_REQUEST_STATUS.EXPIRED,
      responded_at: new Date().toISOString()
    })
    .eq('request_id', requestId)
    .eq('status', HOSPITAL_REQUEST_STATUS.PENDING);

  // Step 6: Update emergency request with hospital assignment
  await supabase
    .from('emergency_requests')
    .update({ 
      status: EMERGENCY_STATUS.HOSPITAL_APPROVED,
      hospital_id: hospitalId
    })
    .eq('request_id', requestId);

  // Fetch hospital details for response
  const { data: hospital } = await supabase
    .from('hospitals')
    .select('*')
    .eq('hospital_id', hospitalId)
    .single();

  // Fetch emergency request to get ambulance_id and patient details
  const { data: emergency } = await supabase
    .from('emergency_requests')
    .select('*, ambulances(*)')
    .eq('request_id', requestId)
    .single();

  console.log(`[HospitalMatcher] Hospital ${hospitalId} approved request ${requestId}`);

  // Notify ambulance driver about hospital assignment
  if (emergency && emergency.ambulance_id) {
    const ambulanceData = {
      request_id: requestId,
      hospital_id: hospital.hospital_id,
      hospital_name: hospital.name,
      hospital_latitude: hospital.latitude,
      hospital_longitude: hospital.longitude,
      hospital_address: hospital.address,
      hospital_contact: hospital.contact_number,
      patient_status: 'en_route_to_hospital'
    };
    emitAmbulanceHospitalAssignment(emergency.ambulance_id, ambulanceData);
    console.log(`[HospitalMatcher] Notified ambulance ${emergency.ambulance_id} of hospital assignment`);
  }

  // Notify patient about hospital assignment
  if (emergency) {
    emitRequestUpdate(requestId, {
      status: EMERGENCY_STATUS.HOSPITAL_APPROVED,
      ambulance: emergency.ambulances ? {
        ambulance_id: emergency.ambulances.ambulance_id,
        driver_name: emergency.ambulances.driver_name,
        ambulance_no: emergency.ambulances.ambulance_no
      } : null,
      hospital: {
        hospital_id: hospital.hospital_id,
        name: hospital.name,
        latitude: hospital.latitude,
        longitude: hospital.longitude,
        address: hospital.address
      }
    });
    console.log(`[HospitalMatcher] Notified patient of hospital assignment for request ${requestId}`);
  }

  return {
    success: true,
    message: 'Hospital approved successfully',
    hospital,
    bed_remaining: updatedResources.bed_available
  };
};

/**
 * Process hospital rejection and notify next hospital
 * 
 * @param {string} hospitalRequestId - Hospital request ID
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object>} Rejection result
 */
const processHospitalRejection = async (hospitalRequestId, requestId) => {
  // Mark current hospital request as rejected
  await supabase
    .from('hospital_requests')
    .update({ 
      status: HOSPITAL_REQUEST_STATUS.REJECTED,
      responded_at: new Date().toISOString()
    })
    .eq('id', hospitalRequestId);

  // Find next pending hospital request by priority
  const { data: nextHospitalRequest, error } = await supabase
    .from('hospital_requests')
    .select(`
      *,
      hospitals (*)
    `)
    .eq('request_id', requestId)
    .eq('status', HOSPITAL_REQUEST_STATUS.PENDING)
    .order('priority_order', { ascending: true })
    .limit(1)
    .single();

  if (error || !nextHospitalRequest) {
    // No more pending hospitals - trigger stabilization fallback
    console.log(`All hospitals rejected for request ${requestId}, routing to stabilization`);

    // Get emergency request location
    const { data: emergency } = await supabase
      .from('emergency_requests')
      .select('user_latitude, user_longitude')
      .eq('request_id', requestId)
      .single();

    if (emergency) {
      return await stabilizationService.findNearestStabilizationCenter(
        requestId,
        emergency.user_latitude,
        emergency.user_longitude
      );
    }

    throw new AppError('All hospitals rejected and no stabilization center available', 503);
  }

  // Notify the next hospital via Socket.IO
  const { data: emergency } = await supabase
    .from('emergency_requests')
    .select('user_latitude, user_longitude, description, severity')
    .eq('request_id', requestId)
    .single();

  if (emergency) {
    const nextHospital = nextHospitalRequest.hospitals;
    emitHospitalNewRequest(nextHospital.hospital_id, {
      request_id: requestId,
      patient_latitude: emergency.user_latitude,
      patient_longitude: emergency.user_longitude,
      description: emergency.description || '',
      severity: emergency.severity || 'medium',
      medical_keywords: [],
      distance_km: nextHospitalRequest.distance_km,
      priority_order: nextHospitalRequest.priority_order
    });
    console.log(`[HospitalMatcher] Notified next hospital ${nextHospital.hospital_id} via Socket.IO after rejection`);

    // Notify patient that next hospital is being contacted
    emitRequestUpdate(requestId, {
      status: EMERGENCY_STATUS.SEARCHING_HOSPITAL,
      message: 'Next hospital contacted'
    });
  }

  return {
    success: true,
    message: 'Rejection processed, next hospital notified',
    next_hospital: nextHospitalRequest.hospitals
  };
};

/**
 * Get pending hospital requests for a specific hospital
 * 
 * @param {string} hospitalId - Hospital ID
 * @returns {Promise<Array>} Pending hospital requests
 */
const getPendingRequestsForHospital = async (hospitalId) => {
  const { data, error } = await supabase
    .from('hospital_requests')
    .select(`
      *,
      emergency_requests (
        request_id,
        user_latitude,
        user_longitude,
        description,
        medical_keywords,
        severity,
        status,
        created_at
      )
    `)
    .eq('hospital_id', hospitalId)
    .eq('status', HOSPITAL_REQUEST_STATUS.PENDING)
    .order('priority_order', { ascending: true });

  if (error) {
    console.error('Error fetching pending hospital requests:', error);
    throw new AppError('Failed to fetch pending requests', 500);
  }

  return data || [];
};

/**
 * Get hospital request by ID
 * 
 * @param {string} hospitalRequestId - Hospital request ID
 * @returns {Promise<Object>} Hospital request data
 */
const getHospitalRequestById = async (hospitalRequestId) => {
  const { data, error } = await supabase
    .from('hospital_requests')
    .select(`
      *,
      emergency_requests (*),
      hospitals (*)
    `)
    .eq('id', hospitalRequestId)
    .single();

  if (error || !data) {
    throw new AppError(ERROR_MESSAGES.HOSPITAL_REQUEST_NOT_FOUND, 404);
  }

  return data;
};

/**
 * Check if an emergency request has an approved hospital
 * 
 * @param {string} requestId - Emergency request ID
 * @returns {Promise<Object|null>} Approved hospital or null
 */
const getApprovedHospital = async (requestId) => {
  const { data } = await supabase
    .from('hospital_requests')
    .select(`
      *,
      hospitals (*)
    `)
    .eq('request_id', requestId)
    .eq('status', HOSPITAL_REQUEST_STATUS.APPROVED)
    .single();

  return data?.hospitals || null;
};

module.exports = {
  matchHospitals,
  processHospitalApproval,
  processHospitalRejection,
  getPendingRequestsForHospital,
  getHospitalRequestById,
  getApprovedHospital
};
