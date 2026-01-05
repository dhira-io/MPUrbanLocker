class User {
  final String id;
  final String? digilockerid;
  final String? name;
  final String? dob;
  final String? gender;
  final String? email;
  final String? mobile;
  final String? eaadhaar;
  final String? referenceKey;
  final String? address;
  final bool? newAccount;
  final bool? isActive;
  final String? lastLogin;
  final String? profileImageUrl;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    this.digilockerid,
    this.name,
    this.dob,
    this.gender,
    this.email,
    this.mobile,
    this.eaadhaar,
    this.referenceKey,
    this.address,
    this.newAccount,
    this.isActive,
    this.lastLogin,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      digilockerid: json['digilockerid'] as String?,
      name: json['name'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      eaadhaar: json['eaadhaar'] as String?,
      referenceKey: json['referenceKey'] as String?,
      address: json['address'] as String?,
      newAccount: json['newAccount'] as bool?,
      isActive: json['isActive'] as bool?,
      lastLogin: json['lastLogin'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'digilockerid': digilockerid,
      'name': name,
      'dob': dob,
      'gender': gender,
      'email': email,
      'mobile': mobile,
      'eaadhaar': eaadhaar,
      'referenceKey': referenceKey,
      'address': address,
      'newAccount': newAccount,
      'isActive': isActive,
      'lastLogin': lastLogin,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  User copyWith({
    String? id,
    String? digilockerid,
    String? name,
    String? dob,
    String? gender,
    String? email,
    String? mobile,
    String? eaadhaar,
    String? referenceKey,
    String? address,
    bool? newAccount,
    bool? isActive,
    String? lastLogin,
    String? profileImageUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      digilockerid: digilockerid ?? this.digilockerid,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      eaadhaar: eaadhaar ?? this.eaadhaar,
      referenceKey: referenceKey ?? this.referenceKey,
      address: address ?? this.address,
      newAccount: newAccount ?? this.newAccount,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}
