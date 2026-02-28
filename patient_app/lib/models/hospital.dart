import 'hospital_resource.dart';

class Hospital {
  final String hospitalId;
  final String name;
  final double latitude;
  final double longitude;
  final String contactNumber;
  final HospitalResource? resources;

  Hospital({
    required this.hospitalId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    this.resources,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalId: json['hospital_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      contactNumber: json['contact_number']?.toString() ?? '',
      resources: json['resources'] != null
          ? HospitalResource.fromJson(
              json['resources'] is List
                  ? json['resources'][0]
                  : json['resources'],
            )
          : json['hospital_resources'] != null
          ? HospitalResource.fromJson(
              json['hospital_resources'] is List
                  ? json['hospital_resources'][0]
                  : json['hospital_resources'],
            )
          : null,
    );
  }
}
