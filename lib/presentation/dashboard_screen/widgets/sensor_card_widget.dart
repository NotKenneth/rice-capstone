import 'dart:async';
import 'dart:ui'; // Required for glass blur
import 'package:flutter/material.dart';

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
      final DateTime nowUtc = DateTime.now().toUtc();
      final DateTime startUtc = widget.startTime!.toUtc();

      setState(() {
        if (nowUtc.isBefore(startUtc)) {
          _elapsedTime = Duration.zero;
        } else {
          _elapsedTime = nowUtc.difference(startUtc);
        }
      });
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
    final bool isOffline = widget.status.toLowerCase() == 'offline';
    final Color varietyColor = _getVarietyColor(widget.riceVariety);

    return GestureDetector(
      onTap: widget.onTap, // Added the tap functionality here
      child: Container(
        // Outer container handles the floating shadow
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // ClipRRect keeps the blur inside the card shape
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0), // The glass frost
            child: Container(
              decoration: BoxDecoration(
                // Dark glassy tint
                color: const Color(0xFF1B2230).withOpacity(0.45),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  // Border changes color if active
                  color: widget.isActive
                      ? varietyColor.withOpacity(0.6)
                      : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.sensorId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white, // Updated to white for dark glass
                              ),
                            ),
                            Icon(
                              isOffline ? Icons.wifi_off : Icons.wifi,
                              size: 16,
                              color: isOffline ? Colors.redAccent : Colors.greenAccent,
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
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            // Lighter grey if offline, variety color if online
                            color: isOffline ? Colors.white54 : varietyColor,
                          ),
                        ),
                        Text(
                          "MOISTURE LEVEL",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.6), // Glassy white text
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 16),
                        _timerBadge(varietyColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timerBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Glassy inner pill
        color: widget.isActive 
            ? color.withOpacity(0.15) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isActive 
              ? color.withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        widget.isActive ? _formatDuration(_elapsedTime) : "INACTIVE",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          // Softer red if inactive
          color: widget.isActive ? color : Colors.redAccent.withOpacity(0.8), 
        ),
      ),
    );
  }

  Color _getVarietyColor(String v) {
    if (v.contains('Jasmine')) return const Color(0xFF81C784); // Brightened for dark mode
    if (v.contains('Basmati')) return const Color(0xFF64B5F6); // Brightened for dark mode
    return const Color(0xFF81C784); // Default bright green
  }
}