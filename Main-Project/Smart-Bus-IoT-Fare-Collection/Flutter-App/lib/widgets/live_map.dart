import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Real Google Maps view of the bus route, replacing the earlier
/// dependency-free schematic map. Needs a Google Maps API key — see
/// SETUP_GUIDE.md section 10 for how to get one and where to put it.
///
/// Draws: a grey polyline for the full route, a green polyline for the
/// travelled portion, a marker at every stop, and an amber marker for the
/// bus itself that smoothly interpolates its real lat/lng between the
/// current and next stop as AppState.routeProgress advances — the same
/// animation the old schematic map did, just against real coordinates now.
class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  GoogleMapController? _controller;
  bool _fitted = false;

  LatLng _stopLatLng(RouteStop s) => LatLng(s.lat, s.lng);

  LatLng _busPosition(AppState app) {
    final current = app.stops[app.currentStopIndex];
    if (app.currentStopIndex >= app.stops.length - 1) return _stopLatLng(current);
    final next = app.stops[app.currentStopIndex + 1];
    final t = app.routeProgress;
    return LatLng(
      current.lat + (next.lat - current.lat) * t,
      current.lng + (next.lng - current.lng) * t,
    );
  }

  void _fitToRoute(AppState app) {
    if (_controller == null || _fitted || app.stops.isEmpty) return;
    final lats = app.stops.map((s) => s.lat);
    final lngs = app.stops.map((s) => s.lng);
    final bounds = LatLngBounds(
      southwest: LatLng(lats.reduce((a, b) => a < b ? a : b), lngs.reduce((a, b) => a < b ? a : b)),
      northeast: LatLng(lats.reduce((a, b) => a > b ? a : b), lngs.reduce((a, b) => a > b ? a : b)),
    );
    _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
    _fitted = true;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final busPos = _busPosition(app);

    final routePoints = app.stops.map(_stopLatLng).toList();
    final travelledPoints = [
      ...app.stops.take(app.currentStopIndex + 1).map(_stopLatLng),
      busPos,
    ];

    final markers = <Marker>{
      for (final s in app.stops)
        Marker(
          markerId: MarkerId(s.id),
          position: _stopLatLng(s),
          infoWindow: InfoWindow(title: '${s.name} (${s.id})'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            app.stops.indexOf(s) <= app.currentStopIndex
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueAzure,
          ),
        ),
      Marker(
        markerId: const MarkerId('bus'),
        position: busPos,
        infoWindow: const InfoWindow(title: 'Bus-01'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        zIndex: 2,
      ),
    };

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map_outlined, size: 16, color: AppColors.blue),
              SizedBox(width: 6),
              Text('LIVE BUS LOCATION',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: routePoints.first, zoom: 12.5),
                onMapCreated: (c) {
                  _controller = c;
                  _fitToRoute(app);
                },
                markers: markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('full-route'),
                    points: routePoints,
                    color: AppColors.border,
                    width: 3,
                  ),
                  Polyline(
                    polylineId: const PolylineId('travelled'),
                    points: travelledPoints,
                    color: AppColors.green,
                    width: 4,
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
