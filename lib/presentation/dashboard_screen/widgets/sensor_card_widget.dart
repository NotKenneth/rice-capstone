import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SensorCardWidget extends StatefulWidget {
  final String sensorId;
  final double moisturePercentage;
  final double temperature;
  final String status;
  final DateTime lastUpdate;
  final DateTime? startTime;
  final String connectionStatus;
  final String riceVariety;
  final bool isActive;
  final VoidCallback? onTap;

  const SensorCardWidget({
    super.key,
    required this.sensorId,
    required this.moisturePercentage,
    required this.temperature,
    required this.status,
    required this.lastUpdate,
    this.startTime,
    required this.connectionStatus,
    required this.riceVariety,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<SensorCardWidget> createState() => _SensorCardWidgetState();
}

class _SensorCardWidgetState extends State<SensorCardWidget> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void didUpdateWidget(SensorCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive ||
        widget.startTime != oldWidget.startTime) {
      _initTimer();
    }
  }

  void _initTimer() {
    _timer?.cancel();
    if (widget.isActive && widget.startTime != null) {
      _updateElapsed();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (t) => _updateElapsed(),
      );
    } else {
      setState(() => _elapsedTime = Duration.zero);
    }
  }

  void _updateElapsed() {
    if (widget.startTime != null) {
      setState(
        () => _elapsedTime = DateTime.now().difference(widget.startTime!),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String digits(int n) => n.toString().padLeft(2, "0");
    return "${digits(d.inHours)}:${digits(d.inMinutes.remainder(60))}:${digits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isOffline = widget.status.toLowerCase() == 'offline';
    final Color varietyColor = _getVarietyColor(widget.riceVariety);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isActive
              ? varietyColor
              : theme.dividerColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.sensorId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                    Icon(
                      isOffline ? Icons.wifi_off : Icons.wifi,
                      size: 14,
                      color: isOffline ? Colors.red : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // MOISTURE READING
                Text(
                  isOffline
                      ? "--"
                      : "${widget.moisturePercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isOffline ? Colors.grey : varietyColor,
                  ),
                ),
                const Text(
                  "MOISTURE LEVEL",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),
                _timerBadge(varietyColor),
              ],
            ),
          ),
          const Spacer(),
          _actionButton(isOffline),
        ],
      ),
    );
  }

  Widget _timerBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isActive ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.isActive ? _formatDuration(_elapsedTime) : "00:00:00",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: widget.isActive ? color : Colors.grey,
        ),
      ),
    );
  }

  Widget _actionButton(bool offline) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: offline ? null : () => _togglePower(),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isActive
                ? Colors.redAccent
                : Colors.green[700],
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.isActive ? "STOP" : "START",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _togglePower() async {
    final bool starting = !widget.isActive;

    // We try to match the ID as a dynamic value.
    // If your DB ID is an integer, int.tryParse(widget.sensorId) is better.
    final dynamic dbId = int.tryParse(widget.sensorId) ?? widget.sensorId;

    try {
      await Supabase.instance.client
          .from('sensors')
          .update({
            'is_active': starting,
            'last_started_at': starting
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', dbId); // Use the parsed ID

      debugPrint("Successfully toggled $dbId to $starting");
    } catch (e) {
      debugPrint("Single update error for $dbId: $e");
    }
  }

  Color _getVarietyColor(String v) {
    if (v.contains('Jasmine')) return const Color(0xFF2E7D32);
    if (v.contains('Basmati')) return const Color(0xFF1976D2);
    return const Color(0xFF4CAF50);
  }
}
