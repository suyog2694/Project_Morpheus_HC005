class UserModel {
  final String name;
  final String ambulanceId;
  final String phone;

  const UserModel({
    required this.name,
    required this.ambulanceId,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name':        name,
    'ambulanceId': ambulanceId,
    'phone':       phone,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name:        json['name']        as String,
    ambulanceId: json['ambulanceId'] as String,
    phone:       json['phone']       as String,
  );
}