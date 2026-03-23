import 'dart:ui'; // <-- ADDED FOR GLASSMORPHISM (ImageFilter)
import 'dart:io';

import 'package:dryce_monitoring_system/presentation/analysis_screen/widgets/rice_variety_filter_widget.dart';
import 'package:dryce_monitoring_system/widgets/custom_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart'; 
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  bool get _isSingleDaySelected {
    return _selectedRange.start.year == _selectedRange.end.year &&
        _selectedRange.start.month == _selectedRange.end.month &&
        _selectedRange.start.day == _selectedRange.end.day;
  }

  List<Map<String, dynamic>> _sensorHistoricalData = [];

  List<String> _selectedVarieties = [];
  List<Map<String, dynamic>> _availableVarieties = [];

  List<Map<String, dynamic>> get _filteredData {
    return _sensorHistoricalData.where((session) {
      final variety = session['variety'] ?? 'Unknown';
      return _selectedVarieties.contains(variety);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> sessions =
          await _fetchAllSensorsHistory();

      if (mounted) {
        setState(() {
          _sensorHistoricalData = sessions;
          _extractAvailableVarieties(sessions);
        });
      }
    } catch (e) {
      debugPrint("Critical Loading Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _extractAvailableVarieties(List<Map<String, dynamic>> sessions) {
    final Set<String> uniqueVarieties = {};
    for (var session in sessions) {
      final variety = session['variety'] ?? 'Unknown';
      if (variety != 'Standard' && variety != 'Unknown') {
        uniqueVarieties.add(variety);
      }
    }

    final List<Color> palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    int colorIdx = 0;

    _availableVarieties = uniqueVarieties.map((v) {
      return {'name': v, 'color': palette[(colorIdx++) % palette.length]};
    }).toList();
    _selectedVarieties = uniqueVarieties.toList();
  }

  List<Map<String, dynamic>> _groupIntoSessions(
    List<Map<String, dynamic>> rawData,
  ) {
    if (rawData.isEmpty) return [];

    Map<String, List<Map<String, dynamic>>> logsByVariety = {};
    for (var record in rawData) {
      String variety = record['rice_variety'] ?? 'Unknown';
      logsByVariety.putIfAbsent(variety, () => []);
      logsByVariety[variety]!.add(record);
    }

    List<Map<String, dynamic>> finalSessions = [];
    const sessionGap = Duration(minutes: 30);

    logsByVariety.forEach((variety, varietyLogs) {
      varietyLogs.sort(
        (a, b) => DateTime.parse(
          a['recorded_at'],
        ).compareTo(DateTime.parse(b['recorded_at'])),
      );

      List<Map<String, dynamic>> currentBatch = [];

      for (var record in varietyLogs) {
        if (currentBatch.isEmpty) {
          currentBatch.add(record);
          continue;
        }

        DateTime lastTime = DateTime.parse(currentBatch.last['recorded_at']);
        DateTime currentTime = DateTime.parse(record['recorded_at']);

        if (currentTime.difference(lastTime) <= sessionGap) {
          currentBatch.add(record);
        } else {
          final processed = _processSession(List.from(currentBatch));
          if (processed['durationValue'] >= 0 &&
              processed['chartData'].isNotEmpty) {
            finalSessions.add(processed);
          }
          currentBatch = [record];
        }
      }

      if (currentBatch.isNotEmpty) {
        final processed = _processSession(List.from(currentBatch));
        if (processed['durationValue'] >= 0 &&
            processed['chartData'].isNotEmpty) {
          finalSessions.add(processed);
        }
      }
    });

    finalSessions.sort((a, b) {
      DateTime timeA = DateTime.parse(a['chartData'].first['recorded_at']);
      DateTime timeB = DateTime.parse(b['chartData'].first['recorded_at']);
      return timeB.compareTo(timeA);
    });

    return finalSessions;
  }

  Map<String, dynamic> _processSession(List<Map<String, dynamic>> records) {
    final hardwareRecords = records;

    if (hardwareRecords.isEmpty) {
      return {
        'durationValue': 0.0,
        'initialMoisture': "0.0",
        'finalMoisture': "0.0",
      };
    }

    final firstTime = DateTime.parse(hardwareRecords.first['recorded_at']);
    final lastTime = DateTime.parse(hardwareRecords.last['recorded_at']);
    final duration = lastTime.difference(firstTime);

    final sensorIds = hardwareRecords.map((r) => r['sensor_id']).toSet();

    List<double> initialReadings = [];
    for (var id in sensorIds) {
      final firstEntry = hardwareRecords.firstWhere(
        (r) => r['sensor_id'] == id,
      );
      initialReadings.add(
        (firstEntry['moisture_percentage'] as num).toDouble(),
      );
    }
    double initialAvg = initialReadings.isEmpty
        ? 0.0
        : initialReadings.reduce((a, b) => a + b) / initialReadings.length;

    List<double> finalReadings = [];
    for (var id in sensorIds) {
      final lastEntry = hardwareRecords.lastWhere((r) => r['sensor_id'] == id);
      finalReadings.add((lastEntry['moisture_percentage'] as num).toDouble());
    }
    double finalAvg = finalReadings.isEmpty
        ? 0.0
        : finalReadings.reduce((a, b) => a + b) / finalReadings.length;
        
    for (var id in sensorIds) {
      final firstEntry = records.firstWhere((r) => r['sensor_id'] == id);
      double reading = (firstEntry['moisture_percentage'] as num).toDouble();
      initialReadings.add(reading);
    }

    double totalWeight = hardwareRecords.fold(
      0.0,
      (sum, item) => sum + (item['weight'] as num? ?? 0.0).toDouble(),
    );
    double avgWeight = totalWeight / hardwareRecords.length;

    return {
      'session_id': hardwareRecords.first['session_id'],
      'variety': hardwareRecords.first['rice_variety'],
      'date': "${firstTime.day}/${firstTime.month}/${firstTime.year}",
      'duration': "${duration.inHours}h ${duration.inMinutes % 60}m",
      'durationValue': duration.inMinutes.toDouble(),
      'initialMoisture': initialAvg.toStringAsFixed(1),
      'finalMoisture': finalAvg.toStringAsFixed(1),
      'weight': avgWeight > 0 ? avgWeight.toStringAsFixed(1) : "0.0",
      'weightValue': avgWeight,
      'chartData': hardwareRecords,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchAllSensorsHistory() async {
    try {
      final start = DateTime(
        _selectedRange.start.year,
        _selectedRange.start.month,
        _selectedRange.start.day,
        0,
        0,
        0,
      ).toUtc();

      final end = DateTime(
        _selectedRange.end.year,
        _selectedRange.end.month,
        _selectedRange.end.day,
        23,
        59,
        59,
      ).toUtc();

      final response = await Supabase.instance.client
          .from('sensor_history')
          .select(
            'moisture_percentage, recorded_at, rice_variety, weight, sensor_id, session_id',
          )
          .not('recorded_at', 'is', null)
          .neq('rice_variety', 'Standard')
          .gte('recorded_at', start.toIso8601String())
          .lte('recorded_at', end.toIso8601String())
          .order('recorded_at', ascending: true)
          .order('rice_variety', ascending: true);

      final List rawData = response as List;
      if (rawData.isEmpty) return [];

      return _groupIntoSessions(List<Map<String, dynamic>>.from(rawData));
    } catch (e) {
      debugPrint("🔍 RAW SUPABASE FETCH ERROR: $e");
      return [];
    }
  }

  Future<void> _exportData() async {
    if (_filteredData.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      List<List<dynamic>> rows = [];
      rows.add(["BATCH ANALYSIS SUMMARY REPORT"]);
      rows.add([
        "Range: ${DateFormat('MMM dd').format(_selectedRange.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedRange.end)}",
      ]);
      rows.add([]);

      Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (var session in _filteredData) {
        String variety = session['variety'] ?? 'Unknown';
        groupedData.putIfAbsent(variety, () => []);
        groupedData[variety]!.add(session);
      }

      groupedData.forEach((variety, sessions) {
        rows.add([variety.toUpperCase()]);
        rows.add(["Date", "Weight", "Initial MC", "Duration", "Final MC"]);

        double totalFinalMc = 0;

        for (var session in sessions) {
          totalFinalMc +=
              double.tryParse(session['finalMoisture'].toString()) ?? 0.0;
          rows.add([
            session['date'],
            session['weight'] ?? "0.0 kg",
            "${session['initialMoisture']}%",
            session['duration'],
            "${session['finalMoisture']}%",
          ]);
        }

        List<Map<String, dynamic>> sortedByInitial = List.from(sessions);
        sortedByInitial.sort(
          (a, b) => (double.tryParse(a['initialMoisture'].toString()) ?? 0.0)
              .compareTo(
                double.tryParse(b['initialMoisture'].toString()) ?? 0.0,
              ),
        );

        var lowestRecord = sortedByInitial.first;
        var highestRecord = sortedByInitial.last;
        double avgFinalMc = totalFinalMc / sessions.length;

        rows.add(["-- STATISTICS for $variety --"]);
        rows.add(["HIGHEST INITIAL MC"]);
        rows.add([
          highestRecord['date'],
          highestRecord['weight'],
          "${highestRecord['initialMoisture']}%",
          highestRecord['duration'],
          "${highestRecord['finalMoisture']}%",
        ]);

        rows.add(["LOWEST INITIAL MC"]);
        rows.add([
          lowestRecord['date'],
          lowestRecord['weight'],
          "${lowestRecord['initialMoisture']}%",
          lowestRecord['duration'],
          "${lowestRecord['finalMoisture']}%",
        ]);

        rows.add([
          "TOTAL AVERAGE FINAL MC",
          "",
          "",
          "",
          "",
          "${avgFinalMc.toStringAsFixed(2)}%",
        ]);

        rows.add([]);
      });

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final String fileName =
          "Batch_Summary_${DateTime.now().millisecondsSinceEpoch}.csv";
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Batch Analysis Report');
    } catch (e) {
      debugPrint("Export Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UPDATED TEXT COLORS FOR EMPTY STATE ---
  Widget _buildNoDataState() {
    final String dateText = _isSingleDaySelected
        ? DateFormat('MMMM dd, yyyy').format(_selectedRange.start)
        : "${DateFormat('MMM dd').format(_selectedRange.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedRange.end)}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.query_stats, size: 80, color: Colors.white54),
        const SizedBox(height: 16),
        const Text(
          "No History Found",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "No drying records found for $dateText.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteSession(Map<String, dynamic> session) async {
    final List<dynamic> chartData = session['chartData'] ?? [];
    if (chartData.isEmpty) return;

    final String startTime = chartData.first['recorded_at'].toString();
    final String endTime = chartData.last['recorded_at'].toString();
    final String variety = session['variety'].toString();

    try {
      setState(() => _isLoading = true);

      final response = await Supabase.instance.client
          .from('sensor_history')
          .delete()
          .match({'rice_variety': variety})
          .gte('recorded_at', startTime)
          .lte('recorded_at', endTime)
          .select();

      if (response.isNotEmpty) {
        await _loadAllData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permanently deleted ${response.length} records.'),
            ),
          );
        }
      } 
    } catch (e) {
      debugPrint("Database Delete Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Lowered opacity so the Lottie background is actually visible!
      backgroundColor: Colors.black.withOpacity(0.4),
      
      appBar: CustomAppBar(
        title: 'Analysis',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _loadAllData, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/newwwww.json', 
              fit: BoxFit.cover,
            ),
          ),
          
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: DateSelectorWidget(
                              initialRange: _selectedRange,
                              onRangeChanged: (start, end) {
                                setState(() {
                                  _selectedRange = DateTimeRange(
                                    start: start,
                                    end: end,
                                  );
                                });
                                _loadAllData();
                              },
                            ),
                          ),
                          if (_availableVarieties.isNotEmpty)
                            SliverToBoxAdapter(
                              child: RiceVarietyFilterWidget(
                                key: ValueKey(
                                  _availableVarieties
                                      .map((v) => v['name'])
                                      .join(','),
                                ),
                                varieties: _availableVarieties,
                                initialSelection: _selectedVarieties,
                                onSelectionChanged: (selected) {
                                  setState(() {
                                    _selectedVarieties = selected;
                                  });
                                },
                              ),
                            ),
                          if (_filteredData.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildNoDataState(),
                            )
                          else ...[
                            if (_isSingleDaySelected)
                              SliverToBoxAdapter(
                                child: HistoricalDataWidget(
                                  historicalCycles: _filteredData,
                                  onDelete: (dynamic sessionData) {
                                    if (sessionData is Map<String, dynamic>) {
                                      _deleteSession(sessionData);
                                    } else {
                                      final fullMap = _sensorHistoricalData
                                          .firstWhere(
                                            (s) => s['session_id'] == sessionData,
                                            orElse: () => <String, dynamic>{},
                                          );
                                      if (fullMap.isNotEmpty) {
                                        _deleteSession(fullMap);
                                      }
                                    }
                                  },
                                ),
                              ),

                            // --- UPDATED FOR VISIBILITY ---
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                                child: Text(
                                  _isSingleDaySelected
                                      ? (DateUtils.isSameDay(
                                            _selectedRange.start,
                                            DateTime.now(),
                                          )
                                          ? "Today's Drying Sessions"
                                          : "Drying Sessions: ${DateFormat('MMM dd, yyyy').format(_selectedRange.start)}")
                                      : "Batch Analysis Summary",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white, // Forces text to be white
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),

                            SliverToBoxAdapter(
                              child: _buildAnalysisTable(_filteredData),
                            ),

                            const SliverToBoxAdapter(child: SizedBox(height: 24)),
                          ],
                        ],
                      ),
              ),

              if (_filteredData.isNotEmpty && !_isLoading)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  // Glassmorphic footer for the button             
                  child: SizedBox(
                    width: 300,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _exportData,
                      icon: const Icon(Icons.file_download_rounded),
                      label: Text(
                        "EXPORT ${(_selectedRange.end.difference(_selectedRange.start).inDays > 1) ? 'WEEKLY/MONTHLY' : 'DAILY'} REPORT",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.8), // Slight transparency to match
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomBar(currentRoute: '/analysis-screen'),
    );
  }

  // --- UPDATED GLASSMORPHIC TABLE ---
  Widget _buildAnalysisTable(List<Map<String, dynamic>> historicalCycles) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var session in historicalCycles) {
      String variety = session['variety'] ?? 'Unknown';
      if (variety == 'Standard' || variety == 'Unknown') continue;
      groupedData.putIfAbsent(variety, () => []);
      groupedData[variety]!.add(session);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: groupedData.entries.map((entry) {
          final varietyName = entry.key;
          final sessions = entry.value;

          double avgFinalMC =
              sessions.fold(
                0.0,
                (sum, item) =>
                    sum +
                    (double.tryParse(item['finalMoisture'].toString()) ?? 0.0),
              ) /
              sessions.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  varietyName.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70, // Made visible against dark background
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              // Glassmorphic Container replacing the old solid Card
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // Forcing a dark theme purely for the DataTable so text is white
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.white.withOpacity(0.1),
                          dataTableTheme: const DataTableThemeData(
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                            ),
                            dataTextStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: DataTable(
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Weight')),
                            DataColumn(label: Text('Initial MC')),
                            DataColumn(label: Text('Duration')),
                            DataColumn(label: Text('Final MC')),
                          ],
                          rows: [
                            ...sessions.map(
                              (session) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      DateFormat('MM/dd/yy').format(
                                        DateTime.parse(
                                          session['chartData'].first['recorded_at'],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${session['weight']} kg')),
                                  DataCell(Text('${session['initialMoisture']}%')),
                                  DataCell(Text(session['duration'])),
                                  DataCell(Text('${session['finalMoisture']}%')),
                                ],
                              ),
                            ),
                            DataRow(
                              color: WidgetStateProperty.all(
                                Colors.lightBlueAccent.withOpacity(0.15),
                              ),
                              cells: [
                                const DataCell(
                                  Text(
                                    'AVERAGE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent, // Pops better than plain blue
                                    ),
                                  ),
                                ),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                const DataCell(Text('')),
                                DataCell(
                                  Text(
                                    '${avgFinalMC.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}