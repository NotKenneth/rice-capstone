import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/rice_variety_selector_widget.dart';
import './widgets/sensor_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedRiceVariety = 'Basmati';
  bool _isRefreshing = false;

  // Mock sensor data
  final List<Map<String, dynamic>> _sensorData = [
    {
      "id": "SENSOR-001",
      "moisturePercentage": 18.5,
      "status": "optimal",
      "lastUpdate": DateTime.now().subtract(const Duration(minutes: 2)),
      "riceVariety": "Basmati",
      "connectionStatus": "connected",
    },
    {
      "id": "SENSOR-002",
      "moisturePercentage": 22.3,
      "status": "warning",
      "lastUpdate": DateTime.now().subtract(const Duration(minutes: 5)),
      "riceVariety": "Jasmine",
      "connectionStatus": "connected",
    },
    {
      "id": "SENSOR-003",
      "moisturePercentage": 14.2,
      "status": "optimal",
      "lastUpdate": DateTime.now().subtract(const Duration(minutes: 1)),
      "riceVariety": "Basmati",
      "connectionStatus": "connected",
    },
    {
      "id": "SENSOR-004",
      "moisturePercentage": 28.7,
      "status": "critical",
      "lastUpdate": DateTime.now().subtract(const Duration(minutes: 8)),
      "riceVariety": "Long Grain",
      "connectionStatus": "weak",
    },
  ];

  final List<String> _riceVarieties = [
    'Basmati',
    'Jasmine',
    'Long Grain',
    'Short Grain',
    'Brown Rice',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'DryCe Monitor',
        variant: CustomAppBarVariant.standard,
        showSyncStatus: true,
        syncStatus: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              // Navigate to notifications
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Critical moisture alert banner
                  if (_hasCriticalAlerts()) _buildAlertBanner(theme),

                  // Greeting header
                  GreetingHeaderWidget(userName: 'John Farmer'),

                  const SizedBox(height: 16),

                  // Rice variety selector
                  RiceVarietySelectorWidget(
                    selectedVariety: _selectedRiceVariety,
                    varieties: _riceVarieties,
                    onVarietyChanged: (String? newVariety) {
                      if (newVariety != null) {
                        setState(() {
                          _selectedRiceVariety = newVariety;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Sensors',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_getFilteredSensors().length} sensors',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Sensor cards grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final filteredSensors = _getFilteredSensors();
                  if (index >= filteredSensors.length) return null;

                  final sensor = filteredSensors[index];
                  return SensorCardWidget(
                    sensorId: sensor["id"] as String,
                    moisturePercentage: sensor["moisturePercentage"] as double,
                    status: sensor["status"] as String,
                    lastUpdate: sensor["lastUpdate"] as DateTime,
                    connectionStatus: sensor["connectionStatus"] as String,
                    riceVariety: sensor["riceVariety"] as String,
                    onTap: () {
                      _navigateToSensorDetail(sensor["id"] as String);
                    },
                  );
                }, childCount: _getFilteredSensors().length),
              ),
            ),

            // Bottom spacing for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/dashboard-screen',
        badges: {CustomBottomBarItem.dashboard: _hasCriticalAlerts() ? 1 : 0},
      ),
    );
  }

  Widget _buildAlertBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.error, width: 1.0),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning',
            color: theme.colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Critical Moisture Alert',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sensor ${_getCriticalSensors().first["id"]} requires immediate attention',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'close',
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                // Dismiss alert
              });
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSensors() {
    return _sensorData
        .where((sensor) => sensor["riceVariety"] == _selectedRiceVariety)
        .toList();
  }

  bool _hasCriticalAlerts() {
    return _sensorData.any((sensor) => sensor["status"] == "critical");
  }

  List<Map<String, dynamic>> _getCriticalSensors() {
    return _sensorData
        .where((sensor) => sensor["status"] == "critical")
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      // Update last update times
      for (var sensor in _sensorData) {
        sensor["lastUpdate"] = DateTime.now();
      }
    });
  }

  void _navigateToSensorDetail(String sensorId) {
    // Navigate to sensor detail screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sensor $sensorId'),
        content: const Text('Detailed sensor view will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
