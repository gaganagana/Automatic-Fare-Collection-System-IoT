import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// A self-contained "map" of the route. It does NOT need a Google Maps
/// API key or internet tiles — every stop is drawn from the x/y
/// coordinates in mock_data.dart, and the bus icon animates smoothly
/// along the polyline as the simulator advances.
class LiveMap extends StatelessWidget {
  const LiveMap({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                l10n.liveMapTitle,
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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _RoutePainter(
                    stops: app.stops,
                    currentIndex: app.currentStopIndex,
                    progress: app.routeProgress,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<RouteStop> stops;
  final int currentIndex;
  final double progress;

  _RoutePainter({required this.stops, required this.currentIndex, required this.progress});

  Offset _pt(int i, Size size) => Offset(stops[i].x * size.width, stops[i].y * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0E1620);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)), bg);

    final linePaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(_pt(0, size).dx, _pt(0, size).dy);
    for (int i = 1; i < stops.length; i++) {
      path.lineTo(_pt(i, size).dx, _pt(i, size).dy);
    }
    canvas.drawPath(path, linePaint);

    final travelled = Paint()
      ..color = AppColors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final tPath = Path()..moveTo(_pt(0, size).dx, _pt(0, size).dy);
    for (int i = 1; i <= currentIndex; i++) {
      tPath.lineTo(_pt(i, size).dx, _pt(i, size).dy);
    }
    if (currentIndex < stops.length - 1) {
      final a = _pt(currentIndex, size);
      final b = _pt(currentIndex + 1, size);
      tPath.lineTo(a.dx + (b.dx - a.dx) * progress, a.dy + (b.dy - a.dy) * progress);
    }
    canvas.drawPath(tPath, travelled);

    for (int i = 0; i < stops.length; i++) {
      final p = _pt(i, size);
      final isPast = i <= currentIndex;
      canvas.drawCircle(p, 6, Paint()..color = isPast ? AppColors.green : AppColors.border);
      canvas.drawCircle(p, 6, Paint()
        ..color = AppColors.bg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);

      final tp = TextPainter(
        text: TextSpan(
          text: stops[i].id,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p + const Offset(8, -14));
    }

    Offset busPos;
    if (currentIndex < stops.length - 1) {
      final a = _pt(currentIndex, size);
      final b = _pt(currentIndex + 1, size);
      busPos = Offset(a.dx + (b.dx - a.dx) * progress, a.dy + (b.dy - a.dy) * progress);
    } else {
      busPos = _pt(currentIndex, size);
    }
    canvas.drawCircle(busPos, 9, Paint()..color = AppColors.amber.withOpacity(0.25));
    canvas.drawCircle(busPos, 5.5, Paint()..color = AppColors.amber);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.currentIndex != currentIndex || oldDelegate.progress != progress;
}
