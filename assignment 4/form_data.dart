class FormData {
  String? id;
  String fullName;
  String email;
  String phoneNumber;
  String address;
  String gender;
  DateTime createdAt;

  FormData({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.createdAt,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      id: json['id'] as String?,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      address: json['address'] as String,
      gender: json['gender'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }
}