/**
 * Socket.IO Service for Patient App
 *
 * Handles real-time connection to the Emergency Coordination Server.
 * Listens for request_update events to receive ambulance and hospital assignments.
 */

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_config.dart';

/// Callback type for status updates
typedef StatusUpdateCallback = void Function(Map<String, dynamic> statusData);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  String? _currentRequestId;
  StatusUpdateCallback? _onStatusUpdate;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// Connect to Socket.IO server and register for a specific request
  void connect(String requestId, {StatusUpdateCallback? onStatusUpdate}) {
    _currentRequestId = requestId;
    _onStatusUpdate = onStatusUpdate;

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

      // Register for this specific request's updates
      _socket!.emit('register_patient', {'requestId': requestId});
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected from server');
      _isConnected = false;
    });

    _socket!.on('request_update', (data) {
      print('[Socket] Received request_update: $data');
      if (data is Map<String, dynamic> && _onStatusUpdate != null) {
        _onStatusUpdate!(data);
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

    print('[Socket] Connecting to $serverUrl for request $requestId');
    _socket!.connect();
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRequestId = null;
    _isConnected = false;
    print('[Socket] Disconnected and disposed');
  }

  /// Update the callback for status updates
  void setStatusUpdateCallback(StatusUpdateCallback? callback) {
    _onStatusUpdate = callback;
  }

  /// Check if connected to server
  bool getConnectionStatus() {
    return _isConnected && _socket?.connected == true;
  }
}