import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';

class PassengerManagementPanel extends StatefulWidget {
  const PassengerManagementPanel({super.key});

  @override
  State<PassengerManagementPanel> createState() => _PassengerManagementPanelState();
}

class _PassengerManagementPanelState extends State<PassengerManagementPanel> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final query = _search.text.trim().toLowerCase();

    // Combine registered accounts with active wallet passenger records.
    final registeredUids = app.passengers.map((p) => p.linkedUid?.toUpperCase()).toSet();
    final walletPassengers = app.wallets
        .where((w) => !registeredUids.contains(w.uid.toUpperCase()))
        .map((w) {
          final cleanName = w.holderName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '.');
          return UserAccount(
            uid: 'acc-${w.uid}',
            username: w.holderName,
            email: '$cleanName@smartbus.in',
            role: UserRole.passenger,
            linkedUid: w.uid,
          );
        })
        .toList();

    final all = [...app.passengers, ...walletPassengers];
    final filtered = query.isEmpty
        ? all
        : all.where((p) =>
            p.username.toLowerCase().contains(query) ||
            (p.linkedUid ?? '').toLowerCase().contains(query) ||
            p.email.toLowerCase().contains(query)).toList();

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(l10n.passengerManagement, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12,
                fontWeight: FontWeight.w600, letterSpacing: 1.2,
              )),
              const Spacer(),
              Text('${filtered.length} records', style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.searchPassengerUid,
              prefixIcon: const Icon(Icons.search, size: 17),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () { _search.clear(); setState(() {}); },
                    ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.noPassengerRecords,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            )
          else
            ...filtered.map((p) => _PassengerRow(
                  passenger: p,
                )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openAddPassenger(context),
            icon: const Icon(Icons.person_add_alt_1, size: 16),
            label: Text(l10n.addPassengerButton, style: const TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddPassenger(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController(text: '123456');
    final uid = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.addPassenger, style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter passenger details and RFID Card UID to automatically provision their account and wallet.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              TextField(controller: name, decoration: InputDecoration(labelText: l10n.passengerName)),
              const SizedBox(height: 10),
              TextField(controller: email, keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.emailLabel)),
              const SizedBox(height: 10),
              TextField(controller: password, obscureText: true,
                  decoration: InputDecoration(labelText: l10n.temporaryPassword)),
              const SizedBox(height: 10),
              TextField(controller: uid, textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.registeredRfidUid)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: saving ? null : () async {
                  if (name.text.trim().isEmpty || email.text.trim().isEmpty ||
                      password.text.trim().length < 6 || uid.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.enterValidPassengerDetails)));
                    return;
                  }
                  setSheetState(() => saving = true);
                  final error = await context.read<AppState>().addPassenger(
                    username: name.text, email: email.text, password: password.text, linkedUid: uid.text,
                  );
                  if (!ctx.mounted) return;
                  setSheetState(() => saving = false);
                  if (error != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(error)));
                  } else {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passengerAdded)));
                  }
                },
                child: saving ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(l10n.addPassengerButton),
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final UserAccount passenger;
  const _PassengerRow({required this.passenger});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final walletIndex = passenger.linkedUid == null
        ? -1
        : app.wallets.indexWhere((w) => w.uid.toUpperCase() == passenger.linkedUid!.toUpperCase());
    final wallet = walletIndex >= 0 ? app.wallets[walletIndex] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: panelDecoration(color: AppColors.panelAlt),
      child: Row(children: [
        CircleAvatar(radius: 16, child: Text(
          passenger.username.isEmpty ? '?' : passenger.username[0].toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(passenger.username, style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
          Text('${passenger.email} • RFID ${passenger.linkedUid ?? l10n.notLinked}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (wallet != null)
            Text('${l10n.balanceLabel} ₹${wallet.balance.toStringAsFixed(0)}  •  ${wallet.active ? l10n.cardActive : l10n.cardInactive}',
              style: TextStyle(color: wallet.active ? AppColors.green : AppColors.red,
                  fontSize: 9, fontWeight: FontWeight.w600)),
        ])),
        if (passenger.linkedUid != null) ...[
          Switch.adaptive(
            value: wallet?.active ?? true,
            activeTrackColor: AppColors.green,
            onChanged: (val) async {
              final error = await context.read<AppState>().setCardActive(
                passenger.linkedUid!,
                val,
              );
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
          ),
          const SizedBox(width: 4),
        ],
        IconButton(
          tooltip: l10n.deletePassenger,
          icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 19),
          onPressed: () => _delete(context),
        ),
      ]),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.deletePassenger), content: Text(l10n.confirmDeletePassenger(passenger.username)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.delete)),
      ],
    ));
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<AppState>().deletePassenger(passenger);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
