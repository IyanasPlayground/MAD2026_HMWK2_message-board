import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
Stream<DocumentSnapshot<Map<String, dynamic>>> userRecord(String uid) {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots();
}