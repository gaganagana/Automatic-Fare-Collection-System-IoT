import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool obscurePassword = true;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => loading = true);
    final ok = await context.read<AppState>().login(emailCtrl.text.trim(), passCtrl.text.trim());
    if (!mounted) return;
    setState(() => loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful — a confirmation email is on its way.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AppState>().authError;
    return Scaffold(
      body: Container(
        // Subtle radial-style glow behind the card instead of a flat
        // background — the single biggest thing that makes a dark login
        // screen feel like a designed product instead of a placeholder.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1720), AppColors.bg],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.06),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                        const BoxShadow(
                          color: Colors.black54,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon in a soft glowing badge instead of a bare icon —
                        // this one change reads as "designed" vs "default".
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.green.withOpacity(0.22), AppColors.green.withOpacity(0.06)],
                            ),
                            border: Border.all(color: AppColors.green.withOpacity(0.35)),
                          ),
                          child: const Icon(Icons.directions_bus_rounded, color: AppColors.green, size: 28),
                        ),
                        const SizedBox(height: 20),
                        const Text('Smart Bus — Control Room',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        const Text(
                            'Secured by Firebase Authentication. Sign in as Admin/Operator '
                            'or with your passenger account.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                        const SizedBox(height: 28),
                        _LoginField(
                          controller: emailCtrl,
                          label: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _LoginField(
                          controller: passCtrl,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: obscurePassword,
                          onSubmitted: (_) => _submit(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: error != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, size: 14, color: AppColors.red),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(error,
                                            style: const TextStyle(color: AppColors.red, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [AppColors.green, Color(0xFF00C87A)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.green.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: loading ? null : _submit,
                                child: Center(
                                  child: loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                        )
                                      : const Text('LOGIN',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.5)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text('New passenger? Register a card account',
                                style: TextStyle(color: AppColors.blue, fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary.withOpacity(0.7)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Admin/Operator accounts are created once by the transport '
                                'admin directly in the Firebase console — there is no '
                                'self-service admin sign-up.',
                                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.85), fontSize: 11, height: 1.4),
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
          ),
        ),
      ),
    );
  }
}

/// Shared styled field for the login form — icon prefix, rounded fill,
/// subtle border-highlight on focus. Pulled into its own widget so the
/// email and password fields stay pixel-identical without repeating the
/// decoration by hand.
class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.panelAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}
