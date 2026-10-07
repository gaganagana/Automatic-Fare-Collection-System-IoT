import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';

/// Admin RFID panel.
///
/// The list is searchable by passenger name or RFID UID so an administrator
/// can quickly find one particular card when there are many passengers.
/// The ACTIVE/INACTIVE switch remains an admin-only control.
class RfidWalletPanel extends StatefulWidget {
  const RfidWalletPanel({super.key});

  @override
  State<RfidWalletPanel> createState() => _RfidWalletPanelState();
}

class _RfidWalletPanelState extends State<RfidWalletPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final allCards = app.wallets.where((w) => !w.isDemo).toList();
    final query = _query.trim().toLowerCase();
    final cards = query.isEmpty
        ? allCards
        : allCards.where((wallet) {
            return wallet.holderName.toLowerCase().contains(query) ||
                wallet.uid.toLowerCase().contains(query);
          }).toList();

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                l10n.rfidWallets,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${cards.length}/${allCards.length}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search makes it practical to select one passenger from a large
          // RFID list instead of manually scanning every card.
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 19),
              hintText: l10n.passengerName,
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              isDense: true,
              filled: true,
              fillColor: AppColors.panelAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.search_off,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.noMatchFound,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...cards.map((w) => _CompactCardRow(wallet: w)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openRegisterSheet(context),
            icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            label: Text(
              l10n.registerNewRfid,
              style: const TextStyle(fontSize: 11),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openRegisterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uidCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.registerNewRfidTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: uidCtrl,
              decoration: InputDecoration(labelText: l10n.cardUidHex),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.holderName),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (uidCtrl.text.trim().isEmpty ||
                      nameCtrl.text.trim().isEmpty) {
                    return;
                  }
                  final error = await ctx.read<AppState>().addWallet(
                    uidCtrl.text.trim(),
                    nameCtrl.text.trim(),
                  );
                  if (!ctx.mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.addCard),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCardRow extends StatelessWidget {
  final dynamic wallet;

  const _CompactCardRow({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: panelDecoration(color: AppColors.panelAlt),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: CircleAvatar(
          radius: 17,
          backgroundColor: wallet.active
              ? (wallet.onboard
                  ? AppColors.green.withValues(alpha: 0.18)
                  : AppColors.blue.withValues(alpha: 0.14))
              : AppColors.red.withValues(alpha: 0.14),
          child: Icon(
            wallet.active
                ? (wallet.onboard ? Icons.directions_bus : Icons.credit_card)
                : Icons.block,
            size: 17,
            color: wallet.active
                ? (wallet.onboard ? AppColors.green : AppColors.blue)
                : AppColors.red,
          ),
        ),
        title: Text(
          wallet.holderName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${wallet.uid} • ₹${wallet.balance.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              wallet.active
                  ? (wallet.onboard ? l10n.cardOnboard : l10n.cardActive)
                  : l10n.cardInactive,
              style: TextStyle(
                color: wallet.active
                    ? (wallet.onboard ? AppColors.green : AppColors.blue)
                    : AppColors.red,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            Switch.adaptive(
              value: wallet.active,
              activeTrackColor: AppColors.green,
              onChanged: (value) async {
                final error = await context.read<AppState>().setCardActive(
                  wallet.uid,
                  value,
                );
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
