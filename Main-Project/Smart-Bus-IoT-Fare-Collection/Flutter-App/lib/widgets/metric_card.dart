import 'package:flutter/material.dart';
import '../theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color accent;

  /// If provided, the big value animates as a smooth count-up/down instead
  /// of jumping instantly — used for ONBOARD/ENTERED/EXITED. Leave null
  /// for text values like "MOVING"/"STOPPED" (STATUS), which crossfade
  /// instead since there's nothing numeric to count between.
  final int? animatedNumber;

  /// Accessibility: the full sentence TalkBack/VoiceOver reads out when
  /// this card is selected, e.g. "Bus status: Moving, speed 28 kilometers
  /// per hour, currently at Kempegowda Bus Station". Pass null to fall
  /// back to Flutter's default behavior of reading the visible text nodes
  /// (label + value) — fine for simple cards like ENTERED/EXITED, but the
  /// STATUS card benefits from a purpose-written sentence since its raw
  /// text ("MOVING", "28 km/h") reads awkwardly out of context.
  final String? semanticLabel;

  /// Marks this card as a "live region" for screen readers — meaning
  /// TalkBack automatically re-announces it whenever [semanticLabel]
  /// changes, without the user needing to re-select it. Use this for
  /// values that update on their own (like bus status), not for values
  /// that only change from a direct user action.
  final bool liveRegion;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subValue,
    this.accent = AppColors.green,
    this.animatedNumber,
    this.semanticLabel,
    this.liveRegion = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: panelDecoration().copyWith(
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (animatedNumber != null)
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: animatedNumber),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) => Text('$val',
                      style: TextStyle(
                          color: accent,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(value,
                      key: ValueKey(value),
                      style: TextStyle(
                          color: accent,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ),
              if (subValue != null) ...[
                const SizedBox(width: 6),
                Text(subValue!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]
            ],
          ),
        ],
      ),
    );

    if (semanticLabel == null) return card;

    // excludeSemantics hides the raw child text nodes from the accessibility
    // tree so TalkBack reads ONLY our curated sentence, not the sentence
    // AND the raw "MOVING" / "28 km/h" text underneath (which would read
    // twice, once per node, and sound broken).
    return Semantics(
      label: semanticLabel,
      liveRegion: liveRegion,
      excludeSemantics: true,
      child: card,
    );
  }
}
