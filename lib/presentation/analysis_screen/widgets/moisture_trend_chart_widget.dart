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

    // Calculate X-Axis Range
    double maxTime = 30.0;
    for (var session in chartData) {
      if (selectedVarieties.contains(session['variety'])) {
        final List rawLogs = session['chartData'] as List? ?? [];
        if (rawLogs.isNotEmpty) {
          try {
            DateTime start = DateTime.parse(
              rawLogs.first['recorded_at'].toString(),
            );
            DateTime end = DateTime.parse(
              rawLogs.last['recorded_at'].toString(),
            );
            double duration = end.difference(start).inSeconds / 60.0;
            if (duration > maxTime) maxTime = duration;
          } catch (e) {
            debugPrint("X-Axis Calc Error: $e");
          }
        }
      }
    }

    double maxX = ((maxTime / 30).ceil() * 30.0);
    if (maxX == 0) maxX = 30.0;

    return Container(
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: 0,
            maxY: 40,
            clipData: const FlClipData.all(),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: theme.colorScheme.surface.withOpacity(0.9),
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)}%',
                        TextStyle(
                          color: s.bar.color ?? Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                axisNameWidget: const Text(
                  "Elapsed Time (Minutes)",
                  style: TextStyle(fontSize: 10),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 30,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}m',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
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
              horizontalInterval: 5,
              verticalInterval: 30,
              getDrawingHorizontalLine: (v) => FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (v) => FlLine(
                color: theme.dividerColor.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),

            lineBarsData: varieties
                .where((v) => selectedVarieties.contains(v['name']))
                .map((variety) {
                  final session = chartData.firstWhere(
                    (d) =>
                        d['variety'].toString() == variety['name'].toString(),
                    orElse: () => {'chartData': []},
                  );

                  final List rawLogs = session['chartData'] as List? ?? [];
                  if (rawLogs.isEmpty) return LineChartBarData(spots: []);

                  DateTime sessionStart = DateTime.parse(
                    rawLogs.first['recorded_at'].toString(),
                  );

                  List<FlSpot> spots = rawLogs.map((log) {
                    DateTime logTime = DateTime.parse(
                      log['recorded_at'].toString(),
                    );
                    double minutes =
                        logTime.difference(sessionStart).inSeconds / 60.0;
                    double moisture =
                        (log['moisture_percentage'] as num? ?? 0.0).toDouble();
                    return FlSpot(minutes, moisture);
                  }).toList();

                  spots.sort((a, b) => a.x.compareTo(b.x));

                  return LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: variety['color'] as Color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (variety['color'] as Color).withOpacity(0.1),
                    ),
                  );
                })
                .where((bar) => bar.spots.isNotEmpty)
                .toList(),
          ),
        ),
      ),
    );
  }
}
