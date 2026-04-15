/**
 * Socket.IO Service for Ambulance App
 *
 * Handles real-time connection to receive emergency assignments
 * and hospital destination updates.
 */

import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/emergency.dart';
import 'api_config.dart';

/// Callback types
typedef NewAssignmentCallback = void Function(Emergency emergency);
typedef HospitalAssignedCallback = void Function(Map<String, dynamic> hospitalData);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  int? _ambulanceId;
  NewAssignmentCallback? _onNewAssignment;
  HospitalAssignedCallback? _onHospitalAssigned;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Connect to Socket.IO server as an ambulance
  void connect(int ambulanceId) {
    _ambulanceId = ambulanceId;

    // Determine server URL (handle Android emulator localhost issue)
    final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      print('[Socket] Connected to server');
      _isConnected = true;

      // Register as ambulance
      _socket!.emit('register_ambulance', {'ambulanceId': ambulanceId});
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected from server');
      _isConnected = false;
    });

    /// Listen for new emergency assignment
    /// Event: "new_assignment"
    /// Data: { request_id, patient_latitude, patient_longitude, description, severity }
    _socket!.on('new_assignment', (data) {
      print('[Socket] Received new_assignment: $data');

      if (data is Map<String, dynamic>) {
        final emergency = Emergency.fromJson({
          'request_id': data['request_id'],
          'patient_lat': data['patient_latitude'],
          'patient_lng': data['patient_longitude'],
          'description': data['description'] ?? 'Emergency',
          'caller_name': data['patient_name'] ?? 'Patient',
        });

        if (_onNewAssignment != null) {
          _onNewAssignment!(emergency);
        }
      }
    });

    /// Listen for hospital assignment (after hospital approves)
    /// Event: "hospital_assigned"
    /// Data: { request_id, hospital: { hospital_id, name, latitude, longitude, address, contact_number } }
    _socket!.on('hospital_assigned', (data) {
      print('[Socket] Received hospital_assigned: $data');

      if (data is Map<String, dynamic> && _onHospitalAssigned != null) {
        _onHospitalAssigned!(data);
      }
    });

    _socket!.onConnectError((error) {
      print('[Socket] Connection error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('[Socket] Socket error: $error');
    });

    _socket!.on('disconnect', (reason) {
      print('[Socket] Disconnected: $reason');
      _isConnected = false;
    });

    print('[Socket] Connecting to $serverUrl as ambulance $ambulanceId');
    _socket!.connect();
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _ambulanceId = null;
    _isConnected = false;
    print('[Socket] Disconnected and disposed');
  }

  /// Set callback for new assignment
  void setOnNewAssignment(NewAssignmentCallback? callback) {
    _onNewAssignment = callback;
  }

  /// Set callback for hospital assignment
  void setOnHospitalAssigned(HospitalAssignedCallback? callback) {
    _onHospitalAssigned = callback;
  }

  /// Check if connected
  bool getConnectionStatus() {
    return _isConnected && _socket?.connected == true;
  }
}