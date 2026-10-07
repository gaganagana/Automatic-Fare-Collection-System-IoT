import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

class UserSupportAndActions extends StatelessWidget {
  final RfidWallet wallet;
  final String email;

  const UserSupportAndActions({
    super.key,
    required this.wallet,
    required this.email,
  });

  // ============================================================
  // HELP & SUPPORT
  // ============================================================

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'gaganacp2002@gmail.com',
      queryParameters: {
        'subject': 'Smart Bus Support Query',
        'body': '''
Hello Smart Bus Admin,

I need help regarding my Smart Bus card.

Card: ${wallet.uid}
Passenger: ${wallet.holderName}

Issue:


Thank you.
''',
      },
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the email application.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // RAZORPAY TEST MODE RECHARGE
  // ============================================================

  void _openRecharge(BuildContext context) {
    final amountController = TextEditingController(text: '100');

    // Provider is required for context.read<AppState>().
    final app = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECHARGE SMART CARD',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Razorpay TEST MODE • No real money is charged.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // QUICK AMOUNT BUTTONS
                  // ------------------------------------------------

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [50, 100, 200, 500].map(
                          (amount) {
                        return ChoiceChip(
                          label: Text('₹$amount'),
                          selected:
                          amountController.text == '$amount',
                          onSelected: (_) {
                            amountController.text = '$amount';
                            setState(() {});
                          },
                        );
                      },
                    ).toList(),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // CUSTOM AMOUNT
                  // ------------------------------------------------

                  TextField(
                    controller: amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Recharge amount',
                      prefixText: '₹ ',
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // PAY BUTTONS
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      label: const Text(
                        'INSTANT RECHARGE (DEMO / UPI)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final amount = double.tryParse(
                          amountController.text.trim(),
                        ) ??
                            0;

                        if (amount < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Minimum recharge is ₹10.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(sheetContext).pop();
                        app.recharge(wallet.uid, amount);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recharge of ₹${amount.toStringAsFixed(0)} successful!'),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.payment),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.blue),
                        foregroundColor: AppColors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      label: const Text(
                        'PAY WITH RAZORPAY TEST MODE',
                      ),
                      onPressed: () {
                        final amount = double.tryParse(
                          amountController.text.trim(),
                        ) ??
                            0;

                        if (amount < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Minimum recharge is ₹10.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Close recharge sheet.
                        Navigator.of(sheetContext).pop();

                        // Start Razorpay test payment.
                        app.startRazorpayRecharge(
                          uid: wallet.uid,
                          holderName: wallet.holderName,
                          amount: amount,
                          contactEmail: email,
                          onFailed: (message) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Recharge not completed: $message',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications(BuildContext context) {
    final app = context.read<AppState>();

    final items = app.currentUserNotifications;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height:
            MediaQuery.of(sheetContext).size.height * .72,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  const Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: AppColors.green,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'NOTIFICATIONS',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // NOTIFICATION LIST
                  // ------------------------------------------------

                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                      child: Text(
                        'No notifications yet.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                        : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const Divider(
                        color: AppColors.border,
                      ),
                      itemBuilder: (_, index) {
                        final tx = items[index];

                        String title;

                        if (tx.type == TxType.recharge) {
                          title = 'Recharge successful';
                        } else if (tx.type == TxType.exit) {
                          title = 'Journey completed';
                        } else if (tx.type ==
                            TxType.denied) {
                          if (tx.reason == 'LOW_BALANCE') {
                            title =
                            'Low balance — access denied';
                          } else {
                            title =
                            'Invalid card — access denied';
                          }
                        } else {
                          title = 'Bus entry recorded';
                        }

                        final date =
                        tx.time.day.toString().padLeft(
                          2,
                          '0',
                        );

                        final month =
                        tx.time.month.toString().padLeft(
                          2,
                          '0',
                        );

                        final hour =
                        tx.time.hour.toString().padLeft(
                          2,
                          '0',
                        );

                        final minute =
                        tx.time.minute.toString().padLeft(
                          2,
                          '0',
                        );

                        return ListTile(
                          leading: Icon(
                            tx.type == TxType.denied
                                ? Icons.warning_amber_rounded
                                : Icons.notifications_none,
                            color:
                            tx.type == TxType.denied
                                ? AppColors.red
                                : AppColors.green,
                          ),

                          title: Text(title),

                          subtitle: Text(
                            '${tx.stop} • '
                                '$date/$month '
                                '$hour:$minute',
                          ),

                          trailing: tx.type == TxType.recharge
                              ? Text(
                            '+₹${tx.amount.toStringAsFixed(0)}',
                          )
                              : tx.type == TxType.exit
                              ? Text(
                            '₹${tx.amount.abs().toStringAsFixed(0)}',
                          )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CARD LOCK / UNLOCK (ACTIVATE / INACTIVATE)
  // ============================================================

  void _toggleCardStatus(BuildContext context) {
    final app = context.read<AppState>();
    final isCurrentlyActive = wallet.active;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              Icon(
                isCurrentlyActive ? Icons.lock_outline : Icons.lock_open,
                color: isCurrentlyActive ? AppColors.red : AppColors.green,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isCurrentlyActive ? 'Deactivate Card (Lost Card)' : 'Activate Smart Card',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            isCurrentlyActive
                ? 'If you lost your card or want to prevent unauthorized usage, deactivating will immediately notify the bus gate system to block entry (red light and denied sound) until reactivated.'
                : 'Do you want to reactivate card (${wallet.uid}) for automated smart bus travel? Once activated, the bus gate will accept taps (green light and welcome sound).',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isCurrentlyActive ? AppColors.red : AppColors.green,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final error = await app.setCardActive(wallet.uid, !isCurrentlyActive);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: AppColors.red),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isCurrentlyActive ? 'Card deactivated (Lost). Bus gate will deny entry.' : 'Card activated successfully! Gate will permit entry.'),
                      backgroundColor: isCurrentlyActive ? AppColors.red : AppColors.green,
                    ),
                  );
                }
              },
              child: Text(isCurrentlyActive ? 'Deactivate Card' : 'Activate Card'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // --------------------------------------------------------
        // SIMULATE RFID TAP (ENTRY / EXIT)
        // --------------------------------------------------------

        FilledButton.tonalIcon(
          onPressed: () {
            final app = context.read<AppState>();
            final wasOnboard = wallet.onboard;
            final res = app.simulatePassengerTap(wallet.uid);
            if (!context.mounted) return;
            if (res != null && res['status'] == 'error') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res['error']?.toString() ?? 'Simulation error'),
                  backgroundColor: AppColors.red,
                ),
              );
            } else if (res != null && res['status'] == 'DENIED') {
              final reason = res['reason'];
              final message = reason == 'insufficient_balance'
                  ? '🔴 Access Denied: Low Balance (< ₹10). Please recharge before travel!'
                  : (reason == 'card_inactive'
                      ? '🔴 Access Denied: Card is Inactive / Blocked. Please activate your card!'
                      : '🔴 Access Denied: Unregistered card.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !wasOnboard
                        ? '🟢 Card scanned: Entered bus at ${app.currentStop.name}! Fare is ₹10/stop, charged upon exit.'
                        : '🏁 Card scanned: Exited bus at ${app.currentStop.name}! Fare deducted at ₹10/stop.',
                  ),
                  backgroundColor: !wasOnboard ? AppColors.blue : AppColors.green,
                ),
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: wallet.onboard ? AppColors.amber.withOpacity(0.18) : AppColors.green.withOpacity(0.18),
            foregroundColor: wallet.onboard ? AppColors.amber : AppColors.green,
          ),
          icon: Icon(
            wallet.onboard ? Icons.logout : Icons.login,
            size: 18,
          ),
          label: Text(
            wallet.onboard ? 'Simulate Exit Tap' : 'Simulate Entry Tap',
          ),
        ),

        // --------------------------------------------------------
        // RECHARGE
        // --------------------------------------------------------

        FilledButton.icon(
          onPressed: () {
            _openRecharge(context);
          },
          icon: const Icon(
            Icons.add_card,
            size: 18,
          ),
          label: const Text(
            'Recharge Card',
          ),
        ),

        // --------------------------------------------------------
        // ACTIVATE / INACTIVATE (LOCK / UNLOCK)
        // --------------------------------------------------------

        OutlinedButton.icon(
          onPressed: () {
            _toggleCardStatus(context);
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: wallet.active ? AppColors.red : AppColors.green,
              width: 1.2,
            ),
            foregroundColor: wallet.active ? AppColors.red : AppColors.green,
          ),
          icon: Icon(
            wallet.active ? Icons.lock_outline : Icons.lock_open,
            size: 18,
          ),
          label: Text(
            wallet.active ? 'Deactivate Card (Lost)' : 'Activate Card',
          ),
        ),

        // --------------------------------------------------------
        // NOTIFICATIONS
        // --------------------------------------------------------

        OutlinedButton.icon(
          onPressed: () {
            _showNotifications(context);
          },
          icon: const Icon(
            Icons.notifications_none,
            size: 18,
          ),
          label: const Text(
            'Notifications',
          ),
        ),

        // --------------------------------------------------------
        // HELP & SUPPORT
        // --------------------------------------------------------

        OutlinedButton.icon(
          onPressed: () {
            _emailSupport(context);
          },
          icon: const Icon(
            Icons.mail_outline,
            size: 18,
          ),
          label: const Text(
            'Help & Support',
          ),
        ),
      ],
    );
  }
}