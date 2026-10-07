import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Registration controllers
  final nameCtrl = TextEditingController();
  final rfidCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool isSignUp = false;
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? localError;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    rfidCtrl.dispose();
    confirmPassCtrl.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    setState(() => localError = null);
    if (emailCtrl.text.trim().isEmpty ||
        passCtrl.text.trim().isEmpty) {
      setState(() => localError = 'Please enter email and password.');
      return;
    }

    setState(() {
      loading = true;
    });

    final ok = await context.read<AppState>().login(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful.'),
        ),
      );
    }
  }

  Future<void> _submitRegister() async {
    setState(() => localError = null);
    final l10n = AppLocalizations.of(context);
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final rfid = rfidCtrl.text.trim().toUpperCase();
    final password = passCtrl.text.trim();
    final confirmPassword = confirmPassCtrl.text.trim();

    if (name.isEmpty) {
      setState(() => localError = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => localError = 'Please enter a valid email address.');
      return;
    }
    if (rfid.isEmpty || rfid.length < 4) {
      setState(() => localError = 'Please enter a valid RFID Card UID (e.g., 5B850B1A).');
      return;
    }
    if (password.length < 6) {
      setState(() => localError = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => localError = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      loading = true;
    });

    final ok = await context.read<AppState>().registerPassenger(
      email: email,
      password: password,
      username: name,
      linkedUid: rfid,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationSuccess),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final error = localError ?? app.authError;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND
          // ============================================================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F1720),
                  AppColors.bg,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 440,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withValues(alpha: 0.06),
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

                        // ==================================================
                        // AUTH CARD CONTENT
                        // ==================================================
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // BUS ICON & HEADER
                            // ==================================================
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.green.withValues(alpha: 0.22),
                                        AppColors.green.withValues(alpha: 0.06),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: AppColors.green.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus_rounded,
                                    color: AppColors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.loginTitle,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isSignUp
                                            ? 'Auto-provision your RFID card & account'
                                            : l10n.loginSubtitle,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // TAB SWITCHER (SIGN IN / SIGN UP)
                            // ==================================================
                            Container(
                              height: 42,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.panelAlt,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSignUp = false;
                                          localError = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: !isSignUp
                                              ? AppColors.green.withValues(alpha: 0.18)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: !isSignUp
                                              ? Border.all(
                                                  color: AppColors.green.withValues(alpha: 0.4),
                                                )
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          l10n.signInTab,
                                          style: TextStyle(
                                            color: !isSignUp ? AppColors.green : AppColors.textSecondary,
                                            fontWeight: !isSignUp ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSignUp = true;
                                          localError = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSignUp
                                              ? AppColors.green.withValues(alpha: 0.18)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isSignUp
                                              ? Border.all(
                                                  color: AppColors.green.withValues(alpha: 0.4),
                                                )
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          l10n.signUpTab,
                                          style: TextStyle(
                                            color: isSignUp ? AppColors.green : AppColors.textSecondary,
                                            fontWeight: isSignUp ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // SIGN UP: FULL NAME FIELD
                            // ==================================================
                            if (isSignUp) ...[
                              _LoginField(
                                controller: nameCtrl,
                                label: l10n.fullNameLabel,
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 12),
                            ],

                            // ==================================================
                            // EMAIL FIELD
                            // ==================================================
                            _LoginField(
                              controller: emailCtrl,
                              label: l10n.emailLabel,
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // SIGN UP: RFID CARD UID FIELD
                            // ==================================================
                            if (isSignUp) ...[
                              _LoginField(
                                controller: rfidCtrl,
                                label: l10n.rfidUidLabel,
                                icon: Icons.nfc_outlined,
                                helperText: l10n.rfidUidHelper,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                  LengthLimitingTextInputFormatter(14),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // ==================================================
                            // PASSWORD FIELD
                            // ==================================================
                            _LoginField(
                              controller: passCtrl,
                              label: l10n.passwordLabel,
                              icon: Icons.lock_outline,
                              obscureText: obscurePassword,
                              onSubmitted: (_) => isSignUp ? _submitRegister() : _submitLogin(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),

                            // ==================================================
                            // SIGN UP: CONFIRM PASSWORD FIELD
                            // ==================================================
                            if (isSignUp) ...[
                              const SizedBox(height: 12),
                              _LoginField(
                                controller: confirmPassCtrl,
                                label: l10n.confirmPasswordLabel,
                                icon: Icons.lock_reset_outlined,
                                obscureText: obscureConfirmPassword,
                                onSubmitted: (_) => _submitRegister(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirmPassword = !obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ],

                            // ==================================================
                            // FORGOT PASSWORD (SIGN IN ONLY)
                            // ==================================================
                            if (!isSignUp)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _openForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 8),

                            // ==================================================
                            // ERROR MESSAGE DISPLAY
                            // ==================================================
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: error != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 14,
                                            color: AppColors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              error,
                                              style: const TextStyle(
                                                color: AppColors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            const SizedBox(height: 10),

                            // ==================================================
                            // ACTION BUTTON (LOGIN OR REGISTER)
                            // ==================================================
                            SizedBox(
                              width: double.infinity,
                              height: 48,
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
                                      color: AppColors.green.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: loading
                                        ? null
                                        : () => isSignUp ? _submitRegister() : _submitLogin(),
                                    child: Center(
                                      child: loading
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.black,
                                              ),
                                            )
                                          : Text(
                                              isSignUp
                                                  ? l10n.registerButton
                                                  : l10n.loginButton,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==================================================
                            // TOGGLE PROMPT LINK
                            // ==================================================
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isSignUp = !isSignUp;
                                    localError = null;
                                  });
                                },
                                child: Text(
                                  isSignUp
                                      ? l10n.alreadyHaveAccount
                                      : l10n.needAccountPrompt,
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const Divider(
                              color: AppColors.border,
                              height: 1,
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // INFO NOTE
                            // ==================================================
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isSignUp ? Icons.verified_user_outlined : Icons.info_outline,
                                  size: 14,
                                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isSignUp
                                        ? 'Your RFID card will be instantly initialized in Firestore with ₹200 balance and active status.'
                                        : 'Admin/Operator accounts are managed securely via Firebase Console. Passengers can self-register their cards above.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
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

          // ==============================================================
          // LANGUAGE SELECTOR BUTTON
          // ==============================================================
          Positioned(
            top: 42,
            right: 24,
            child: PopupMenuButton<String>(
              tooltip: l10n.languageLabel,
              onSelected: (value) {
                app.setLocale(Locale(value));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: 'kn',
                  child: Text('ಕನ್ನಡ'),
                ),
                PopupMenuItem(
                  value: 'hi',
                  child: Text('हिन्दी'),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Text(
                  app.locale.languageCode == 'kn'
                      ? 'ಕನ್ನಡ'
                      : app.locale.languageCode == 'hi'
                          ? 'हिन्दी'
                          : 'EN',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOGIN FIELD WIDGET
// ============================================================================

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSubmitted,
    this.helperText,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.panelAlt,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
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
            width: 1.4,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}