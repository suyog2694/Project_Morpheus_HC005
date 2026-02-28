class StabilizationCenter {
  final String centerId;
  final String name;
  final double latitude;
  final double longitude;
  final String contactNumber;

  StabilizationCenter({
    required this.centerId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
  });

  factory StabilizationCenter.fromJson(Map<String, dynamic> json) {
    return StabilizationCenter(
      centerId: json['center_id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      contactNumber: json['contact_number'] ?? '',
    );
  }
}
