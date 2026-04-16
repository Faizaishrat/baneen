class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? cnic;
  final String? profilePicture;
  final String userType; // 'passenger' or 'driver'
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Driver-specific fields
  final String? vehicleType;
  final String? vehicleNumber;
  final double? rating;
  final bool? isAvailable;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.cnic,
    this.profilePicture,
    required this.userType,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.vehicleType,
    this.vehicleNumber,
    this.rating,
    this.isAvailable,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      cnic: json['cnic'],
      profilePicture: json['profilePicture'],
      userType: json['userType'] ?? 'passenger',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'profilePicture': profilePicture,
      'userType': userType,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? cnic,
    String? profilePicture,
    String? userType,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehicleType,
    String? vehicleNumber,
    double? rating,
    bool? isAvailable,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

