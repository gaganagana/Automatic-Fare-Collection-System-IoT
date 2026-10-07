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

  // Gives Scaffold enough room for:
  // phone status bar + actual 60px header.
  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  late Timer _clock;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _clock = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!mounted) return;

        setState(() {
          now = DateTime.now();
        });
      },
    );
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    final currentUser = app.currentUser;
    final username = currentUser?.username ?? 'User';

    final isAdmin =
        currentUser?.role.toString().toLowerCase().contains('admin') ?? false;

    return Material(
      color: Colors.transparent,

      // IMPORTANT:
      // Keeps EN, speaker and profile BELOW the phone battery/time/network.
      child: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            gradient: panelGradient(
              top: const Color(0xFF17202B),
              bottom: AppColors.panel,
            ),
            border: const Border(
              bottom: BorderSide(
                color: AppColors.border,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 850;

              if (isSmallScreen) {
                return _SmallHeader(
                  app: app,
                  l10n: l10n,
                  username: username,
                  isAdmin: isAdmin,
                  now: now,
                );
              }

              return _DesktopHeader(
                app: app,
                l10n: l10n,
                username: username,
                isAdmin: isAdmin,
                now: now,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DESKTOP HEADER
// ============================================================================

class _DesktopHeader extends StatelessWidget {
  final AppState app;
  final AppLocalizations l10n;
  final String username;
  final bool isAdmin;
  final DateTime now;

  const _DesktopHeader({
    required this.app,
    required this.l10n,
    required this.username,
    required this.isAdmin,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.controlRoomTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.dashboardSubtitle}  •  ${username.toUpperCase()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LiveBadge(
              connected: app.telemetryServer.isRunning,
            ),

            const SizedBox(width: 8),

            _TimeDisplay(
              now: now,
            ),

            const SizedBox(width: 6),

            // Simulator stays available for ADMIN.
            if (isAdmin) ...[
              _SimulatorButton(app: app),
              const SizedBox(width: 6),
            ],

            _LanguageToggle(
              app: app,
            ),

            const SizedBox(width: 2),

            _WifiButton(
              app: app,
            ),

            const SizedBox(width: 2),

            _ProfileMenu(
              username: username,
              isAdmin: isAdmin,
              onLogout: () {
                HapticFeedback.lightImpact();
                context.read<AppState>().logout();
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// MOBILE / SMALL SCREEN HEADER
// ============================================================================

class _SmallHeader extends StatelessWidget {
  final AppState app;
  final AppLocalizations l10n;
  final String username;
  final bool isAdmin;
  final DateTime now;

  const _SmallHeader({
    required this.app,
    required this.l10n,
    required this.username,
    required this.isAdmin,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ------------------------------------------------------------------
        // TITLE + USERNAME
        // ------------------------------------------------------------------

        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.controlRoomTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                username.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 5),

        // ------------------------------------------------------------------
        // LANGUAGE
        // ------------------------------------------------------------------

        _LanguageToggle(
          app: app,
        ),

        const SizedBox(width: 2),

        // ------------------------------------------------------------------
        // WI-FI CONFIG
        // ------------------------------------------------------------------

        _WifiButton(
          app: app,
        ),

        const SizedBox(width: 1),

        // ------------------------------------------------------------------
        // PROFILE
        // ------------------------------------------------------------------

        _ProfileMenu(
          username: username,
          isAdmin: isAdmin,
          onLogout: () {
            HapticFeedback.lightImpact();
            context.read<AppState>().logout();
          },
        ),
      ],
    );
  }
}

// ============================================================================
// TIME DISPLAY
// ============================================================================

class _TimeDisplay extends StatelessWidget {
  final DateTime now;

  const _TimeDisplay({
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.panelAlt,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        DateFormat('HH:mm:ss').format(now),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontFeatures: [
            FontFeature.tabularFigures(),
          ],
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// ============================================================================
// SIMULATOR BUTTON
// ============================================================================

class _SimulatorButton extends StatelessWidget {
  final AppState app;

  const _SimulatorButton({
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return _BouncyButton(
      onPressed: () {
        HapticFeedback.mediumImpact();

        if (app.simulatorRunning) {
          app.stopSimulator();
        } else {
          app.startSimulator();

          if (!app.telemetryServer.isRunning) {
            app.startTelemetryServer();
          }
        }
      },
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: app.simulatorRunning
              ? AppColors.red
              : AppColors.green,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              app.simulatorRunning
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded,
              size: 14,
              color: Colors.black,
            ),

            const SizedBox(width: 3),

            Text(
              app.simulatorRunning ? 'STOP' : 'START',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LANGUAGE TOGGLE
// ============================================================================

class _LanguageToggle extends StatelessWidget {
  final AppState app;

  const _LanguageToggle({
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final code = app.locale.languageCode;

    final label = code == 'kn'
        ? 'ಕನ್ನಡ'
        : code == 'hi'
        ? 'हिन्दी'
        : 'EN';

    return PopupMenuButton<String>(
      tooltip: AppLocalizations.of(context).languageLabel,

      onSelected: (value) {
        HapticFeedback.selectionClick();
        app.setLocale(Locale(value));
      },

      color: AppColors.panel,
      elevation: 8,

      offset: const Offset(0, 5),

      itemBuilder: (context) => const [
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
        height: 30,
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.panelAlt,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WI-FI CONFIGURATION BUTTON & MODAL
// ============================================================================

class _WifiButton extends StatelessWidget {
  final AppState app;

  const _WifiButton({
    required this.app,
  });

  void _showWifiDialog(BuildContext context) {
    final ipCtrl = TextEditingController(text: app.esp32Ip);
    final phoneIps = app.localIps.isNotEmpty ? app.localIps.join(', ') : 'Fetching IP...';
    bool isConnecting = false;
    String? statusMessage;
    bool statusSuccess = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isOnline = app.isNodeMcuOnline;

          return AlertDialog(
            backgroundColor: AppColors.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? AppColors.green : AppColors.red,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'NodeMCU Wi-Fi Link',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Status badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isOnline ? AppColors.green : AppColors.red).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isOnline ? AppColors.green : AppColors.red).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? AppColors.green : AppColors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOnline
                                ? 'CONNECTED TO NODEMCU (${app.esp32Ip})'
                                : 'DISCONNECTED / WAITING FOR HARDWARE',
                            style: TextStyle(
                              color: isOnline ? AppColors.green : AppColors.red,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: ipCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'NodeMCU IP Address',
                      hintText: 'e.g. 192.168.1.24',
                      prefixIcon: const Icon(Icons.router, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.panelAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Local IP: $phoneIps:${app.serverPort}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ensure NodeMCU and phone are connected to the same Wi-Fi / Hotspot network.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  if (statusMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      statusMessage!,
                      style: TextStyle(
                        color: statusSuccess ? AppColors.green : AppColors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                ),
                icon: isConnecting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.link, size: 16, color: Colors.black),
                label: Text(
                  isConnecting ? 'Connecting...' : 'Connect to NodeMCU',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: isConnecting
                    ? null
                    : () async {
                        final ip = ipCtrl.text.trim();
                        if (ip.isEmpty) return;
                        setDialogState(() {
                          isConnecting = true;
                          statusMessage = null;
                        });

                        final success = await app.connectToNodeMcu(ip);

                        if (!ctx.mounted) return;
                        setDialogState(() {
                          isConnecting = false;
                          statusSuccess = success;
                          statusMessage = success
                              ? 'Successfully connected to NodeMCU at $ip!'
                              : 'Could not connect to $ip. Verify IP & Wi-Fi connection.';
                        });

                        if (success && context.mounted) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Connected to NodeMCU at $ip!'),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = app.isNodeMcuOnline;

    return Semantics(
      label: 'Wi-Fi Configuration',
      child: IconButton(
        tooltip: isOnline
            ? 'NodeMCU Connected (${app.esp32Ip})'
            : 'NodeMCU Disconnected (Tap to connect)',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showWifiDialog(context);
        },
        icon: Icon(
          isOnline ? Icons.wifi : Icons.wifi_off,
          color: isOnline ? AppColors.green : AppColors.red,
          size: 19,
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE MENU
// ============================================================================

class _ProfileMenu extends StatelessWidget {
  final String username;
  final bool isAdmin;
  final VoidCallback onLogout;

  const _ProfileMenu({
    required this.username,
    required this.isAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',

      onSelected: (value) {
        if (value == 'logout') {
          onLogout();
        }
      },

      color: AppColors.panel,
      elevation: 10,

      offset: const Offset(0, 5),

      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            enabled: false,
            value: 'profile',

            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withOpacity(0.14),
                    border: Border.all(
                      color: AppColors.green.withOpacity(0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.green,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 9),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        isAdmin
                            ? 'Admin / Operator'
                            : 'Passenger',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const PopupMenuDivider(),

          PopupMenuItem<String>(
            value: 'logout',

            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: AppColors.red,
                  size: 18,
                ),

                const SizedBox(width: 9),

                const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ];
      },

      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.panelAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.green.withOpacity(0.4),
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.green,
                size: 14,
              ),
            ),

            const SizedBox(width: 4),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 70,
              ),
              child: Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 1),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BOUNCY BUTTON
// ============================================================================

class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _BouncyButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.96;
        });
      },

      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
      },

      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },

      onTap: widget.onPressed,

      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(
          milliseconds: 100,
        ),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// LIVE / OFFLINE BADGE
// ============================================================================

class _LiveBadge extends StatefulWidget {
  final bool connected;

  const _LiveBadge({
    required this.connected,
  });

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connected = widget.connected;

    final color = connected
        ? AppColors.green
        : AppColors.textSecondary;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.35,
              end: 1.0,
            ).animate(_controller),

            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(width: 4),

          Text(
            connected ? 'LIVE' : 'OFFLINE',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}