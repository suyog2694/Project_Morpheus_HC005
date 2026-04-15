/**
 * Socket.IO Manager
 *
 * Handles all real-time WebSocket communication for the Emergency Response System.
 *
 * Events:
 * - "register_ambulance"  : Ambulance driver registers their socket with ambulance_id
 * - "new_assignment"      : Sent to specific ambulance driver when assigned to a request
 * - "hospital_new_request": Sent to hospital dashboard when a new request is created
 * - "request_update"      : Sent to patient app when request status changes
 */

const { Server } = require('socket.io');
const { createServer } = require('http');

let io = null;

/**
 * Initialize Socket.IO server
 * Call once from server.js after HTTP server is created
 *
 * @param {Object} httpServer - HTTP server instance
 * @returns {Object} Socket.IO server instance
 */
const init = (httpServer) => {
  io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST']
    },
    pingTimeout: 60000,
    pingInterval: 25000
  });

  console.log('Socket.IO server initialized');

  io.on('connection', (socket) => {
    console.log(`[Socket] Client connected: ${socket.id}`);

    // Handle ambulance driver registration
    socket.on('register_ambulance', (data, callback) => {
      const { ambulanceId } = data;

      if (!ambulanceId) {
        console.log(`[Socket] Registration attempted without ambulanceId`);
        if (callback) callback({ success: false, message: 'ambulanceId required' });
        return;
      }

      // Join a room specific to this ambulance
      // Room name format: "ambulance:<ambulance_id>"
      const roomName = `ambulance:${ambulanceId}`;
      socket.join(roomName);

      console.log(`[Socket] Ambulance ${ambulanceId} registered in room ${roomName}`);
      console.log(`[Socket] Socket ${socket.id} joined room ${roomName}`);

      if (callback) {
        callback({ success: true, message: `Registered to ambulance room: ${ambulanceId}` });
      }
    });

    // Handle hospital dashboard registration
    socket.on('register_hospital', (data, callback) => {
      const { hospitalId } = data;

      if (!hospitalId) {
        console.log(`[Socket] Hospital registration attempted without hospitalId`);
        if (callback) callback({ success: false, message: 'hospitalId required' });
        return;
      }

      const roomName = `hospital:${hospitalId}`;
      socket.join(roomName);

      console.log(`[Socket] Hospital ${hospitalId} registered in room ${roomName}`);

      if (callback) {
        callback({ success: true, message: `Registered to hospital room: ${hospitalId}` });
      }
    });

    // Handle patient app registration
    socket.on('register_patient', (data, callback) => {
      const { requestId } = data;

      if (!requestId) {
        if (callback) callback({ success: false, message: 'requestId required' });
        return;
      }

      const roomName = `request:${requestId}`;
      socket.join(roomName);

      console.log(`[Socket] Patient registered for request ${requestId}`);

      if (callback) {
        callback({ success: true, message: `Registered to request room: ${requestId}` });
      }
    });

    socket.on('disconnect', (reason) => {
      console.log(`[Socket] Client disconnected: ${socket.id}, reason: ${reason}`);
    });

    socket.on('error', (error) => {
      console.error(`[Socket] Socket error for ${socket.id}:`, error.message);
    });
  });

  return io;
};

/**
 * Get the Socket.IO server instance
 * @returns {Object|null} Socket.IO server instance
 */
const getIO = () => io;

/**
 * Emit new assignment event to a specific ambulance driver
 *
 * @param {number} ambulanceId - The ambulance ID
 * @param {Object} assignmentData - Assignment details
 * @returns {boolean} True if emitted successfully
 */
const emitNewAssignment = (ambulanceId, assignmentData) => {
  if (!io) {
    console.error('[Socket] Socket.IO not initialized - cannot emit new_assignment');
    return false;
  }

  const roomName = `ambulance:${ambulanceId}`;
  const eventData = {
    event: 'new_assignment',
    request_id: assignmentData.request_id,
    patient_latitude: assignmentData.patient_latitude,
    patient_longitude: assignmentData.patient_longitude,
    description: assignmentData.description || '',
    patient_name: assignmentData.patient_name || 'Patient',
    severity: assignmentData.severity || 'medium',
    timestamp: new Date().toISOString()
  };

  // Emit to the specific ambulance room
  io.to(roomName).emit('new_assignment', eventData);

  console.log(`[Socket] Emitted new_assignment to room ${roomName}`);
  console.log(`[Socket] Data: request_id=${eventData.request_id}, lat=${eventData.patient_latitude}, lng=${eventData.patient_longitude}`);

  return true;
};

