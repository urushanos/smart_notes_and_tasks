class AppUser {
  final String uid;
  final String username;
  final String email;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
    );
  }
}
