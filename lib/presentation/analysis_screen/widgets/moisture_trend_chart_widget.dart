import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoistureTrendChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final List<Map<String, dynamic>> varieties;
  final List<String> selectedVarieties;

  const MoistureTrendChartWidget({
    super.key,
    required this.chartData,
    required this.varieties,
    required this.selectedVarieties,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            // LOCK AXIS: This prevents lines from overlapping or going off-screen
            minX: 1,
            maxX: 12,
            minY: 5,
            maxY: 40,

            // BORDER: Adds a clean frame around the graph
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: theme.dividerColor, width: 1),
            ),

            // LEGENDS: Defines the X and Y axis labels
            titlesData: FlTitlesData(
              show: true,
              // Y-AXIS (Moisture %)
              leftTitles: AxisTitles(
                axisNameWidget: const Text(
                  "Moisture %",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 5, // Shows 5, 10, 15... 40
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              // X-AXIS (Time in Hours)
              bottomTitles: AxisTitles(
                axisNameWidget: const Text(
                  "Time (Hours)",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 2, // Shows 2h, 4h, 6h... 12h
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}h',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),

            // GRID: Helps distinguish values
            gridData: FlGridData(
              show: true,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),

            lineBarsData: varieties
                .where((v) => selectedVarieties.contains(v['name']))
                .map((variety) {
                  final varietyData = chartData
                      .where((d) => d['variety'] == variety['name'])
                      .toList();

                  return LineChartBarData(
                    spots: varietyData
                        .map(
                          (d) => FlSpot(
                            (d['hour'] as num).toDouble(),
                            (d['moisture'] as num).toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: variety['color'] as Color,
                    barWidth: 3,
                    dotData: const FlDotData(
                      show: false,
                    ), // Disable dots to prevent overlapping clutter
                    belowBarData: BarAreaData(
                      show: false,
                    ), // Disable shading to keep lines distinct
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }
}
