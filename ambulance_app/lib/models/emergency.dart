class Emergency {
  final String requestId;
  final String patientName;
  final String careType;
  final String description;
  final String pickupLocation;
  final double? patientLat;
  final double? patientLng;

  Emergency({
    this.requestId = '',
    required this.patientName,
    required this.careType,
    required this.description,
    required this.pickupLocation,
    this.patientLat,
    this.patientLng,
  });

  /// Create from the server's pending-emergency JSON.
  factory Emergency.fromJson(Map<String, dynamic> json) {
    final lat = (json['patient_lat'] as num?)?.toDouble();
    final lng = (json['patient_lng'] as num?)?.toDouble();

    return Emergency(
      requestId: json['request_id']?.toString() ?? '',
      patientName: 'Patient',
      careType: json['description'] ?? 'Emergency',
      description: json['description'] ?? 'No description provided',
      pickupLocation: (lat != null && lng != null)
          ? 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}'
          : 'Location unavailable',
      patientLat: lat,
      patientLng: lng,
    );
  }
}
