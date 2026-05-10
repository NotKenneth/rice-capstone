import 'package:dryce_monitoring_system/presentation/analysis_screen/widgets/rice_variety_history_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../widgets/custom_icon_widget.dart';

class HistoricalDataWidget extends StatefulWidget {
  final List<Map<String, dynamic>> historicalCycles;
  final Function(Map<String, dynamic> session) onDelete;

  const HistoricalDataWidget({
    super.key,
    required this.historicalCycles,
    required this.onDelete,
  });

  @override
  State<HistoricalDataWidget> createState() => _HistoricalDataWidgetState();
}

class _HistoricalDataWidgetState extends State<HistoricalDataWidget> {
  int? _expandedIndex;

  /* bool _shouldShowTimeline() {
    if (widget.historicalCycles.isEmpty) return false;

    return widget.historicalCycles.length >= 1;
  }*/

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text(
          "Are you sure you want to delete this session? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final showTimeline = _shouldShowTimeline();

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CONDITIONAL TIMELINE CHART SECTION
            /* if (showTimeline) ...[
              Text(
                'Processing Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 250,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: RiceVarietyHistoryChart(
                  historicalCycles: widget.historicalCycles,
                ),
              ),
              const SizedBox(height: 24),
            ],*/

            // 2. DETAILED LIST SECTION (Always visible)
            Text(
              'Real-time Sensor History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Handle empty state for the list specifically
            if (widget.historicalCycles.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "No data found for this range",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.historicalCycles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final cycle = widget.historicalCycles[index];
                  final isExpanded = _expandedIndex == index;
                  final sessionId =
                      cycle['session_id']?.toString() ?? "temp_$index";

                  return Dismissible(
                    key: Key('delete_session_$sessionId'),
                    direction: DismissDirection.endToStart,
                    dragStartBehavior: DragStartBehavior.down,
                    confirmDismiss: (direction) =>
                        _showDeleteConfirmation(context),
                    onDismissed: (direction) => widget.onDelete(cycle),
                    secondaryBackground: _buildDeleteBackground(),
                    background: Container(),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => setState(
                              () => _expandedIndex = isExpanded ? null : index,
                            ),
                            leading: _buildLeadingIcon(theme),
                            title: Text(
                              cycle['variety'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(cycle['date'] ?? ''),
                            trailing: CustomIconWidget(
                              iconName: isExpanded
                                  ? 'expand_less'
                                  : 'expand_more',
                              size: 24,
                            ),
                          ),
                          if (isExpanded) _buildExpandedContent(context, cycle),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25.0),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_forever, color: Colors.white, size: 30),
          Text(
            "Delete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: 'history',
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    Map<String, dynamic> cycle,
  ) {
    final double duration = (cycle['durationValue'] ?? 12.0).toDouble();
    final bool isShortDuration = duration <= 1.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Duration',
                cycle['duration'] ?? '0h',
                'schedule',
              ),
              _buildStatItem(
                context,
                'Initial MC',
                '${cycle['initialMoisture']}%',
                'water_drop',
              ),
              _buildStatItem(
                context,
                'Final MC',
                '${cycle['finalMoisture']}%',
                'check_circle',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: _buildThumbnailChart(
              context,
              (cycle['chartData'] as List?)?.cast<Map<String, dynamic>>() ?? [],
              duration,
              isShortDuration,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String iconName,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildThumbnailChart(
    BuildContext context,
    List<Map<String, dynamic>> data,
    double recordedDuration,
    bool useMinutes,
  ) {
    final theme = Theme.of(context);
    if (data.isEmpty) return const Center(child: Text("No data points"));

    final int startIndex = data.length > 1 ? 1 : 0;

    Map<String, List<FlSpot>> sensorLines = {};
    final String rawTimestamp =
        data.first['recorded_at']?.toString() ??
        DateTime.now().toIso8601String();
    DateTime sessionStart = DateTime.parse(rawTimestamp);

    double dynamicMaxX = 0.0;
    double minMoisture = 100.0;
    double maxMoisture = 0.0;

    for (var row in data) {
      String id = row['sensor_id']?.toString() ?? 'Unknown';
      DateTime time = DateTime.parse(
        row['recorded_at']?.toString() ?? DateTime.now().toIso8601String(),
      );
      double minutes = time.difference(sessionStart).inSeconds / 60.0;
      double moisture = (row['moisture_percentage'] as num? ?? 0.0).toDouble();

      if (minutes > dynamicMaxX) dynamicMaxX = minutes;
      if (moisture < minMoisture) minMoisture = moisture;
      if (moisture > maxMoisture) maxMoisture = moisture;

      sensorLines.putIfAbsent(id, () => []);
      sensorLines[id]!.add(FlSpot(minutes, moisture));
    }

    double minY = (minMoisture - 2).clamp(0, 100);
    double maxY = (maxMoisture + 2).clamp(0, 100);
    final List<Color> areaColors = [
      theme.colorScheme.primary,
      Colors.orange,
      Colors.teal,
      Colors.purple,
    ];

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              minX: 0,
              maxX: dynamicMaxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: sensorLines.keys.toList().asMap().entries.map((
                entry,
              ) {
                return LineChartBarData(
                  spots: sensorLines[entry.value]!,
                  isCurved: true,
                  color: areaColors[entry.key % areaColors.length],
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(
                    "Drying Time (Min)",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  axisNameSize: 18,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    interval: (dynamicMaxX / 4) > 0 ? dynamicMaxX / 4 : 1,
                    getTitlesWidget: (v, m) => Text(
                      '${v.toInt()}m',
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    "Moisture Content (%)",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  axisNameSize: 22,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: (maxY - minY) / 5 > 0 ? (maxY - minY) / 5 : 1,
                    getTitlesWidget: (v, m) => Text(
                      '${v.toInt()}%',
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                verticalInterval: (dynamicMaxX / 4) > 0 ? dynamicMaxX / 4 : 1,
                horizontalInterval: (maxY - minY) / 5 > 0
                    ? (maxY - minY) / 5
                    : 1,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                getDrawingVerticalLine: (v) =>
                    FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // LEGEND
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sensorLines.keys.toList().asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: areaColors[entry.key % areaColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Area ${entry.key + 1}",
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