/**
 * Emit new hospital request event
 *
 * @param {number} hospitalId - The hospital ID
 * @param {Object} requestData - Request details
 * @returns {boolean} True if emitted successfully
 */
const emitHospitalNewRequest = (hospitalId, requestData) => {
  if (!io) {
    console.error('[Socket] Socket.IO not initialized - cannot emit hospital_new_request');
    return false;
  }

  const roomName = `hospital:${hospitalId}`;
  const eventData = {
    event: 'hospital_new_request',
    request_id: requestData.request_id,
    patient_location: {
      latitude: requestData.patient_latitude,
      longitude: requestData.patient_longitude
    },
    description: requestData.description || '',
    severity: requestData.severity || 'medium',
    medical_keywords: requestData.medical_keywords || [],
    distance_km: requestData.distance_km,
    priority_order: requestData.priority_order,
    timestamp: new Date().toISOString()
  };

  io.to(roomName).emit('hospital_new_request', eventData);

  console.log(`[Socket] Emitted hospital_new_request to room ${roomName}`);
  console.log(`[Socket] Data: request_id=${eventData.request_id}, priority=${eventData.priority_order}`);

  return true;
};

/**
 * Emit request status update to patient app
 *
 * @param {string} requestId - The emergency request ID
 * @param {Object} statusData - Status update data
 * @returns {boolean} True if emitted successfully
 */
const emitRequestUpdate = (requestId, statusData) => {
  if (!io) {
    console.error('[Socket] Socket.IO not initialized - cannot emit request_update');
    return false;
  }

  const roomName = `request:${requestId}`;
  const eventData = {
    event: 'request_update',
    request_id: requestId,
    status: statusData.status,
    ambulance: statusData.ambulance || null,
    hospital: statusData.hospital || null,
    timestamp: new Date().toISOString()
  };

  io.to(roomName).emit('request_update', eventData);

  console.log(`[Socket] Emitted request_update to room ${roomName}`);
  console.log(`[Socket] Data: request_id=${requestId}, status=${statusData.status}`);

  return true;
};

/**
 * Broadcast to all connected ambulance drivers (for system-wide alerts)
 *
 * @param {Object} alertData - Alert data
 * @returns {boolean} True if emitted successfully
 */
const emitSystemAlert = (alertData) => {
  if (!io) {
    console.error('[Socket] Socket.IO not initialized - cannot emit system_alert');
    return false;
  }

  io.emit('system_alert', {
    event: 'system_alert',
    ...alertData,
    timestamp: new Date().toISOString()
  });

  console.log(`[Socket] Emitted system_alert: ${alertData.message}`);

  return true;
};

/**
 * Emit hospital assignment to ambulance driver
 * Called when hospital approves so ambulance knows where to drop patient
 *
 * @param {number} ambulanceId - The ambulance ID
 * @param {Object} assignmentData - Hospital assignment details
 * @returns {boolean} True if emitted successfully
 */
const emitAmbulanceHospitalAssignment = (ambulanceId, assignmentData) => {
  if (!io) {
    console.error('[Socket] Socket.IO not initialized - cannot emit hospital_assigned');
    return false;
  }

  const roomName = `ambulance:${ambulanceId}`;
  const eventData = {
    event: 'hospital_assigned',
    request_id: assignmentData.request_id,
    hospital: {
      hospital_id: assignmentData.hospital_id,
      name: assignmentData.hospital_name,
      latitude: assignmentData.hospital_latitude,
      longitude: assignmentData.hospital_longitude,
      address: assignmentData.hospital_address || '',
      contact_number: assignmentData.hospital_contact || ''
    },
    patient_status: assignmentData.patient_status || 'en_route_to_hospital',
    timestamp: new Date().toISOString()
  };

  io.to(roomName).emit('hospital_assigned', eventData);

  console.log(`[Socket] Emitted hospital_assigned to room ${roomName}`);
  console.log(`[Socket] Data: request_id=${eventData.request_id}, hospital=${assignmentData.hospital_name}`);

  return true;
};

module.exports = {
  init,
  getIO,
  emitNewAssignment,
  emitHospitalNewRequest,
  emitRequestUpdate,
  emitSystemAlert,
  emitAmbulanceHospitalAssignment
};
