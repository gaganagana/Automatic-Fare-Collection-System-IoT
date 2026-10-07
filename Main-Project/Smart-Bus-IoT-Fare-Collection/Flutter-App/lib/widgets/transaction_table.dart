import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class TransactionTable extends StatelessWidget {
  const TransactionTable({super.key});

  Color _typeColor(TxType t) {
    switch (t) {
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
    final txs = app.transactions;
    final l10n = AppLocalizations.of(context);
    final timeFmt = DateFormat('HH:mm:ss');

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 16, color: AppColors.green),
              const SizedBox(width: 6),
              Text(
                l10n.transactionsTitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HeaderRow(l10n: l10n),
          const Divider(color: AppColors.border, height: 1),
          SizedBox(
            height: 320,
            child: txs.isEmpty
                ? Center(
                    child: Text(
                      l10n.noTransactions,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    itemCount: txs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, i) {
                      final tx = txs[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            _cell(timeFmt.format(tx.time), flex: 2),
                            _cell(tx.uid, flex: 3, mono: true),
                            _cell(tx.holder, flex: 3),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _typeColor(tx.type).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _typeLabel(tx.type, l10n),
                                  style: TextStyle(
                                    color: _typeColor(tx.type),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            _cell(app.localizedStopName(tx.stop), flex: 4),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${tx.amount >= 0 ? '+' : ''}₹${tx.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: tx.amount >= 0 ? AppColors.green : AppColors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
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

  Widget _cell(String text, {int flex = 1, bool mono = false}) => Expanded(
        flex: flex,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      );
}

class _HeaderRow extends StatelessWidget {
  final AppLocalizations l10n;

  const _HeaderRow({required this.l10n});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(l10n.colTime.toUpperCase(), style: style)),
          Expanded(flex: 3, child: Text(l10n.colUid.toUpperCase(), style: style)),
          Expanded(flex: 3, child: Text(l10n.colPassenger.toUpperCase(), style: style)),
          Expanded(flex: 2, child: Text(l10n.colType.toUpperCase(), style: style)),
          Expanded(flex: 4, child: Text(l10n.colStop.toUpperCase(), style: style)),
          Expanded(flex: 2, child: Text(l10n.colAmount.toUpperCase(), style: style)),
        ],
      ),
    );
  }
}
