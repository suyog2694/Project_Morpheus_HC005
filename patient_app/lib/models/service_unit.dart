class ServiceUnit {
  final String name;
  final double distance;
  final bool available;

  // optional (only for ambulance)
  final int? eta;

  // optional (only for hospital)
  final int? icu;
  final int? beds;
  final int? ventilator;
  final int? oxygen;

  ServiceUnit({
    required this.name,
    required this.distance,
    required this.available,
    this.eta,
    this.icu,
    this.beds,
    this.ventilator,
    this.oxygen,
  });

  // THIS is what backend will use
  factory ServiceUnit.fromJson(Map<String, dynamic> json) {
    return ServiceUnit(
      name: json['name'],
      distance: (json['distance'] as num).toDouble(),
      available: json['available'],
      eta: json['eta'],
      icu: json['icu'],
      beds: json['beds'],
      ventilator: json['ventilator'],
      oxygen: json['oxygen'],
    );
  }
}