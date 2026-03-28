import 'dart:ui'; // Required for glass blur
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:typed_data';
import 'package:lottie/lottie.dart'; 

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
            AndroidFlutterLocalNotificationsPlugin>()
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
      bool isWeightExceeding = _enteredWeight != null && _enteredWeight! > 25.0;

      if (isVarietyMissing || isWeightMissing || isWeightExceeding) {
        String errorMessage;
        if (isVarietyMissing) {
          errorMessage = "Please select a Rice Variety before starting.";
        } else if (isWeightMissing) {
          errorMessage = "Please enter a valid weight (kg) before starting.";
        } else {
          errorMessage = "Weight exceeds maximum capacity of 25kg.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

      final service = FlutterBackgroundService();
      if (activate) {
        await service.startService();
      } else {
        service.invoke('stopService');
      }

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

          if (m >= 10.3 && m <= 12.4) {
            readyCount++;
            if (_addToBell(
              id,
              "Target moisture reached: ${m.toStringAsFixed(1)}%",
              "target",
            )) {
              updated = true;
          } else if (m >= 12.5 &&m <= 14.3) {
            if (_addToBell(
              id,
              "Approaching target moisture: ${m.toStringAsFixed(1)}%",
              "approach",
            )) {
              updated = true;
            }
          }

          if (t > 45.0) {
            if (_addToBell(
              id,
              "LIMIT REACHED: ${t.toStringAsFixed(1)}°C",
              "critical",
            )) {
              updated = true;
            }
          } else if (t > 40.0 && t <= 45.0) {
            if (_addToBell(
              id,
              "Approaching temperature limit: ${t.toStringAsFixed(1)}°C",
              "approach",
            )) {
              updated = true;
            }
          }
        }
      }

      if (moistureSensors.isNotEmpty && readyCount == moistureSensors.length) {
        if (_addToBell("SYSTEM", "ALL GRAINS ARE READY!", "ready")) {
          updated = true;
        }
      }

      if (updated && mounted) setState(() {});
    }
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
      backgroundColor: Colors.transparent, // Important for glassmorphism
      isScrollControlled: true,
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
      extendBody: true, 
      appBar: CustomAppBar(
        // Replace the string with an Image.asset widget
        title: Image.asset(
          'assets/official_logo.png', // <-- Make sure to use your actual asset path
          height: 50, // Adjust this height so it fits well inside the AppBar
          fit: BoxFit.contain,
        ),
        automaticallyImplyLeading: false,
        showNotifications: true,
        showSyncStatus: true,
        syncStatus: true,
        unreadNotificationCount: _notifications
            .where((n) => !(n['isRead'] as bool? ?? false))
            .length,
        onNotificationTap: _showNotifications,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/Background_shooting_star.json', 
              fit: BoxFit.cover, 
            ),
          ),
          // -----------------------------------

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _sensorStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Glassmorphism on the error state
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          color: Colors.white.withValues(alpha: 0.1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Connection Timeout",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "The server connection timed out. Please check your internet or retry.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text("RETRY CONNECTION"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
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
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // Slightly tighter radius like your images
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25), // Stronger shadow for depth against dark bg
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Smooth, moderate blur
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                // Very subtle gradient for that dark glass sheen
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08), // Faint highlight top-left
                                    Colors.white.withValues(alpha: 0.02), // Almost transparent bottom-right
                                  ],
                                ),
                                // Thin, delicate border matching your reference
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1.0, 
                                ),
                              ),
                              child: TextField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18, 
                                    horizontal: 16,
                                  ),
                                  labelText: "Total Grain Weight (kg)",
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Solid white like your image
                                  ),
                                  hintText: "Enter weight...",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3), // Darker hint text
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                                    child: Icon(
                                      Icons.scale_rounded, // Assuming you have a scale icon, or use your custom icon here
                                      color: Colors.white, 
                                    ),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _enteredWeight = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
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
                              DateTime.tryParse(sensor["last_update"]?.toString() ?? "") ??
                              DateTime.now(),
                          startTime: sensor["last_started_at"] != null
                              ? DateTime.tryParse(sensor["last_started_at"].toString())
                              : null,
                          connectionStatus:
                              sensor["connection_status"]?.toString() ??
                              "Disconnected",
                          riceVariety: sensor["rice_variety"]?.toString() ?? "",
                          isActive: sensor["is_active"] ?? false,
                          onTap: () {}, temperature: 0,
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
                              color: Colors.white, // Ensure it's white over Lottie
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHeaterCard(currentTemp),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              );
            },
          ),
          
          // 3. Floating Bottom Bar (Now safely inside a Stack)
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomBar(currentRoute: '/dashboard-screen'),
            
          ),
        ],
      ),
    );
  }

  // Updated Heater Card to Glassmorphism
  Widget _buildHeaterCard(double temp) {
    bool isHot = temp > 45.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Subtle red border if hot, white if normal
          color: isHot 
              ? Colors.redAccent.withValues(alpha: 0.5) 
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Translucent gradient
              gradient: LinearGradient(
                colors: isHot
                    ? [
                        Colors.orange[900]!.withValues(alpha: 0.3),
                        Colors.red[700]!.withValues(alpha: 0.3)
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.05)
                      ],
              ),
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
                        Text(
                          "SYSTEM TEMPERATURE",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
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
          ),
        ),
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
              color: Colors.white, // Ensure it pops over Lottie background
            ),
          ),
          _isBulkUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
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
                    foregroundColor: Colors.white,
                    backgroundColor: anyActive
                        ? Colors.red[700]?.withValues(alpha: 0.8)
                        : Colors.green[700]?.withValues(alpha: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      )
                    )
                  ),
                ),
        ],
      ),
    );
  }
}

// Glassmorphism Notification Sheet
class _NotificationListSheet extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback onClear;
  const _NotificationListSheet({
    required this.notifications,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          height: 450,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4), // Dark translucent overlay
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "System Alerts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    TextButton.icon(
                      onPressed: onClear,
                      icon: Icon(Icons.clear_all, color: Colors.white.withValues(alpha: 0.8)),
                      label: Text(
                        "Clear All",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                ],
              ),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
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
                        alertColor = Colors.greenAccent;
                        icon = Icons.check_circle;
                        break;
                      case 'target':
                        alertColor = Colors.orangeAccent;
                        icon = Icons.stars;
                        break;
                      case 'approach':
                        alertColor = Colors.yellowAccent;
                        icon = Icons.access_time_filled;
                        break;
                      case 'critical':
                        alertColor = Colors.redAccent;
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
                        side: BorderSide(color: alertColor.withValues(alpha: 0.5), width: 1),
                      ),
                      color: alertColor.withValues(alpha: 0.1), // Translucent colored card
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: alertColor.withValues(alpha: 0.2),
                          child: Icon(icon, color: alertColor, size: 20),
                        ),
                        title: Text(
                          n['sensorId'],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['message'],
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            Text(
                              DateFormat('jm').format(n['time']),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
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
        ),
      ),
    );
  }
}