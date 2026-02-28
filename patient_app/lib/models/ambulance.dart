class Ambulance {
  final String ambulanceId;
  final String driverName;
  final double currentLatitude;
  final double currentLongitude;
  final String ambulanceNo;
  final String status; // Available / Busy

  Ambulance({
    required this.ambulanceId,
    required this.driverName,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.ambulanceNo,
    required this.status,
  });

  factory Ambulance.fromJson(Map<String, dynamic> json) {
    return Ambulance(
      ambulanceId: json['ambulance_id']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      currentLatitude: (json['current_latitude'] as num?)?.toDouble() ?? 0.0,
      currentLongitude: (json['current_longitude'] as num?)?.toDouble() ?? 0.0,
      ambulanceNo: json['ambulance_no']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Busy',
    );
  }

  bool get isAvailable => status == 'Available';
}
