##
Project:
Iyana Halliburton
MAD Fall 2026

## Setup 

1. install Flutter, the Firebase CLI and the FlutterFire CLI
2. Create a Firebase project; enable Email/Password sign-in and create a Firestore database. My flutter base project is flutter-fcm-CW14. 
3. Run `flutterfire configure` to make firebase_options.dart.Run `flutter pub get`, then `flutter run'. Afterwards, run 'flutter build apk --release'



## Data model

docuemnt / fields / read rules / write rules

-- uid / uid, firstName, lastName, role, registrationDateTime / created user / registered admin/client

-- msgid / text, authorUid, authorName, createdAt, editedAt / Created user / admin/author



All services for the app are in the lib folder to allow auth calls.
Registration creates the auth account and creates the uid document. If
the docuemnt is not created or completed, an error will show. 





# message_board

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
