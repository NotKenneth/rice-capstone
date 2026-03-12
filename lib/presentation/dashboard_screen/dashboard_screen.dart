import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
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

  final TextEditingController _weightController = TextEditingController();
  double? _enteredWeight;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

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
    if (activate) {
      bool isVarietyMissing =
          _selectedRiceVariety == null || _selectedRiceVariety!.isEmpty;
      bool isWeightMissing = _enteredWeight == null || _enteredWeight! <= 0;

      if (isVarietyMissing || isWeightMissing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isVarietyMissing
                  ? "Please select a Rice Variety before starting."
                  : "Please enter a valid weight (kg) before starting.",
            ),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (moistureSensors.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activate ? "Start System?" : "Stop System?"),
        content: Text(
          activate
              ? "Activate drying process for $_selectedRiceVariety at ${_enteredWeight}kg?"
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

    String currentSelection = _selectedRiceVariety ?? "";

    if (!activate) {
      try {
        final activeSensor = moistureSensors.firstWhere(
          (s) => s['is_active'] == true,
        );
        currentSelection = activeSensor['rice_variety']?.toString() ?? "";
      } catch (e) {
        currentSelection = "";
      }
    }
    final double currentWeight = _enteredWeight ?? 0.0;
    final String nowIso = DateTime.now().toUtc().toIso8601String();

    try {
      final List<String> idsToUpdate = moistureSensors
          .map((s) => s['id'].toString())
          .toList();

      if (!idsToUpdate.contains('TEMPERATURE')) {
        idsToUpdate.add('TEMPERATURE');
      }

      await Supabase.instance.client
          .from('sensors')
          .update({
            'is_active': activate,
            'last_started_at': activate ? nowIso : null,
            'last_update': nowIso,
            'rice_variety': activate ? currentSelection : "",
          })
          .inFilter('id', idsToUpdate);

      final List<Map<String, dynamic>> historyEntries = moistureSensors.map((
        sensor,
      ) {
        return {
          'sensor_id': sensor['id'].toString(),
          'moisture_percentage': (sensor['moisture_percentage'] as num? ?? 0.0)
              .toDouble(),
          'temperature': (sensor['temperature'] as num? ?? 27.5).toDouble(),
          'recorded_at': nowIso,
          'rice_variety': currentSelection,
          'weight': currentWeight,
        };
      }).toList();

      await Supabase.instance.client
          .from('sensor_history')
          .insert(historyEntries);

      debugPrint(
        "System ${activate ? 'Started' : 'Stopped'}. Variety saved: $currentSelection",
      );

      if (!activate) {
        _weightController.clear();
        _enteredWeight = null;
        _selectedRiceVariety = null;
      }

      if (activate && mounted) {
        Navigator.pushReplacementNamed(context, '/analysis-screen');
      }
    } catch (e) {
      debugPrint("Update error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
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

      final moistureSensors = sensors
          .where((s) => s['id'].toString().startsWith('MSENSOR'))
          .toList();

      int readyCount = 0;
      for (var s in sensors) {
        if (s['is_active'] == true) {
          double m = (s['moisture_percentage'] as num? ?? 0).toDouble();
          double t = (s['temperature'] as num? ?? 0).toDouble();
          String id = s['id']?.toString() ?? "Unknown";

          if (m > 0 && m <= 12.4) {
            readyCount++;
            if (_addToBell(
              id,
              "Target moisture reached: ${m.toStringAsFixed(1)}%",
              "target",
            ))
              updated = true;
          } else if (m > 12.4 && m <= 13.5) {
            if (_addToBell(
              id,
              "Approaching target moisture: ${m.toStringAsFixed(1)}%",
              "approach",
            ))
              updated = true;
          }

          if (t > 45.0) {
            if (_addToBell(
              id,
              "LIMIT REACHED: ${t.toStringAsFixed(1)}°C",
              "critical",
            ))
              updated = true;
          } else if (t > 40.0 && t <= 45.0) {
            if (_addToBell(
              id,
              "Approaching temperature limit: ${t.toStringAsFixed(1)}°C",
              "approach",
            ))
              updated = true;
          }
        }
      }

      if (moistureSensors.isNotEmpty && readyCount == moistureSensors.length) {
        if (_addToBell("SYSTEM", "ALL GRAINS ARE READY!", "ready"))
          updated = true;
      }

      if (updated && mounted) setState(() {});
    });
  }

  bool _addToBell(String sensorId, String message, String status) {
    final now = DateTime.now();
    bool exists = _notifications.any(
      (n) =>
          n['sensorId'] == sensorId &&
          n['message'] == message &&
          now.difference(n['time'] as DateTime).inMinutes < 5,
    );

    if (!exists) {
      _triggerSystemNotification("DryCe Alert: $sensorId", message);

      _notifications.insert(0, {
        'sensorId': sensorId,
        'message': message,
        'time': now,
        'status': status,
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
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

          moistureSensors.sort((a, b) {
            int idA =
                int.tryParse(
                  a['id'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            int idB =
                int.tryParse(
                  b['id'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                0;
            return idA.compareTo(idB);
          });

          final tempRow = allSensors.firstWhere(
            (s) => s['id'] == "TEMPERATURE",
            orElse: () => {"temperature": 27.5},
          );
          double currentTemp = (tempRow['temperature'] as num? ?? 27.5)
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
                      varieties: const ['RC 160', 'RC 402', 'RC 216'],
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
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, moistureSensors),
                        const SizedBox(height: 16),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 12.0,
                      ),
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: "Total Grain Weight (kg)",
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          hintText: "Enter weight...",
                          prefixIcon: Icon(
                            Icons.scale_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _enteredWeight = double.tryParse(value);
                          });
                        },
                      ),
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
                    String displayId =
                        sensor["id"]?.toString().replaceAll(
                          'MSENSOR',
                          'Area ',
                        ) ??
                        "N/A";
                    return SensorCardWidget(
                      sensorId: displayId,
                      moisturePercentage:
                          (sensor["moisture_percentage"] as num? ?? 0)
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
                  label: Text(anyActive ? "STOP" : "START"),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      height: 450,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "System Alerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (notifications.isNotEmpty)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Clear All"),
                ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final String status = n['status'] ?? '';

                Color alertColor;
                IconData icon;

                switch (status) {
                  case 'ready':
                    alertColor = Colors.green;
                    icon = Icons.check_circle;
                    break;
                  case 'target':
                    alertColor = Colors.orange;
                    icon = Icons.stars;
                    break;
                  case 'approach':
                    alertColor = Colors.yellow[700]!;
                    icon = Icons.access_time_filled;
                    break;
                  case 'critical':
                    alertColor = Colors.red;
                    icon = Icons.gpp_maybe;
                    break;
                  default:
                    alertColor = Colors.blueGrey;
                    icon = Icons.notifications;
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: alertColor, width: 2),
                  ),
                  color: alertColor.withOpacity(0.08),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: alertColor,
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      n['sensorId'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n['message'],
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        Text(
                          DateFormat('jm').format(n['time']),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
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
