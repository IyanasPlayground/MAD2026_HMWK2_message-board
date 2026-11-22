import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../user-record_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();

  String _role = 'student'; 
  String? _error;
  bool _busy = false;

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'email not available':
        return 'That email is already being used.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak password':
        return 'Password must be at least 6 characters.';
      default:
        return 'Could not create the account. Please try again.';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });

    try {
      final cred = await _auth.register(
        email: _email.text,
        password: _pass.text,
      );
      final user = cred.user;
      if (user == null) {
        setState(() => _error = 'Please try again.');
        return;
      }
      try {
        await saveUserRecord(
          user,
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          role: _role,
        );
      } catch (_) {
        setState(() => _error =
            'Account created, but your profile was not saved. Please retry.');
        return;
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
        debugPrint('AUTH ERROR: ${e.code}');
      setState(() => _error = _friendly(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create account')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: _required,
              ),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: _required,
              ),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'student'),
              ),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              TextFormField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => (v == null || v.length < 6)
                    ? 'At least 6 characters'
                    : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Creating...' : 'Create account'),
              ),
            ]),
          ),
        ),
      );
}