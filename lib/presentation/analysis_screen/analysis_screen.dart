import 'package:dryce_monitoring_system/widgets/custom_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/analysis_insights_sheet_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/historical_data_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/moisture_trend_chart_widget.dart';
import './widgets/rice_variety_filter_widget.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<String> _selectedVarieties = [];
  List<Map<String, dynamic>> _sensorHistoricalData = [];

  final List<Map<String, dynamic>> _riceVarieties = [
    {'name': 'Jasmine', 'color': const Color(0xFF2E7D32)},
    {'name': 'Basmati', 'color': const Color(0xFF1976D2)},
    {'name': 'Arborio', 'color': const Color(0xFFF57C00)},
    {'name': 'Brown Rice', 'color': const Color(0xFF8D6E63)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedVarieties = _riceVarieties
        .map((v) => v['name'] as String)
        .toList();
    _loadAllData();
  }

  // Master load function
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    // Fetch real history for the 4 sensors
    final history = await _fetchAllSensorsHistory();

    setState(() {
      _sensorHistoricalData = history;
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAllSensorsHistory() async {
    List<Map<String, dynamic>> finalHistory = [];
    List<String> sensorIds = [
      'MSENSOR-001',
      'MSENSOR-002',
      'MSENSOR-003',
      'MSENSOR-004',
    ];

    for (String id in sensorIds) {
      final response = await Supabase.instance.client
          .from('sensor_history')
          .select('moisture_percentage, recorded_at')
          .eq('sensor_id', id)
          .order('recorded_at', ascending: false)
          .limit(15);

      List<Map<String, dynamic>> rawChartData = (response as List).reversed.map(
        (data) {
          DateTime time = DateTime.parse(data['recorded_at']);
          return {
            'hour': time.hour.toDouble() + (time.minute / 60),
            'moisture': data['moisture_percentage'],
          };
        },
      ).toList();

      if (rawChartData.isNotEmpty) {
        finalHistory.add({
          'variety': 'Sensor Unit $id', // Using sensor ID as title
          'date': 'Last 15 readings',
          'duration': 'Live',
          'initialMoisture': rawChartData.first['moisture'].toStringAsFixed(1),
          'finalMoisture': rawChartData.last['moisture'].toStringAsFixed(1),
          'chartData': rawChartData,
        });
      }
    }
    return finalHistory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analysis',
        showSyncStatus: true,
        syncStatus: true,
        actions: [
          IconButton(
            onPressed: _loadAllData,
            icon: const CustomIconWidget(iconName: 'refresh', size: 24),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DateRangeSelectorWidget(
                    onDateRangeChanged: (s, e) => _loadAllData(),
                    initialStartDate: _startDate,
                    initialEndDate: _endDate,
                  ),
                ),
                // Historical Sensors Section
                SliverToBoxAdapter(
                  child: HistoricalDataWidget(
                    historicalCycles: _sensorHistoricalData,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(currentRoute: '/analysis-screen'),
    );
  }
}
