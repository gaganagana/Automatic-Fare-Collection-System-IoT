
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme.dart';

class TravelAnalyticsPanel extends StatelessWidget {
  const TravelAnalyticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final completed = app.transactions.where((t) => t.type == TxType.exit).toList();
    final denied = app.transactions.where((t) => t.type == TxType.denied).toList();
    final totalFare = completed.fold<double>(0, (sum, t) => sum + t.amount.abs());
    final avgStops = completed.isEmpty
        ? 0
        : completed.fold<int>(0, (sum, t) => sum + (t.stopsTravelled ?? 0)) / completed.length;

    final stopCounts = <String, int>{};
    for (final tx in completed) {
      final app = context.read<AppState>();
      final name = app.localizedStopName(tx.exitStop ?? tx.stop);
      stopCounts[name] = (stopCounts[name] ?? 0) + 1;
    }
    final popular = stopCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, size: 17, color: AppColors.amber),
              SizedBox(width: 7),
              Text(
                'TRAVEL ANALYTICS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Spacer(),
              Text('PROTOTYPE', style: TextStyle(color: AppColors.textSecondary, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric('Completed', '${completed.length}'),
              _Metric('Denied', '${denied.length}'),
              _Metric('Fare', '₹${totalFare.toStringAsFixed(0)}'),
              _Metric('Avg. stops', avgStops.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            popular.isEmpty
                ? 'No completed journeys yet.'
                : 'Most used exit: ${popular.first.key} (${popular.first.value} trip${popular.first.value == 1 ? '' : 's'})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 5),
          const Text(
            'Analytics are calculated from the available Firestore + prototype transaction data.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
    width: 105,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.panelAlt,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
