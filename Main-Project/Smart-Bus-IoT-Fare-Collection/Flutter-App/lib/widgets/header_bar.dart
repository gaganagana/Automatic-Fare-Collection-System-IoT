import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';

class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  const HeaderBar({super.key});

  @override
  State<HeaderBar> createState() => _HeaderBarState();

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _HeaderBarState extends State<HeaderBar> {
  late Timer _clock;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => now = DateTime.now()));
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: panelGradient(top: const Color(0xFF17202B), bottom: AppColors.panel),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SMART BUS - CONTROL ROOM',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  'IOT FLEET DASHBOARD / BENGALURU ROUTE - BUS-01'
                  '${app.currentUser != null ? '  •  ${app.currentUser!.username.toUpperCase()}' : ''}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _LiveBadge(connected: app.telemetryServer.isRunning),
              const SizedBox(width: 16),
              Text(DateFormat('HH:mm:ss').format(now),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFeatures: [FontFeature.tabularFigures()],
                      fontFamily: 'monospace')),
              const SizedBox(width: 16),
              _BouncyButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (app.simulatorRunning) {
                    app.stopSimulator();
                  } else {
                    app.startSimulator();
                    if (!app.telemetryServer.isRunning) app.startTelemetryServer();
                  }
                },
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(app.simulatorRunning ? Icons.stop : Icons.play_arrow, size: 16),
                  label: Text(app.simulatorRunning ? 'STOP SIMULATOR' : 'START SIMULATOR',
                      style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: app.simulatorRunning ? AppColors.red : AppColors.green,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: app.simulatorRunning ? AppColors.red : AppColors.green,
                    disabledForegroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _LanguageToggle(app: app),
              const SizedBox(width: 8),
              Semantics(
                label: app.ttsEnabled
                    ? '${l10n.ttsToggleLabel}: on'
                    : '${l10n.ttsToggleLabel}: off',
                toggled: app.ttsEnabled,
                child: IconButton(
                  tooltip: l10n.ttsToggleLabel,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    app.toggleTts();
                  },
                  icon: Icon(
                    app.ttsEnabled ? Icons.volume_up : Icons.volume_off,
                    color: app.ttsEnabled ? AppColors.green : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Logout',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<AppState>().logout();
                },
                icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple EN / KN switcher. Tapping it flips AppState.locale, which
/// simultaneously updates every AppLocalizations.of(context) string AND
/// the TTS engine's voice (see AppState.setLocale) — text and speech
/// never fall out of sync with each other.
class _LanguageToggle extends StatelessWidget {
  final AppState app;
  const _LanguageToggle({required this.app});

  @override
  Widget build(BuildContext context) {
    final isKannada = app.locale.languageCode == 'kn';
    return Semantics(
      label: '${AppLocalizations.of(context)!.languageLabel}: ${isKannada ? 'ಕನ್ನಡ' : 'English'}',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          app.setLocale(Locale(isKannada ? 'en' : 'kn'));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panelAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            isKannada ? 'ಕನ್ನಡ' : 'EN',
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Wraps any button so it visibly "presses down" (scales to 96%) on tap —
/// a small thing, but it's exactly the kind of micro-interaction that
/// makes a UI feel responsive rather than static.
class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const _BouncyButton({required this.child, required this.onPressed});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  final bool connected;
  const _LiveBadge({required this.connected});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
        boxShadow: glow(AppColors.green, blur: 10, opacity: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 6),
          const Text('LIVE', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
