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

    // Determine the maximum time reached to scale the X-axis
    double maxTime = 30.0; // Start with at least a 30-min window
    for (var sensor in chartData) {
      if (sensor['maxMinute'] != null && sensor['maxMinute'] > maxTime) {
        maxTime = (sensor['maxMinute'] as num).toDouble();
      }
    }

    // Round maxX up to the next 30-minute interval for clean legends
    double maxX = ((maxTime / 30).ceil() * 30.0);

    return Container(
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            // FORCE START AT LEFT
            minX: 0,
            maxX: maxX,
            minY: 5,
            maxY: 35,

            // Clip data to prevent lines from bleeding into legends
            clipData: const FlClipData.all(),

            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
                left: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),

            titlesData: FlTitlesData(
              show: true,
              // X-AXIS: Show labels every 30 minutes
              bottomTitles: AxisTitles(
                axisNameWidget: const Text(
                  "Elapsed Time (Minutes)",
                  style: TextStyle(fontSize: 10),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 30, // <--- FORCES 30 MINUTE STEPS
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${value.toInt()}m',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 5,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
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

            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 5,
              verticalInterval: 30, // Grid lines align with 30m labels
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.dividerColor.withOpacity(0.05),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: theme.dividerColor.withOpacity(0.05),
                strokeWidth: 1,
              ),
            ),

            lineBarsData: varieties
                .where((v) => selectedVarieties.contains(v['name']))
                .map((variety) {
                  // Find the data specific to this sensor/variety
                  // Based on our _fetchAllSensorsHistory logic
                  final sensorData = chartData.firstWhere(
                    (d) =>
                        d['variety'].toString().contains(variety['name']) ||
                        d['variety'].toString().contains(
                          selectedVarieties.indexOf(variety['name']).toString(),
                        ),
                    orElse: () => {'chartData': []},
                  );

                  return LineChartBarData(
                    spots: (sensorData['chartData'] as List).map((d) {
                      return FlSpot(d['minute'], d['moisture']);
                    }).toList(),
                    isCurved: true,
                    color: variety['color'] as Color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }
}
