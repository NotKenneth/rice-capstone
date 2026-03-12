import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 
import 'dart:typed_data';
import 'package:lottie/lottie.dart'; 

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/rice_variety_selector_widget.dart';
import './widgets/sensor_card_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _selectedRiceVariety;
  final List<Map<String, dynamic>> _notifications = [];
  bool _isBulkUpdating = false;

  String _fullName = "Farmer";
  bool _isLoadingProfile = true;

  final Stream<List<Map<String, dynamic>>> _sensorStream = Supabase
      .instance
      .client
      .from('sensors')
      .stream(primaryKey: ['id'])
      .order('id');

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            String first = data['first_name'] ?? "";
            String last = data['last_name'] ?? "";

            _fullName = "$first $last".trim();

            if (_fullName.isEmpty) _fullName = "Farmer";

            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  void _requestNotificationPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _triggerSystemNotification(String title, String body) async {
    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'dryce_alerts_channel', 
      'DryCe Critical Alerts',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      vibrationPattern: vibrationPattern,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('dryce_alarm'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
    );
  }

  Future<void> _toggleAllSensors(
    List<Map<String, dynamic>> moistureSensors,
    bool activate,
  ) async {
    if (activate &&
        (_selectedRiceVariety == null || _selectedRiceVariety!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a Rice Variety before starting."),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (moistureSensors.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activate ? "Start System?" : "Stop System?"),
        content: Text(
          activate
              ? "Activate drying process for $_selectedRiceVariety?"
              : "Stop all active sensors and save analysis for today?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: activate ? Colors.green : Colors.red,
            ),
            child: Text("YES, ${activate ? 'START' : 'STOP'}"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isBulkUpdating = true);

    final String sessionVariety = _selectedRiceVariety ?? "Unknown";
    try {
      final List<String> idsToUpdate = moistureSensors
          .map((s) => s['id'].toString())
          .toList();

      if (!idsToUpdate.contains('TEMPERATURE')) {
        idsToUpdate.add('TEMPERATURE');
      }
      final String nowIso = DateTime.now().toUtc().toIso8601String();

      await Supabase.instance.client
          .from('sensors')
          .update({
            'is_active': activate,
            'last_started_at': activate ? nowIso : null,
            'last_update': nowIso,
            'rice_variety': activate ? _selectedRiceVariety : "EMPTY",
          })
          .inFilter('id', idsToUpdate);

      final List<Map<String, dynamic>> historyEntries = moistureSensors.map((
        sensor,
      ) {
        return {
          'sensor_id': sensor['id'],
          'moisture_percentage': (sensor['moisture_percentage'] as num? ?? 0)
              .toDouble(),
          'temperature': (sensor['temperature'] as num? ?? 0).toDouble(),
          'recorded_at': nowIso,
          'rice_variety': sessionVariety,
        };
      }).toList();

      await Supabase.instance.client
          .from('sensor_history')
          .insert(historyEntries);

      debugPrint(
        "System ${activate ? 'Started' : 'Stopped'}. Final snapshot stored.",
      );

      if (activate && mounted) {
        Navigator.pushReplacementNamed(context, '/analysis-screen');
      }
    } catch (e) {
      debugPrint("Update error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isBulkUpdating = false);
      }
    }
  }

  void _handleNotifications(List<Map<String, dynamic>> sensors) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool updated = false;
      for (var s in sensors) {
        if (s['is_active'] == true) {
          double m = (s['moisture_percentage'] as num? ?? 0).toDouble();
          double t = (s['temperature'] as num? ?? 0).toDouble();
          String id = s['id']?.toString() ?? "Unknown";

          if (m > 0 && m <= 12.4) {
            if (_addToBell(id, "Target moisture reached", true)) updated = true;
          }
          if (t > 45.0) {
            if (_addToBell(id, "High Temp Alert: ${t}°C", true)) updated = true;
          }
        }
      }
      if (updated && mounted) setState(() {});
    });
  }

  bool _addToBell(String sensorId, String message, bool isCritical) {
    final now = DateTime.now();
    bool exists = _notifications.any(
      (n) =>
          n['sensorId'] == sensorId &&
          n['message'] == message &&
          now.difference(n['time'] as DateTime).inMinutes < 5,
    );

    if (!exists) {
      _triggerSystemNotification("Critical Alert: $sensorId", message);

      _notifications.insert(0, {
        'sensorId': sensorId,
        'message': message,
        'time': now,
        'isCritical': isCritical,
        'isRead': false,
      });
      return true;
    }
    return false;
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _NotificationListSheet(
        notifications: _notifications,
        onClear: () {
          setState(() => _notifications.clear());
          Navigator.pop(context);
        },
      ),
    );
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // Ensures scaffold doesn't block Lottie
      extendBody: true, // Crucial for full bleed
      appBar: CustomAppBar(
        title: 'DryCe Monitor',
        automaticallyImplyLeading: false, 
        showNotifications: true,
        showSyncStatus: true,
        syncStatus: true,
        unreadNotificationCount: _notifications
            .where((n) => !n['isRead'])
            .length,
        onNotificationTap: _showNotifications,
      ),
      body: Stack(
        children: [
          // 1. Background Layer: Lottie Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/newback.json', 
              fit: BoxFit.cover, 
              repeat: true, 
            ),
          ),
          
          // 2. Foreground Layer: Your existing Dashboard Content
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _sensorStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Connection Timeout",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                        child: Text(
                          "The server connection timed out. Please check your internet or retry.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {}); 
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("RETRY CONNECTION"),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allSensors = snapshot.data!;
              _handleNotifications(allSensors);

              final moistureSensors = allSensors
                  .where((s) => s['id'].toString().startsWith('MSENSOR'))
                  .toList();

              final tempRow = allSensors.firstWhere(
                (s) => s['id'] == "TEMPERATURE",
                orElse: () => {"temperature": 0.0},
              );
              double currentTemp = (tempRow['temperature'] as num? ?? 0.0)
                  .toDouble();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        GreetingHeaderWidget(
                          userName: _isLoadingProfile ? "..." : _fullName,
                        ),
                        const SizedBox(height: 16),
                        RiceVarietySelectorWidget(
                          selectedVariety: _selectedRiceVariety ?? '',
                          varieties: const [
                            'Basmati',
                            'Jasmine',
                            'Long Grain',
                            'Short Grain',
                            'Brown Rice',
                          ],
                          onVarietyChanged: (val) async {
                            if (val != null) {
                              setState(() => _selectedRiceVariety = val);
                              try {
                                await Supabase.instance.client
                                    .from('sensors')
                                    .update({
                                      'rice_variety': val,
                                      'last_update': DateTime.now()
                                          .toUtc()
                                          .toIso8601String(),
                                    })
                                    .like('id', 'MSENSOR%');

                                debugPrint("Variety updated in Supabase to: $val");
                              } catch (e) {
                                debugPrint("Error updating variety: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Failed to sync variety: $e"),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, moistureSensors),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final sensor = moistureSensors[index];
                        return SensorCardWidget(
                          sensorId: sensor["id"]?.toString() ?? "N/A",
                          moisturePercentage:
                              (sensor["moisture_percentage"] as num? ?? 0)
                                  .toDouble(),
                          temperature: (sensor["temperature"] as num? ?? 0)
                              .toDouble(),
                          status: sensor["status"]?.toString() ?? "Offline",
                          lastUpdate:
                              DateTime.tryParse(sensor["last_update"] ?? "") ??
                              DateTime.now(),
                          startTime: sensor["last_started_at"] != null
                              ? DateTime.tryParse(sensor["last_started_at"])
                              : null,
                          connectionStatus:
                              sensor["connection_status"]?.toString() ??
                              "Disconnected",
                          riceVariety: sensor["rice_variety"]?.toString() ?? "",
                          isActive: sensor["is_active"] ?? false,
                          onTap: () {},
                        );
                      }, childCount: moistureSensors.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Heater Monitoring",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHeaterCard(currentTemp),
                        ],
                      ),
                    ),
                  ),
                  // Increased height here to prevent bottom bar from blocking content
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              );
            },
          ),
          
          // 3. Floating Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomBar(currentRoute: '/dashboard-screen'),
          ),
        ],
      ),
      // bottomNavigationBar removed entirely from here!
    );
  }

  Widget _buildHeaterCard(double temp) {
    bool isHot = temp > 45.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHot
              ? [Colors.orange[900]!, Colors.red[700]!]
              : [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isHot ? Icons.whatshot : Icons.thermostat,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SYSTEM TEMPERATURE",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${temp.toStringAsFixed(1)}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isHot)
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    List<Map<String, dynamic>> moistureSensors,
  ) {
    final anyActive = moistureSensors.any((s) => s['is_active'] == true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Sensors',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          _isBulkUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton.icon(
                  onPressed: () =>
                      _toggleAllSensors(moistureSensors, !anyActive),
                  icon: Icon(
                    anyActive
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    size: 18,
                  ),
                  label: Text(anyActive ? "STOP ALL" : "START ALL"),
                  style: TextButton.styleFrom(
                    foregroundColor: anyActive
                        ? Colors.red[700]
                        : Colors.green[700],
                  ),
                ),
        ],
      ),
    );
  }
}

class _NotificationListSheet extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback onClear;
  const _NotificationListSheet({
    required this.notifications,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Alerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onClear, child: const Text("Clear All")),
            ],
          ),
          const Divider(),
          if (notifications.isEmpty)
            const Expanded(child: Center(child: Text("No new alerts"))),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: n['isCritical'] ? Colors.red : Colors.orange,
                  ),
                  title: Text("${n['sensorId']}: ${n['message']}"),
                  subtitle: Text("${n['time'].hour}:${n['time'].minute}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}