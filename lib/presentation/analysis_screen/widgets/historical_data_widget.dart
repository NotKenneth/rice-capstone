import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../widgets/custom_icon_widget.dart';

class HistoricalDataWidget extends StatefulWidget {
  final List<Map<String, dynamic>> historicalCycles;

  const HistoricalDataWidget({super.key, required this.historicalCycles});

  @override
  State<HistoricalDataWidget> createState() => _HistoricalDataWidgetState();
}

class _HistoricalDataWidgetState extends State<HistoricalDataWidget> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Sensor History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.historicalCycles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cycle = widget.historicalCycles[index];
              final isExpanded = _expandedIndex == index;

              return Card(
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
                        cycle['variety'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(cycle['date']),
                      trailing: CustomIconWidget(
                        iconName: isExpanded ? 'expand_less' : 'expand_more',
                        size: 24,
                      ),
                    ),
                    if (isExpanded) _buildExpandedContent(context, cycle),
                  ],
                ),
              );
            },
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
    // Determine if we should show minutes or hours based on duration string/value
    // Assumes cycle['durationValue'] is a double (e.g. 0.5 for 30m or 12.0 for 12h)
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
                cycle['duration'],
                'schedule',
              ),
              _buildStatItem(
                context,
                'Start',
                '${cycle['initialMoisture']}%',
                'water_drop',
              ),
              _buildStatItem(
                context,
                'Latest',
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
              cycle['chartData'] as List<Map<String, dynamic>>,
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
    double recordedDuration, // This comes from your fetched data
    bool useMinutes,
  ) {
    final theme = Theme.of(context);

    // 1. Find the actual max time in your data to prevent the line from going out of bounds
    // If data is empty, default to 1.0 to avoid division by zero errors
    double dynamicMaxX = data.isEmpty
        ? 1.0
        : data
              .map((d) => (d['minute'] ?? 0).toDouble())
              .reduce((a, b) => a > b ? a : b);

    // Ensure maxX is at least a small value so the chart isn't a single vertical line at the start
    if (dynamicMaxX < 1.0) dynamicMaxX = 1.0;

    final spots = data.map((d) {
      return FlSpot(
        (d['minute'] ?? 0).toDouble(),
        (d['moisture'] ?? 0).toDouble(),
      );
    }).toList();

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        // 2. SET DYNAMIC BOUNDARIES
        minX: 0,
        maxX: dynamicMaxX,
        minY: 0,
        maxY: 40,

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              // 3. DYNAMIC INTERVAL: Divide the X-axis into 4 equal segments
              interval: dynamicMaxX / 4,
              getTitlesWidget: (v, m) {
                // Convert minutes to a readable format based on length
                if (dynamicMaxX <= 60) {
                  return Text(
                    '${v.toInt()}m',
                    style: const TextStyle(fontSize: 9),
                  );
                } else {
                  return Text(
                    '${(v / 60).toStringAsFixed(1)}h',
                    style: const TextStyle(fontSize: 9),
                  );
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: dynamicMaxX / 4, // Align grid with labels
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
    );
  }
}
