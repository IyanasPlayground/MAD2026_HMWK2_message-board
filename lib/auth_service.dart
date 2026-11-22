import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Stream<User?> authState = _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserRecord(User user, {
    required String firstName,
    required String lastName,
    required String role,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'registrationDateTime': FieldValue.serverTimestamp(),
      });
  }
}