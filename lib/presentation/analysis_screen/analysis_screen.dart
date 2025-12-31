import 'package:flutter/material.dart';

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

  // Mock data for rice varieties
  final List<Map<String, dynamic>> _riceVarieties = [
    {'name': 'Jasmine', 'color': const Color(0xFF2E7D32)},
    {'name': 'Basmati', 'color': const Color(0xFF1976D2)},
    {'name': 'Arborio', 'color': const Color(0xFFF57C00)},
    {'name': 'Brown Rice', 'color': const Color(0xFF8D6E63)},
  ];

  // Mock chart data
  List<Map<String, dynamic>> _chartData = [];

  // Mock metrics data
  List<Map<String, dynamic>> _metricsData = [];

  // Mock historical cycles
  final List<Map<String, dynamic>> _historicalCycles = [
    {
      'variety': 'Jasmine Rice',
      'date': '12/23/2025',
      'duration': '18h',
      'initialMoisture': 24,
      'finalMoisture': 14,
      'chartData': [
        {'hour': 0, 'moisture': 24.0},
        {'hour': 3, 'moisture': 22.0},
        {'hour': 6, 'moisture': 20.0},
        {'hour': 9, 'moisture': 18.0},
        {'hour': 12, 'moisture': 16.5},
        {'hour': 15, 'moisture': 15.0},
        {'hour': 18, 'moisture': 14.0},
      ],
    },
    {
      'variety': 'Basmati Rice',
      'date': '12/20/2025',
      'duration': '20h',
      'initialMoisture': 26,
      'finalMoisture': 13,
      'chartData': [
        {'hour': 0, 'moisture': 26.0},
        {'hour': 4, 'moisture': 23.5},
        {'hour': 8, 'moisture': 21.0},
        {'hour': 12, 'moisture': 18.5},
        {'hour': 16, 'moisture': 16.0},
        {'hour': 20, 'moisture': 13.0},
      ],
    },
    {
      'variety': 'Brown Rice',
      'date': '12/18/2025',
      'duration': '22h',
      'initialMoisture': 28,
      'finalMoisture': 15,
      'chartData': [
        {'hour': 0, 'moisture': 28.0},
        {'hour': 4, 'moisture': 26.0},
        {'hour': 8, 'moisture': 24.0},
        {'hour': 12, 'moisture': 21.5},
        {'hour': 16, 'moisture': 19.0},
        {'hour': 20, 'moisture': 16.5},
        {'hour': 22, 'moisture': 15.0},
      ],
    },
  ];

  // Mock insights data
  final List<Map<String, dynamic>> _insightsData = [
    {
      'type': 'success',
      'title': 'Optimal Drying Rate',
      'description':
          'Current drying rate is within optimal range for Jasmine rice. Maintain current temperature and airflow settings.',
    },
    {
      'type': 'warning',
      'title': 'Moisture Variation Detected',
      'description':
          'Sensor 3 shows slightly higher moisture readings. Check sensor placement and ensure uniform air distribution.',
    },
    {
      'type': 'info',
      'title': 'Efficiency Improvement',
      'description':
          'Based on historical data, reducing temperature by 2°C during final phase could improve energy efficiency by 8%.',
    },
    {
      'type': 'info',
      'title': 'Target Achievement',
      'description':
          'Estimated time to reach target moisture content: 4.5 hours. Current progress is on schedule.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedVarieties = _riceVarieties
        .map((v) => v['name'] as String)
        .toList();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Simulate data loading
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock chart data
    _chartData = _generateChartData();

    // Generate mock metrics
    _metricsData = [
      {
        'title': 'Avg Drying Rate',
        'value': '1.2%/h',
        'progress': 0.85,
        'icon': 'trending_down',
        'color': const Color(0xFF2E7D32),
      },
      {
        'title': 'Target Moisture',
        'value': '14%',
        'progress': 0.72,
        'icon': 'water_drop',
        'color': const Color(0xFF1976D2),
      },
      {
        'title': 'Efficiency Score',
        'value': '92/100',
        'progress': 0.92,
        'icon': 'speed',
        'color': const Color(0xFFF57C00),
      },
      {
        'title': 'Energy Usage',
        'value': '2.4 kWh',
        'progress': 0.68,
        'icon': 'bolt',
        'color': const Color(0xFF8D6E63),
      },
    ];

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _generateChartData() {
    final List<Map<String, dynamic>> data = [];

    for (var variety in _riceVarieties) {
      final varietyName = variety['name'] as String;

      // Generate data points for 24 hours
      for (int hour = 0; hour <= 24; hour += 2) {
        final baseMoisture = 25.0;
        final dryingRate = 0.8 + (varietyName.hashCode % 5) * 0.1;
        final moisture = baseMoisture - (hour * dryingRate);

        data.add({
          'variety': varietyName,
          'hour': hour,
          'moisture': moisture.clamp(12.0, 25.0),
        });
      }
    }

    return data;
  }

  void _handleDateRangeChanged(DateTime startDate, DateTime endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
    _loadData();
  }

  void _handleVarietySelectionChanged(List<String> selectedVarieties) {
    setState(() {
      _selectedVarieties = selectedVarieties;
    });
  }

  void _showInsights() {
    AnalysisInsightsSheetWidget.show(context, _insightsData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analysis',
        variant: CustomAppBarVariant.standard,
        showSyncStatus: true,
        syncStatus: true,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInsights,
        tooltip: 'View Insights',
        child: CustomIconWidget(
          iconName: 'lightbulb',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading analysis data...', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // Date range selector
        SliverToBoxAdapter(
          child: DateRangeSelectorWidget(
            onDateRangeChanged: _handleDateRangeChanged,
            initialStartDate: _startDate,
            initialEndDate: _endDate,
          ),
        ),

        // Rice variety filter
        SliverToBoxAdapter(
          child: RiceVarietyFilterWidget(
            varieties: _riceVarieties,
            onSelectionChanged: _handleVarietySelectionChanged,
            initialSelection: _selectedVarieties,
          ),
        ),

        // Moisture trend chart
        SliverToBoxAdapter(
          child: MoistureTrendChartWidget(
            chartData: _chartData,
            varieties: _riceVarieties,
            selectedVarieties: _selectedVarieties,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Metrics cards
        SliverToBoxAdapter(child: MetricsCardWidget(metrics: _metricsData)),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Historical data
        SliverToBoxAdapter(
          child: HistoricalDataWidget(historicalCycles: _historicalCycles),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
