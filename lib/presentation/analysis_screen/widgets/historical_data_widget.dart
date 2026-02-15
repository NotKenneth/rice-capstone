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
    double maxX,
    bool useMinutes,
  ) {
    final theme = Theme.of(context);
    final spots = data
        .map(
          (d) => FlSpot(
            (d['hour'] as num).toDouble(),
            (d['moisture'] as num).toDouble(),
          ),
        )
        .toList();

    return LineChart(
      LineChartData(
        // DYNAMIC X-AXIS: Stops exactly at the recorded duration
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: 40,

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 10,
              getTitlesWidget: (v, m) =>
                  Text('${v.toInt()}%', style: const TextStyle(fontSize: 9)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              // Adjust interval so labels don't crowd on short durations
              interval: maxX > 2 ? 2 : maxX / 3,
              getTitlesWidget: (v, m) {
                // If duration is 0.5 (30 mins) and useMinutes is true,
                // you might need to multiply v by 60 for the label.
                String label = useMinutes
                    ? '${(v * 60).toInt()}m'
                    : '${v.toInt()}hr';
                return Text(label, style: const TextStyle(fontSize: 9));
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          drawVerticalLine: true,
          verticalInterval: maxX > 2 ? 2 : maxX / 3,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
    );
  }
}
