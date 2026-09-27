import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/header_bar.dart';
import '../widgets/sms_banner.dart';

class PassengerScreen extends StatelessWidget {
  const PassengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final uid = app.currentUser?.linkedUid;
    final wallet = app.wallets.where((w) => w.uid == uid).cast<RfidWallet?>().firstOrNull;
    final history = app.transactions.where((t) => t.uid == uid).toList();

    return Scaffold(
      appBar: const HeaderBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wallet == null)
                    const Text('No card linked to this account.',
                        style: TextStyle(color: AppColors.textSecondary))
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: panelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MY SMART CARD',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2)),
                          const SizedBox(height: 10),
                          Text(wallet.holderName,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(wallet.uid,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontFamily: 'monospace')),
                          const SizedBox(height: 16),
                          Text('₹${wallet.balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.green, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(wallet.onboard ? 'Status: Currently onboard' : 'Status: Not on a trip',
                              style: TextStyle(
                                  color: wallet.onboard ? AppColors.blue : AppColors.textSecondary,
                                  fontSize: 12)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _openRechargeSheet(context, wallet.uid),
                              child: const Text('RECHARGE MY CARD'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('MY TRIP HISTORY',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    if (history.isEmpty)
                      const Text('No transactions yet.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
                    else
                      ...history.map((t) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: panelDecoration(color: AppColors.panelAlt),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.type.label,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text('${t.stop} · ${DateFormat('dd MMM, HH:mm').format(t.time)}',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${t.amount >= 0 ? '+' : ''}₹${t.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: t.amount >= 0 ? AppColors.green : AppColors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                  ],
                ],
              ),
            ),
          ),
          const SmsBanner(),
        ],
      ),
    );
  }

  void _openRechargeSheet(BuildContext context, String uid) {
    final amountCtrl = TextEditingController(text: '100');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recharge Card', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  await ctx.read<AppState>().recharge(uid, amount);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('PAY & RECHARGE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
