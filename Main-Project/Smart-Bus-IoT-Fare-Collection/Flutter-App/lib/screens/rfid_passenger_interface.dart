import 'package:flutter/material.dart';

/// Passenger-facing RFID interface.
///
/// This screen does not replace Firebase Login/Sign Up. It is intended to be
/// opened after a user is authenticated and shows the passenger/card state
/// reported by the hardware bridge. The RFID UID remains the card identifier;
/// Firebase Authentication remains the app account authentication mechanism.
class RfidPassengerInterface extends StatelessWidget {
  final String? uid;
  final String? passengerName;
  final double? balance;
  final String? status;
  final String? entryStop;
  final String? exitStop;
  final double fare;
  final VoidCallback? onRefresh;

  const RfidPassengerInterface({
    super.key,
    this.uid,
    this.passengerName,
    this.balance,
    this.status,
    this.entryStop,
    this.exitStop,
    this.fare = 5.0,
    this.onRefresh,
  });

  bool get hasCard => uid != null && uid!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = (passengerName == null || passengerName!.trim().isEmpty)
        ? 'Passenger'
        : passengerName!;
    final displayBalance = balance ?? 0.0;
    final cardStatus = status ?? (hasCard ? 'Card detected' : 'Waiting for RFID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Passenger'),
        actions: [
          if (onRefresh != null)
            IconButton(
              tooltip: 'Refresh RFID status',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Icon(
                            hasCard ? Icons.contactless : Icons.nfc,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName,
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(cardStatus,
                                  style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(label: 'RFID UID', value: uid ?? 'Tap your card'),
                    _InfoRow(
                      label: 'Balance',
                      value: '₹${displayBalance.toStringAsFixed(2)}',
                    ),
                    _InfoRow(label: 'Fare / stop', value: '₹${fare.toStringAsFixed(2)}'),
                    if (entryStop != null)
                      _InfoRow(label: 'Entry stop', value: entryStop!),
                    if (exitStop != null)
                      _InfoRow(label: 'Exit stop', value: exitStop!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      hasCard ? Icons.check_circle_outline : Icons.nfc,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasCard
                          ? 'RFID card linked to this passenger'
                          : 'Tap your RFID card on the bus reader',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasCard
                          ? 'The hardware can report the card UID and fare event to the app.'
                          : 'After a successful tap, the passenger and wallet details can be displayed here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
