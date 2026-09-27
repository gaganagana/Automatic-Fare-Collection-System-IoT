import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final txs = context.watch<AppState>().transactions;
    final timeFmt = DateFormat('HH:mm:ss');

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, size: 16, color: AppColors.green),
              SizedBox(width: 6),
              Text('LIVE TRANSACTION FEED',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 10),
          _HeaderRow(),
          const Divider(color: AppColors.border, height: 1),
          SizedBox(
            height: 320,
            child: txs.isEmpty
                ? const Center(
                    child: Text('No taps yet — tap a card or start the simulator.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)))
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
                                  color: _typeColor(tx.type).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(tx.type.label,
                                    style: TextStyle(
                                        color: _typeColor(tx.type),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            _cell(tx.stop, flex: 4),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${tx.amount >= 0 ? '+' : ''}₹${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: tx.amount >= 0 ? AppColors.green : AppColors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                            _cell('₹${tx.balanceAfter.toStringAsFixed(2)}', flex: 2),
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
        child: Text(text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: mono ? 'monospace' : null)),
      );
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600);
    return const Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('TIME', style: style)),
          Expanded(flex: 3, child: Text('CARD', style: style)),
          Expanded(flex: 3, child: Text('HOLDER', style: style)),
          Expanded(flex: 2, child: Text('TYPE', style: style)),
          Expanded(flex: 4, child: Text('STOP', style: style)),
          Expanded(flex: 2, child: Text('AMOUNT', style: style)),
          Expanded(flex: 2, child: Text('BALANCE', style: style)),
        ],
      ),
    );
  }
}
