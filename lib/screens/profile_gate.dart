import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../user-record_service.dart';
import 'board_screen.dart';

class ProfileGate extends StatelessWidget {
  final User user;
  const ProfileGate({super.key, required this.user});

  static const _required = [
    'uid', 'firstName', 'lastName', 'role', 'registrationDateTime'
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userRecord(user.uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Scaffold(
              body: Center(child: Text('Could not load your profile.')));
        }
        final data = snap.data?.data();
        final complete = data != null &&
            _required.every((k) => data[k] != null);
        if (!complete) {
          return Scaffold(
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Setting up your profile...'),
                TextButton(
                  onPressed: () => AuthService().signOut(),
                  child: const Text('Sign out'),
                ),
              ]),
            ),
          );
        }
        return BoardScreen(user: user, firstName: data['firstName']);
      },
    );
  }
}