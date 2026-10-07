import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final TextEditingController emailCtrl =
  TextEditingController();

  bool loading = false;

  String? errorMessage;
  String? successMessage;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });

    final email = emailCtrl.text.trim();

    // Basic validation
    if (email.isEmpty) {
      setState(() {
        loading = false;
        errorMessage = 'Please enter your email address.';
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        loading = false;
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await AuthService.sendPasswordReset(email);

      if (!mounted) return;

      setState(() {
        loading = false;
        successMessage =
        'Password reset email sent successfully.\n\n'
            'Please check your inbox and spam/junk folder.';
      });
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;

        errorMessage =
        'Firebase error: ${e.code}\n\n'
            '${e.message ?? 'Unable to send password reset email.'}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;

        errorMessage =
        'Unexpected error:\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1720),
        elevation: 0,
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 55),

              // Lock icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.panel,
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Enter the email address registered '
                    'with your Smart Bus account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Email field
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _sendResetLink(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.panelAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.green,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error message
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success message
              if (successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          successMessage!,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.green,
                        Color(0xFF00C87A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        AppColors.green.withOpacity(0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(12),
                      onTap:
                      loading ? null : _sendResetLink,
                      child: Center(
                        child: loading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          'SEND RESET LINK',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'A password reset link will be sent to '
                    'the email address registered in Firebase '
                    'Authentication.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}