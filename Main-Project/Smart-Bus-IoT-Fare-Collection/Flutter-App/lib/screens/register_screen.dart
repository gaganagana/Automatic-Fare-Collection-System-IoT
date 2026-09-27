import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final uidCtrl = TextEditingController();
  bool loading = false;

  String? localError;

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty ||
        uidCtrl.text.trim().isEmpty) {
      setState(() => localError = 'Please fill in every field.');
      return;
    }
    final app = context.read<AppState>();
    final uid = uidCtrl.text.trim().toUpperCase();
    final walletExists = app.wallets.any((w) => w.uid == uid);
    if (!walletExists) {
      setState(() => localError =
          'That RFID UID isn\'t registered yet. Ask the admin to add it under "Register New RFID" first.');
      return;
    }
    setState(() {
      loading = true;
      localError = null;
    });
    final ok = await app.registerPassenger(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
      username: nameCtrl.text.trim(),
      linkedUid: uid,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final error = localError ?? context.watch<AppState>().authError;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register — Passenger Account'),
        backgroundColor: AppColors.panel,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: panelDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This creates a real account with Firebase Authentication. '
                    'Link it to an RFID card UID already registered by the admin '
                    '(or ask the admin to add your card first).',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password (min 6 characters)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: uidCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Your RFID Card UID (Hex)'),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('CREATE ACCOUNT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
