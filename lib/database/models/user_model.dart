class UserLocal {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? profileImage;
  final int isSynced;

  UserLocal({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.profileImage,
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'profile_image': profileImage,
      'is_synced': isSynced,
    };
  }

  factory UserLocal.fromMap(Map<String, dynamic> map) {
    return UserLocal(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      gender: map['gender'],
      profileImage: map['profile_image'],
      isSynced: map['is_synced'] ?? 0,
    );
  }
}
