class HospitalResource {
  final String hospitalId;
  final int icuTotal;
  final int icuAvailable;
  final int bedTotal;
  final int bedAvailable;
  final int ventilatorTotal;
  final int ventilatorAvailable;
  final String? lastUpdatedAt;

  HospitalResource({
    required this.hospitalId,
    required this.icuTotal,
    required this.icuAvailable,
    required this.bedTotal,
    required this.bedAvailable,
    required this.ventilatorTotal,
    required this.ventilatorAvailable,
    this.lastUpdatedAt,
  });

  factory HospitalResource.fromJson(Map<String, dynamic> json) {
    return HospitalResource(
      hospitalId: json['hospital_id']?.toString() ?? '',
      icuTotal: json['icu_total'] ?? 0,
      icuAvailable: json['icu_available'] ?? 0,
      bedTotal: json['bed_total'] ?? json['beds_total'] ?? 0,
      bedAvailable: json['bed_available'] ?? json['beds_available'] ?? 0,
      ventilatorTotal:
          json['ventilator_total'] ?? json['ventilators_total'] ?? 0,
      ventilatorAvailable:
          json['ventilator_available'] ?? json['ventilators_available'] ?? 0,
      lastUpdatedAt: json['last_updated_at'],
    );
  }
}
