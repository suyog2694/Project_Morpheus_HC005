class UserModel {
  final String name;
  /// Numeric ambulance_id from the backend server.
  final int ambulanceId;
  /// Vehicle plate number (ambulance_no).
  final String ambulanceNo;
  final String phone;

  const UserModel({
    required this.name,
    required this.ambulanceId,
    required this.ambulanceNo,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name':         name,
    'ambulanceId':  ambulanceId,
    'ambulanceNo':  ambulanceNo,
    'phone':        phone,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name:         json['name']         as String,
    ambulanceId:  json['ambulanceId']  as int,
    ambulanceNo:  json['ambulanceNo']  as String,
    phone:       json['phone']        as String,
  );
}