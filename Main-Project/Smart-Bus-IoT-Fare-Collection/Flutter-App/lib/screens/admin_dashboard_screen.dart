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
import '../widgets/route_timeline.dart';
import '../widgets/sms_banner.dart';
import '../widgets/telemetry_panel.dart';
import '../widgets/transaction_table.dart';

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
                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricsRow(app: app),
                    const SizedBox(height: 14),
                    const CurrentRouteBlock(),
                    const SizedBox(height: 14),
                    const LiveMap(),
                    const SizedBox(height: 14),
                    const TransactionTable(),
                    const SizedBox(height: 14),
                    const _DebugTapPanel(),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    TelemetryPanel(),
                    SizedBox(height: 14),
                    RfidWalletPanel(),
                    SizedBox(height: 14),
                    RouteTimeline(),
                  ],
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: leftColumn),
                      const SizedBox(width: 16),
                      Expanded(flex: 3, child: rightColumn),
                    ],
                  );
                }
                return Column(children: [leftColumn, const SizedBox(height: 14), rightColumn]);
              },
            ),
          ),
          const SmsBanner(),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final AppState app;
  const _MetricsRow({required this.app});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(builder: (context, constraints) {
      final cards = [
        MetricCard(
          label: 'STATUS',
          value: app.simulatorRunning ? 'MOVING' : 'STOPPED',
          subValue: app.simulatorRunning ? '${app.speedKmh.toStringAsFixed(0)} km/h' : null,
          icon: Icons.directions_bus_filled,
          accent: app.simulatorRunning ? AppColors.green : AppColors.textSecondary,
          // This is the "make a bus status widget speak its current state
          // when selected by TalkBack" requirement: excludeSemantics (set
          // inside MetricCard) hides the raw "MOVING" / "28 km/h" text
          // nodes and replaces them with one purpose-written sentence.
          // liveRegion means TalkBack re-announces it automatically every
          // time speed/stop changes, without the user re-selecting it.
          semanticLabel: l10n.busStatusSemantic(
            app.simulatorRunning ? l10n.statusMoving : l10n.statusStopped,
            app.speedKmh.toStringAsFixed(0),
            app.currentStop.name,
          ),
          liveRegion: true,
        ),
        MetricCard(
          label: 'ONBOARD',
          value: '${app.onboardCount}',
          subValue: '/ ${AppState.busCapacity}',
          icon: Icons.people,
          accent: AppColors.blue,
          animatedNumber: app.onboardCount,
        ),
        MetricCard(
          label: 'ENTERED',
          value: '${app.enteredCount}',
          icon: Icons.login,
          accent: AppColors.green,
          animatedNumber: app.enteredCount,
        ),
        MetricCard(
          label: 'EXITED',
          value: '${app.exitedCount}',
          icon: Icons.logout,
          accent: AppColors.amber,
          animatedNumber: app.exitedCount,
        ),
      ];
      final wide = constraints.maxWidth > 700;
      if (wide) {
        return Row(
          children: cards
              .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
              .toList(),
        );
      }
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: cards,
      );
    });
  }
}

/// Lets you demo the whole tap -> APPROVED/DENIED -> fare -> SMS flow
/// straight from the dashboard, without a physical ESP32 connected.
class _DebugTapPanel extends StatelessWidget {
  const _DebugTapPanel();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SIMULATE RFID TAP (no hardware needed)',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: app.wallets.map((w) {
              return OutlinedButton(
                onPressed: () => context.read<AppState>().simulateTap(w.uid),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: w.onboard ? AppColors.green : AppColors.border),
                  foregroundColor: AppColors.textPrimary,
                ),
                child: Text('${w.holderName} (${w.onboard ? "tap out" : "tap in"})',
                    style: const TextStyle(fontSize: 11)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
