import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/current_route_block.dart';
import '../widgets/header_bar.dart';
import '../widgets/live_map.dart';
import '../widgets/metric_card.dart';
import '../widgets/rfid_wallet_panel.dart';
import '../widgets/passenger_management_panel.dart';
import '../widgets/route_timeline.dart';
import '../widgets/sms_banner.dart';
import '../widgets/ai_assistant_panel.dart';
import '../widgets/transaction_table.dart';
import '../widgets/passenger_history_panel.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: const HeaderBar(),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 1000;

                // ============================================================
                // LEFT COLUMN
                // ============================================================

                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard statistics
                    _MetricsRow(app: app),

                    const SizedBox(height: 14),

                    // Current bus route / stop
                    const CurrentRouteBlock(),

                    const SizedBox(height: 14),

                    // Live bus map
                    const LiveMap(),

                    const SizedBox(height: 14),

                    // RFID transaction history
                    const TransactionTable(),

                    const SizedBox(height: 14),

                    const PassengerHistoryPanel(),

                    const SizedBox(height: 14),
                  ],
                );

                // ============================================================
                // RIGHT COLUMN
                // ============================================================

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Admin passenger management
                    PassengerManagementPanel(),

                    SizedBox(height: 14),

                    // RFID cards and wallet management
                    RfidWalletPanel(),

                    SizedBox(height: 14),

                    // Local/offline AI + ML prototype assistant
                    AIAssistantPanel(),

                    SizedBox(height: 14),

                    // Complete route stop list
                    RouteTimeline(),
                  ],
                );

                // ============================================================
                // DESKTOP / WIDE SCREEN
                // ============================================================

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: leftColumn,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        flex: 3,
                        child: rightColumn,
                      ),
                    ],
                  );
                }

                // ============================================================
                // MOBILE / SMALL SCREEN
                // ============================================================

                return Column(
                  children: [
                    leftColumn,

                    const SizedBox(height: 14),

                    rightColumn,
                  ],
                );
              },
            ),
          ),

          // ================================================================
          // SMS / LOGIN / RFID NOTIFICATION BANNER
          // ================================================================

          const SmsBanner(),
        ],
      ),
    );
  }
}

// ============================================================================
// DASHBOARD METRICS
// ============================================================================

class _MetricsRow extends StatelessWidget {
  final AppState app;

  const _MetricsRow({
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          // ================================================================
          // BUS STATUS
          // ================================================================

          MetricCard(
            label: l10n.statusLabel.toUpperCase(),
            value: app.simulatorRunning
                ? l10n.statusMoving.toUpperCase()
                : l10n.statusStopped.toUpperCase(),
            subValue: app.simulatorRunning
                ? '${app.speedKmh.toStringAsFixed(0)} ${l10n.speedKmh}'
                : null,
            icon: Icons.directions_bus_filled,
            accent: app.simulatorRunning
                ? AppColors.green
                : AppColors.textSecondary,
            semanticLabel: l10n.busStatusSemantic(
              app.simulatorRunning
                  ? l10n.statusMoving
                  : l10n.statusStopped,
              app.speedKmh.toStringAsFixed(0),
              app.localizedStopName(app.currentStop.name),
            ),
            liveRegion: true,
          ),

          // ================================================================
          // ONBOARD
          // ================================================================

          MetricCard(
            label: l10n.onboardLabel.toUpperCase(),
            value: '${app.onboardCount}',
            subValue: '/ ${AppState.busCapacity}',
            icon: Icons.people,
            accent: AppColors.blue,
            animatedNumber: app.onboardCount,
          ),

          // ================================================================
          // ENTERED
          // ================================================================

          MetricCard(
            label: l10n.enteredLabel.toUpperCase(),
            value: '${app.enteredCount}',
            icon: Icons.login,
            accent: AppColors.green,
            animatedNumber: app.enteredCount,
          ),

          // ================================================================
          // EXITED
          // ================================================================

          MetricCard(
            label: l10n.exitedLabel.toUpperCase(),
            value: '${app.exitedCount}',
            icon: Icons.logout,
            accent: AppColors.amber,
            animatedNumber: app.exitedCount,
          ),

          MetricCard(
            label: l10n.trafficLabel.toUpperCase(),
            value: app.trafficLevel.name == 'high'
                ? l10n.trafficHigh.toUpperCase()
                : app.trafficLevel.name == 'medium'
                    ? l10n.trafficMedium.toUpperCase()
                    : l10n.trafficLow.toUpperCase(),
            subValue: '${app.onboardCount}/${AppState.busCapacity}',
            icon: Icons.groups_2,
            accent: app.trafficLevel.name == 'high'
                ? AppColors.red
                : app.trafficLevel.name == 'medium'
                    ? AppColors.amber
                    : AppColors.green,
          ),
        ];

        // ================================================================
        // WIDE SCREEN
        // ================================================================

        final wide = constraints.maxWidth > 700;

        if (wide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                  ),
                  child: card,
                ),
              ),
            )
                .toList(),
          );
        }

        // ================================================================
        // MOBILE SCREEN
        // ================================================================

        return GridView.count(
          crossAxisCount: 2,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 12,

          crossAxisSpacing: 12,

          childAspectRatio: 1.6,

          children: cards,
        );
      },
    );
  }
}
