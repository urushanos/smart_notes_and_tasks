class AppUser {
  final String uid;
  final String username;
  final String email;
  final String? photoPath;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.photoPath,
  });

  AppUser copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoPath,
    bool clearPhotoPath = false,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoPath': photoPath,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      photoPath: map['photoPath'] as String?,
    );
  }
}
