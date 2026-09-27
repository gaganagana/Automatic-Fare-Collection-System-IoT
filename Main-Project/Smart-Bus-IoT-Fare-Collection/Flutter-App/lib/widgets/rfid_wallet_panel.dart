import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class RfidWalletPanel extends StatelessWidget {
  const RfidWalletPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card, size: 16, color: AppColors.blue),
              SizedBox(width: 6),
              Text('RFID WALLETS',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 10),
          ...app.wallets.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WalletCard(
                  uid: w.uid,
                  holderName: w.holderName,
                  balance: w.balance,
                  onboard: w.onboard,
                  onRecharge: () => _openRechargeSheet(context, w.uid, w.holderName),
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openRegisterSheet(context),
            icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            label: const Text('REGISTER NEW RFID', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openRechargeSheet(BuildContext context, String uid, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _RechargeSheet(uid: uid, name: name),
    );
  }

  void _openRegisterSheet(BuildContext context) {
    final uidCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
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
            const Text('Register New RFID Card',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: uidCtrl,
              decoration: const InputDecoration(labelText: 'Card UID (Hex)'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Holder Name'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (uidCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
                  ctx.read<AppState>().addWallet(uidCtrl.text.trim(), nameCtrl.text.trim());
                  Navigator.of(ctx).pop();
                },
                child: const Text('ADD CARD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single RFID wallet rendered like a real transit/bank card — gradient
/// face, chip + contactless icons, masked card number — instead of a plain
/// list row. Presses scale down slightly for tactile feedback, matching
/// how payment apps (PhonePe, GPay, bank apps) treat tappable cards.
class _WalletCard extends StatefulWidget {
  final String uid;
  final String holderName;
  final double balance;
  final bool onboard;
  final VoidCallback onRecharge;

  const _WalletCard({
    required this.uid,
    required this.holderName,
    required this.balance,
    required this.onboard,
    required this.onRecharge,
  });

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _pressed = false;

  // Deterministic gradient per card, based on the UID, so the same card
  // always renders the same colour (not random on every rebuild) while
  // different cards look visually distinct — like real bank cards do.
  List<Color> get _gradient {
    const palettes = [
      [Color(0xFF0F6E56), Color(0xFF0A4F3E)], // teal
      [Color(0xFF185FA5), Color(0xFF0C3A66)], // blue
      [Color(0xFF534AB7), Color(0xFF352E7A)], // purple
      [Color(0xFF993C1D), Color(0xFF6B2A13)], // coral
    ];
    final idx = widget.uid.codeUnits.fold<int>(0, (a, b) => a + b) % palettes.length;
    return palettes[idx];
  }

  String get _maskedUid {
    if (widget.uid.length <= 4) return widget.uid;
    return '\u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  ${widget.uid.substring(widget.uid.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onRecharge();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradient,
            ),
            border: widget.onboard
                ? Border.all(color: AppColors.green, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: _gradient.first.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // chip icon
                  Container(
                    width: 30,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.memory, size: 14, color: Color(0xFF333333)),
                  ),
                  const Spacer(),
                  if (widget.onboard)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('ONBOARD',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 18, color: Colors.white70), // contactless glyph, rotated by eye via icon shape
                ],
              ),
              const SizedBox(height: 16),
              Text(_maskedUid,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontFamily: 'monospace', letterSpacing: 1.5)),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.holderName.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text('\u20b9${widget.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('RECHARGE',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RechargeSheet extends StatefulWidget {
  final String uid;
  final String name;
  const _RechargeSheet({required this.uid, required this.name});

  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  final amountCtrl = TextEditingController(text: '100');
  String method = 'PhonePe';
  bool loading = false;
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recharge — ${widget.name}',
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.uid,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
          const SizedBox(height: 16),
          if (success) ...[
            const SizedBox(height: 12),
            Center(child: _SuccessCheck()),
            const SizedBox(height: 12),
            const Center(
              child: Text('Recharge successful',
                  style: TextStyle(
                      color: AppColors.green, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ] else if (loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator(color: AppColors.green)),
            const SizedBox(height: 12),
            const Center(
              child: Text('Initiating PhonePe SDK Handshake...',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
            const SizedBox(height: 24),
          ] else ...[
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _methodChip('PhonePe', Icons.account_balance_wallet),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _methodChip('Google Pay', Icons.payment),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  HapticFeedback.mediumImpact();
                  setState(() => loading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (!mounted) return;
                  await context.read<AppState>().recharge(widget.uid, amount);
                  if (!mounted) return;
                  HapticFeedback.heavyImpact();
                  setState(() {
                    loading = false;
                    success = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 900));
                  if (mounted) Navigator.of(context).pop();
                },
                child: const Text('PAY & RECHARGE'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _methodChip(String label, IconData icon) {
    final selected = method == label;
    return GestureDetector(
      onTap: () => setState(() => method = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green.withOpacity(0.15) : AppColors.panelAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.green : AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.green : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: selected ? AppColors.green : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// A checkmark that pops in with a bouncy scale — used right after a
/// recharge succeeds instead of just silently closing the sheet.
class _SuccessCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: glow(AppColors.green, blur: 20, opacity: 0.35),
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.green, size: 36),
        ),
      ),
    );
  }
}
