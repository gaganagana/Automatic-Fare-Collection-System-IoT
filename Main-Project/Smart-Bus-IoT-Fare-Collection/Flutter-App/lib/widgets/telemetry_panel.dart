import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class TelemetryPanel extends StatefulWidget {
  const TelemetryPanel({super.key});

  @override
  State<TelemetryPanel> createState() => _TelemetryPanelState();
}

class _TelemetryPanelState extends State<TelemetryPanel> {
  late TextEditingController ipCtrl;

  @override
  void initState() {
    super.initState();
    ipCtrl = TextEditingController(text: context.read<AppState>().esp32Ip);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.telemetry;

    return Container(
      decoration: panelDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors, size: 16, color: AppColors.amber),
              SizedBox(width: 6),
              Text('TELEMETRY SOURCE',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          _statusRow('ESP32 -> /api/bus/telemetry', t.esp32Connected),
          _statusRow('GPS — prototype only', t.gpsOk),
          _statusRow('IR Passenger Counter', t.irOk),
          const SizedBox(height: 8),
          const Text(
            'Prototype note: this project uses a fixed/schematic route; real GPS movement is not required.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 12),
          Text(
            'Server: 0.0.0.0:${app.serverPort}${app.telemetryServer.isRunning ? '  (running)' : '  (stopped — tap Start Simulator once)'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          if (app.telemetryServer.lastError != null) ...[
            const SizedBox(height: 6),
            Text(app.telemetryServer.lastError!,
                style: const TextStyle(color: AppColors.amber, fontSize: 11)),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text('THIS DEVICE\'S IP  (put this in SERVER_HOST on the ESP32)',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6)),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: () async {
                  await app.refreshLocalIps();
                },
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (app.localIps.isEmpty)
            const Text('No WiFi IP detected yet — make sure this device is on WiFi, then tap refresh.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11))
          else
            ...app.localIps.map((ip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(ip,
                          style: const TextStyle(
                              color: AppColors.green, fontSize: 13, fontFamily: 'monospace')),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: ip));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied $ip')),
                          );
                        },
                        child: const Icon(Icons.copy, size: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          const Text('ESP32 board local IP',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ipCtrl,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: '192.168.1.42',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  app.setNodeMcuIp(ipCtrl.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ESP32 / NodeMCU IP saved & Polling started')),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('SAVE', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ok ? AppColors.green : AppColors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: (ok ? AppColors.green : AppColors.red).withOpacity(0.6), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ),
          Text(ok ? 'OK' : 'WAIT', style: TextStyle(color: ok ? AppColors.green : AppColors.red, fontSize: 11)),
        ],
      ),
    );
  }
}
