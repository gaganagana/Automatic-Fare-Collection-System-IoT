import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Callback signature the AppState provides so the server can turn an
/// incoming RFID tap into an actual fare decision and reply with
/// APPROVED/DENIED — exactly as described in the hardware-first fare logic.
typedef TapHandler = Map<String, dynamic> Function(String uid);

typedef RechargeHandler = void Function(Map<String, dynamic> payload);

/// Callback for hardware that has ALREADY made its own fare decision
/// on-board (e.g. an Arduino/ESP32 with its own local card database and
/// balance logic) and is simply reporting a finished event so the
/// dashboard's live feed can display it. The server does NOT deduct any
/// balance or re-run fare logic for these — it just displays what the
/// hardware tells it happened, avoiding double-deduction against the
/// app's own separate demo wallets.
typedef HardwareEventHandler = void Function(Map<String, dynamic> payload);

/// Callback for a physical bus reporting its current stop (e.g. after the
/// START/STOP buttons on the Arduino/ESP32 are pressed), so the
/// dashboard's "Current Stop" / live map can reflect the real bus instead
/// of only the on-screen simulator.
typedef StopUpdateHandler = void Function(Map<String, dynamic> payload);

/// Wraps a tiny embedded web server so the physical ESP32 board can POST
/// RFID taps straight into the running Flutter app and get an
/// APPROVED / DENIED decision back in the same request.
class TelemetryServer {
  HttpServer? _server;
  final TapHandler onTap;
  final RechargeHandler? onRechargePush;
  final HardwareEventHandler? onHardwareEvent;
  final StopUpdateHandler? onStopUpdate;

  TelemetryServer({
    required this.onTap,
    this.onRechargePush,
    this.onHardwareEvent,
    this.onStopUpdate,
  });

  bool get isRunning => _server != null;
  int? get boundPort => _server?.port;

  /// Human-readable reason the last start() call failed, if any — shown
  /// directly in the Telemetry panel instead of a silent/console-only
  /// failure (a common source of "why won't the ESP32 connect?" confusion).
  String? lastError;

  /// Tries [port], and if that's already taken (very common after a hot
  /// restart leaves the old server bound, or another app is using it)
  /// automatically retries on the next 5 ports instead of just crashing.
  Future<int?> start({int port = 8080}) async {
    if (_server != null) return _server!.port;
    lastError = null;

    final router = Router();

    // ESP32 -> POST /api/bus/telemetry   body: {"uid":"CAFEBABE"}
    router.post('/api/bus/telemetry', (Request request) async {
      final body = await request.readAsString();
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final uid = (data['uid'] ?? '').toString().toUpperCase();
        if (uid.isEmpty) {
          return Response(400, body: jsonEncode({'status': 'DENIED', 'reason': 'missing uid'}));
        }
        final result = onTap(uid);
        return Response.ok(jsonEncode(result),
            headers: {'content-type': 'application/json'});
      } catch (e) {
        return Response(500, body: jsonEncode({'status': 'DENIED', 'reason': 'server error'}));
      }
    });

    // Simple health check so you can verify the ESP32 can reach the phone.
    router.get('/api/bus/ping', (Request request) {
      return Response.ok(jsonEncode({'status': 'ok', 'time': DateTime.now().toIso8601String()}),
          headers: {'content-type': 'application/json'});
    });

    // Self-contained hardware (own card DB, own balance logic, e.g. your
    // Arduino/ESP32 sketch) -> POST /api/bus/event
    //   body: {"uid","name","type":"ENTRY"|"EXIT"|"DENIED_INVALID"|"DENIED_BALANCE",
    //          "stop","fare","balance"}
    // This only logs/displays — it never touches the app's own wallets, so
    // there's no double-deduction between your hardware's balances and the
    // app's separate demo wallets.
    router.post('/api/bus/event', (Request request) async {
      final body = await request.readAsString();
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        onHardwareEvent?.call(data);
        return Response.ok(jsonEncode({'status': 'ok'}));
      } catch (e) {
        return Response(400, body: jsonEncode({'status': 'error', 'reason': 'bad payload'}));
      }
    });

    // Physical bus reporting its current stop -> POST /api/bus/stop
    //   body: {"stopNum": 3, "stopName": "KR Circle", "moving": true}
    router.post('/api/bus/stop', (Request request) async {
      final body = await request.readAsString();
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        onStopUpdate?.call(data);
        return Response.ok(jsonEncode({'status': 'ok'}));
      } catch (e) {
        return Response(400, body: jsonEncode({'status': 'error', 'reason': 'bad payload'}));
      }
    });

    // Optional: the ESP32 can also be pushed a recharge update (used by the
    // Flutter side after a successful PhonePe/GPay simulated recharge) if
    // you wire your board to expose its own listener. Kept here for the
    // reverse direction described in the spec ("send HTTP call to ESP32").
    // Root POST handler from NodeMCU (postHttp('/', jsonEvent / jsonLegacy))
    router.post('/', (Request request) async {
      final body = await request.readAsString();
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final event = (data['event'] ?? data['type'] ?? '').toString();
        if (event == 'BUS_DEPARTED' || event == 'STOP_ARRIVED' || data.containsKey('stopNum')) {
          onStopUpdate?.call(data);
        } else if (data.containsKey('uid') || event == 'ENTRY' || event == 'EXIT' || event.startsWith('DENIED')) {
          onHardwareEvent?.call(data);
        }
        return Response.ok(jsonEncode({'status': 'ok'}));
      } catch (e) {
        return Response(400, body: jsonEncode({'status': 'error', 'reason': 'bad payload'}));
      }
    });

    router.get('/', (Request request) {
      return Response.ok(jsonEncode({'status': 'ok', 'server': 'SmartBus Telemetry Server'}),
          headers: {'content-type': 'application/json'});
    });

    final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    for (var attempt = 0; attempt < 6; attempt++) {
      final tryPort = port + attempt;
      try {
        _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, tryPort);
        if (attempt > 0) {
          lastError = 'Port $port was busy — started on $tryPort instead. '
              'Update the ESP32 sketch\'s SERVER_PORT to match if you use it.';
        }
        return tryPort;
      } on SocketException catch (e) {
        // Address already in use — try the next port instead of throwing.
        lastError = 'Could not bind to port $tryPort (${e.osError?.message ?? e.message}).';
        continue;
      } catch (e) {
        lastError = 'Failed to start telemetry server: $e';
        return null;
      }
    }
    return null; // exhausted all retry ports
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  /// All local IPv4 addresses of this device, so the app can show its own
  /// WiFi IP directly instead of making the user hunt through phone
  /// Settings -> WiFi -> network details.
  static Future<List<String>> localIpAddresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      return interfaces
          .expand((i) => i.addresses)
          .map((a) => a.address)
          .where((a) => !a.startsWith('169.254')) // skip auto-assigned/no-network addrs
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
