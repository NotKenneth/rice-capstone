import 'package:dryce_monitoring_system/widgets/custom_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/historical_data_widget.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _sensorHistoricalData = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _sensorHistoricalData = [];
    });

    try {
      final history = await _fetchAllSensorsHistory();
      if (mounted) {
        setState(() {
          _sensorHistoricalData = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Master Load Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllSensorsHistory() async {
    List<Map<String, dynamic>> finalHistory = [];

    List<String> sensorIds = [
      'MSENSOR-001',
      'MSENSOR-002',
      'MSENSOR-003',
      'MSENSOR-004',
    ];

    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      0,
      0,
      0,
    ).toUtc();
    final endOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      23,
      59,
      59,
    ).toUtc();

    for (String id in sensorIds) {
      try {
        final response = await Supabase.instance.client
            .from('sensor_history')
            .select('moisture_percentage, recorded_at, rice_variety')
            .eq('sensor_id', id)
            .gte('recorded_at', startOfDay.toIso8601String())
            .lte('recorded_at', endOfDay.toIso8601String())
            .order('recorded_at', ascending: true);

        final List rawList = response as List;

        if (rawList.isNotEmpty) {
          String riceVariety = 'Short Grain';
          for (var row in rawList) {
            if (row['rice_variety'] != null &&
                row['rice_variety'] != 'Unknown Variety' &&
                row['rice_variety'] != 'Unknown') {
              riceVariety = row['rice_variety'];
              break;
            }
          }

          DateTime sessionStart = DateTime.parse(rawList.first['recorded_at']);
          DateTime sessionEnd = DateTime.parse(rawList.last['recorded_at']);
          final duration = sessionEnd.difference(sessionStart);
          final totalMinutes = duration.inMinutes;

          List<Map<String, dynamic>> processedChartData = rawList.map((data) {
            DateTime time = DateTime.parse(data['recorded_at']);
            return {
              'minute': time.difference(sessionStart).inSeconds / 60.0,
              'moisture': (data['moisture_percentage'] as num? ?? 0.0)
                  .toDouble(),
            };
          }).toList();

          finalHistory.add({
            'variety': '$riceVariety ($id)',
            'pureVariety': riceVariety,
            'sensorId': id,
            'date': DateFormat('MMMM dd, yyyy').format(_selectedDate),
            'duration': '${totalMinutes ~/ 60}h ${totalMinutes % 60}m',
            'initialMoisture': processedChartData.first['moisture']
                .toStringAsFixed(1),
            'finalMoisture': processedChartData.last['moisture']
                .toStringAsFixed(1),
            'chartData': processedChartData,
            'maxMinute': totalMinutes.toDouble() < 1
                ? 1.0
                : totalMinutes.toDouble(),
          });
        }
      } catch (e) {
        debugPrint("Error fetching history for $id: $e");
      }
    }
    return finalHistory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analysis',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _loadAllData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DateSelectorWidget(
                    initialDate: _selectedDate,
                    onDateChanged: (newDate) {
                      setState(() => _selectedDate = newDate);
                      _loadAllData();
                    },
                  ),
                ),
                if (_sensorHistoricalData.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.query_stats,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No History Found",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "No drying records for ${DateFormat('MMMM dd').format(_selectedDate)}.",
                        ),
                      ],
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: HistoricalDataWidget(
                      historicalCycles: _sensorHistoricalData,
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(currentRoute: '/analysis-screen'),
    );
  }
}
