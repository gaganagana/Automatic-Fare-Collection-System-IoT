import 'package:flutter/material.dart';

import '../theme.dart';

/// Shown instead of letting the app crash with a raw exception when
/// `flutterfire configure` hasn't been run yet (the #1 first-run issue).
/// Firebase.initializeApp() needs real project keys in
/// lib/firebase_options.dart — until that file is generated, main.dart
/// catches the failure and routes here instead of a blank/crashed screen.
class FirebaseSetupNeededScreen extends StatelessWidget {
  final Object error;
  const FirebaseSetupNeededScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: panelDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_fire_department, color: AppColors.amber, size: 36),
                  const SizedBox(height: 12),
                  const Text('Firebase isn\'t configured yet',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    'This app uses Firebase Authentication + Firestore for real '
                    'login, which means it needs your own Firebase project keys '
                    'before it can start. This is a one-time, ~10 minute setup.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Run these two commands from the project folder:',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.panelAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const SelectableText(
                      'dart pub global activate flutterfire_cli\nflutterfire configure',
                      style: TextStyle(color: AppColors.green, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Full step-by-step instructions (creating the Firebase '
                    'project, enabling Email/Password sign-in, Firestore, and '
                    'your first admin account) are in SETUP_GUIDE.md, section 2–3.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    collapsedIconColor: AppColors.textSecondary,
                    iconColor: AppColors.textSecondary,
                    title: const Text('Show raw error',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          error.toString(),
                          style: const TextStyle(color: AppColors.red, fontSize: 11),
                        ),
                      ),
                    ],
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
