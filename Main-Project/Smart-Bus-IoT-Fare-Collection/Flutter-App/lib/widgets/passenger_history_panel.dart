import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Admin passenger activity/history view.
class PassengerHistoryPanel extends StatelessWidget {
  const PassengerHistoryPanel({super.key});

  Color _typeColor(TxType type) {
    switch (type) {
      case TxType.boarding:
        return AppColors.blue;
      case TxType.exit:
        return AppColors.amber;
      case TxType.recharge:
        return AppColors.green;
      case TxType.denied:
        return AppColors.red;
    }
  }

  String _typeLabel(TxType t, AppLocalizations l10n) {
    switch (t) {
      case TxType.boarding:
        return l10n.typeBoarding;
      case TxType.exit:
        return l10n.typeExit;
      case TxType.recharge:
        return l10n.typeRecharge;
      case TxType.denied:
        return l10n.typeDenied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final items = app.transactions.take(24).toList();
    final fmt = DateFormat('dd MMM • HH:mm');
    final onboard = app.wallets.where((w) => !w.isDemo && w.onboard).toList();

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.amber),
              const SizedBox(width: 6),
              Text(
                l10n.passengerHistoryTitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (onboard.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_bus, size: 16, color: AppColors.green),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${l10n.cardOnboard}  •  ${onboard.length}',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...onboard.take(4).map((w) => Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.green.withValues(alpha: 0.16),
                      child: Text(
                        w.holderName.isEmpty ? '?' : w.holderName[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(l10n.noTransactions, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            )
          else
            SizedBox(
              height: 360,
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                itemBuilder: (_, index) {
                  final tx = items[index];
                  final color = _typeColor(tx.type);
                  final route = tx.type == TxType.exit && tx.entryStop != null
                      ? '${app.localizedStopName(tx.entryStop)} → ${app.localizedStopName(tx.exitStop ?? tx.stop)}'
                      : app.localizedStopName(tx.stop);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            tx.type == TxType.boarding
                                ? Icons.login
                                : tx.type == TxType.exit
                                    ? Icons.logout
                                    : tx.type == TxType.recharge
                                        ? Icons.add_card
                                        : Icons.block,
                            color: color,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tx.holder,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(fmt.format(tx.time), style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_typeLabel(tx.type, l10n)}  •  $route',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
                              ),
                              if (tx.type == TxType.exit && tx.stopsTravelled != null)
                                Text(
                                  '${tx.stopsTravelled}  •  ₹${tx.amount.abs().toStringAsFixed(0)}  •  ₹${tx.balanceAfter.toStringAsFixed(0)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                                )
                              else if (tx.type == TxType.recharge)
                                Text(
                                  '+₹${tx.amount.toStringAsFixed(0)}  •  ₹${tx.balanceAfter.toStringAsFixed(0)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                                )
                              else if (tx.type == TxType.denied)
                                Text(
                                  '${l10n.typeDenied} • ${tx.reason ?? 'UNKNOWN'}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
