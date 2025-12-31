import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Historical drying cycles with collapsible cards
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
            'Historical Drying Cycles',
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
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'history',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        cycle['variety'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        cycle['date'] as String,
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: CustomIconWidget(
                        iconName: isExpanded ? 'expand_less' : 'expand_more',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  'Duration',
                                  cycle['duration'] as String,
                                  'schedule',
                                ),
                                _buildStatItem(
                                  context,
                                  'Initial',
                                  '${cycle['initialMoisture']}%',
                                  'water_drop',
                                ),
                                _buildStatItem(
                                  context,
                                  'Final',
                                  '${cycle['finalMoisture']}%',
                                  'check_circle',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: _buildThumbnailChart(
                                context,
                                cycle['chartData']
                                    as List<Map<String, dynamic>>,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
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
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailChart(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final theme = Theme.of(context);

    final spots = data.map((d) {
      return FlSpot(
        (d['hour'] as num).toDouble(),
        (d['moisture'] as num).toDouble(),
      );
    }).toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: spots.last.x,
        minY: 0,
        maxY: 30,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
