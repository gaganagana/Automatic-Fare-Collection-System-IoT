import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';

class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final isKn = app.locale.languageCode == 'kn';
    final isHi = app.locale.languageCode == 'hi';

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route, size: 16, color: AppColors.green),
              const SizedBox(width: 6),
              Text(
                l10n.routeTimelineTitle,
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
          ...List.generate(app.stops.length, (i) {
            final stop = app.stops[i];
            final isHere = i == app.currentStopIndex;
            final isNext = i == app.currentStopIndex + 1;
            final isPast = i < app.currentStopIndex;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHere
                              ? AppColors.green
                              : isPast
                                  ? AppColors.green.withValues(alpha: 0.35)
                                  : AppColors.panelAlt,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isHere ? Colors.black : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (i != app.stops.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: isPast ? AppColors.green.withValues(alpha: 0.4) : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.localizedStopName(stop.name),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isHere ? AppColors.green : AppColors.textPrimary,
                                  ),
                                ),
                                if (isHere)
                                  Text(
                                    isKn ? 'ಇಲ್ಲಿ (ಪ್ರಸ್ತುತ)' : (isHi ? 'यहाँ (वर्तमान)' : 'HERE'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (isNext)
                                  Text(
                                    isKn ? 'ಮುಂದಿನ ನಿಲ್ದಾಣ' : (isHi ? 'अगला स्टॉप' : 'NEXT STOP'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            stop.fare == 0 ? '—' : '₹${stop.fare.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
