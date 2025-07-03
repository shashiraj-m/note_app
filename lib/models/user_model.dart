import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String? username;

  AppUser({required this.uid, required this.email, this.username});

  factory AppUser.fromFirebase(User user, Map<String, dynamic>? firestoreData) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      username: firestoreData?['username'] ?? user.displayName,
    );
  }
}
