import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';

class CurrentRouteBlock extends StatelessWidget {
  const CurrentRouteBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: panelDecoration(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentStopLabel.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  app.currentStopDisplay == '—'
                      ? '—'
                      : '${app.localizedStopName(app.currentStop.name)} [${app.currentStop.id}]',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: panelDecoration(),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nextStopLabel.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  app.nextStopDisplay == '—'
                      ? '—'
                      : '${app.localizedStopName(app.nextStop.name)}  |  ${app.nextStop.id}',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
