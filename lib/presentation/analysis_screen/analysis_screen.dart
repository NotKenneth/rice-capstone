import 'package:dryce_monitoring_system/presentation/analysis_screen/widgets/rice_variety_filter_widget.dart';
import 'package:dryce_monitoring_system/widgets/custom_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/historical_data_widget.dart';

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

    // 1. Group the raw data by Variety FIRST to prevent interwoven logs from breaking the batches
    Map<String, List<Map<String, dynamic>>> logsByVariety = {};
    for (var record in rawData) {
      String variety = record['rice_variety'] ?? 'Unknown';
      logsByVariety.putIfAbsent(variety, () => []);
      logsByVariety[variety]!.add(record);
    }

    List<Map<String, dynamic>> finalSessions = [];
    const sessionGap = Duration(minutes: 30);

    // 2. Process each variety's logs completely independently
    logsByVariety.forEach((variety, varietyLogs) {
      // Sort this specific variety's logs chronologically
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

        // Check if the time gap is within our 30-minute window
        if (currentTime.difference(lastTime) <= sessionGap) {
          currentBatch.add(record);
        } else {
          // Gap is too big, close the batch and process it
          final processed = _processSession(List.from(currentBatch));
          if (processed['durationValue'] >= 0 &&
              processed['chartData'].isNotEmpty) {
            finalSessions.add(processed);
          }
          currentBatch = [record]; // Start a new batch
        }
      }

      // Process the final lingering batch for this variety
      if (currentBatch.isNotEmpty) {
        final processed = _processSession(List.from(currentBatch));
        if (processed['durationValue'] >= 0 &&
            processed['chartData'].isNotEmpty) {
          finalSessions.add(processed);
        }
      }
    });

    // 3. Sort all the final sessions so the newest ones appear at the top
    finalSessions.sort((a, b) {
      DateTime timeA = DateTime.parse(a['chartData'].first['recorded_at']);
      DateTime timeB = DateTime.parse(b['chartData'].first['recorded_at']);
      return timeB.compareTo(timeA); // Descending order
    });

    return finalSessions;
  }

  Map<String, dynamic> _processSession(List<Map<String, dynamic>> records) {
    // 1. HARDWARE FILTER: Define your physical sensor IDs
    /*const validIds = [
      'MSENSOR-001',
      'MSENSOR-002',
      'MSENSOR-003',
      'MSENSOR-004',
    ];*/

    // Only keep records from actual sensors
    final hardwareRecords = records;
    /*  .where((r) => validIds.contains(r['sensor_id']))
        .toList();*/

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

    // Get unique sensor IDs from the FILTERED list
    final sensorIds = hardwareRecords.map((r) => r['sensor_id']).toSet();
    debugPrint("Processing session with ${sensorIds.length} valid sensors");

    // Initial MC Calculation (First reading per VALID sensor)
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

    // Final MC Calculation (Last reading per VALID sensor)
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

      // ADD THIS LINE TO YOUR CODE TO SEE THE GHOST:
      debugPrint("SENSOR ID: $id | READING: $reading");

      initialReadings.add(reading);
    }

    // Weight Calculation
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
      // 1. Create strict UTC boundaries for the selected day
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
          // CRITICAL: Order by time first, THEN variety
          .order('recorded_at', ascending: true)
          .order('rice_variety', ascending: true);

      final List rawData = response as List;
      if (rawData.isEmpty) return [];

      // Use a try-catch inside the group function to prevent UI hangs
      return _groupIntoSessions(List<Map<String, dynamic>>.from(rawData));
    } catch (e) {
      debugPrint("🔍 RAW SUPABASE FETCH: Found $e total records for this day.");
      // Ensure you show a message to the user or stop the loader in the parent
      return [];
    }
  }

  Future<void> _exportData() async {
    //if (_sensorHistoricalData.isEmpty) return;
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
        // Standardized Headers
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

        // --- CALCULATE STATISTICS ---
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

        // Highest Initial MC Row: Gets the full record details of THAT specific session
        rows.add(["HIGHEST INITIAL MC"]);

        rows.add([
          highestRecord['date'],
          highestRecord['weight'],
          "${highestRecord['initialMoisture']}%",
          highestRecord['duration'],
          "${highestRecord['finalMoisture']}%",
        ]);

        // Lowest Initial MC Row: Gets the full record details of THAT specific session
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

  Widget _buildNoDataState() {
    final String dateText = _isSingleDaySelected
        ? DateFormat('MMMM dd, yyyy').format(_selectedRange.start)
        : "${DateFormat('MMM dd').format(_selectedRange.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedRange.end)}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.query_stats, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          "No History Found",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "No drying records found for $dateText.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteSession(Map<String, dynamic> session) async {
    // Extract identifiers from the session map
    final List<dynamic> chartData = session['chartData'] ?? [];
    if (chartData.isEmpty) return;

    // We use the exact timestamps of the first and last records in the grouped batch
    final String startTime = chartData.first['recorded_at'].toString();
    final String endTime = chartData.last['recorded_at'].toString();
    final String variety = session['variety'].toString();

    try {
      setState(() => _isLoading = true);

      // This query targets EVERY record of this variety between these two times
      final response = await Supabase.instance.client
          .from('sensor_history')
          .delete()
          .match({'rice_variety': variety})
          .gte('recorded_at', startTime)
          .lte('recorded_at', endTime)
          .select();

      if (response.isNotEmpty) {
        debugPrint("Successfully deleted ${response.length} records from DB.");

        // Crucial: Refresh the data from Supabase so the UI updates
        await _loadAllData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permanently deleted ${response.length} records.'),
            ),
          );
        }
      } else {
        debugPrint("Delete executed but 0 rows were affected.");
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
      // 1. Top Navigation
      appBar: CustomAppBar(
        title: 'Analysis',
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _loadAllData, icon: const Icon(Icons.refresh)),
        ],
      ),

      // 2. Main Content Layout
      body: Column(
        children: [
          // This takes up all available scrollable space
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      // Date Selector
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
                            // Crucial: Use a Key so the widget resets when underlying available varieties change
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
                      // No Data State
                      if (_filteredData.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildNoDataState(),
                        )
                      else ...[
                        // Detailed Graph (Only if single day)
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
                                  if (fullMap.isNotEmpty)
                                    _deleteSession(fullMap);
                                }
                              },
                            ),
                          ),

                        // Section Title
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
                              ),
                            ),
                          ),
                        ),

                        // Data Table
                        SliverToBoxAdapter(
                          child: _buildAnalysisTable(_filteredData),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ],
                  ),
          ),

          // 3. Persistent Export Button
          // This only shows if there is actually data to export
          if (_filteredData.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
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
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // 4. Bottom Navigation
      bottomNavigationBar: CustomBottomBar(currentRoute: '/analysis-screen'),
    );
  }

  Widget _buildAnalysisTable(List<Map<String, dynamic>> historicalCycles) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var session in historicalCycles) {
      String variety = session['variety'] ?? 'Unknown';
      if (variety == 'Standard' || variety == 'Unknown') continue;
      groupedData.putIfAbsent(variety, () => []);
      groupedData[variety]!.add(session);
      DateFormat(
        'MM/dd/yy',
      ).format(DateTime.parse(session['chartData'].first['recorded_at']));
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
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Weight',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Initial MC',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Duration',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Final MC',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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
                          Colors.blue.withOpacity(0.05),
                        ),
                        cells: [
                          const DataCell(
                            Text(
                              'AVERAGE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
