class EmergencyModel {
  String id;
  String status;

  // patient
  double? patientLat;
  double? patientLng;
  String? description;
  String? language;

  // ambulance
  String? ambulanceNumber;
  String? driverName;
  String? driverPhone;
  int? ambulanceEta;

  // hospital
  String? hospitalName;
  String? hospitalDepartment;
  int? hospitalEta;
  double? hospitalDistance;

  EmergencyModel({
    required this.id,
    required this.status,
    this.patientLat,
    this.patientLng,
    this.description,
    this.language,
    this.ambulanceNumber,
    this.driverName,
    this.driverPhone,
    this.ambulanceEta,
    this.hospitalName,
    this.hospitalDepartment,
    this.hospitalEta,
    this.hospitalDistance,
  });

  // backend JSON → app object
  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      id: json['id'],
      status: json['status'],
      patientLat: json['patientLat'],
      patientLng: json['patientLng'],
      description: json['description'],
      language: json['language'],
      ambulanceNumber: json['ambulanceNumber'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      ambulanceEta: json['ambulanceEta'],
      hospitalName: json['hospitalName'],
      hospitalDepartment: json['hospitalDepartment'],
      hospitalEta: json['hospitalEta'],
      hospitalDistance: json['hospitalDistance'],
    );
  }
}