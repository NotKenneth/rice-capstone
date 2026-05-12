import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml

class RiceVarietyHistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> historicalCycles;

  const RiceVarietyHistoryChart({super.key, required this.historicalCycles});

  Color _getVarietyColor(String variety) {
    switch (variety.toUpperCase().trim()) {
      case 'RC 402':
        return Colors.blue;
      case 'RC 160':
        return Colors.green;
      case 'RC 216':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  // Helper to format duration for the Y-axis and tooltips
  String _formatDuration(double totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes.toInt()}m';
    } else {
      int hours = totalMinutes ~/ 60;
      int minutes = (totalMinutes % 60).toInt();
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (historicalCycles.isEmpty) return const Center(child: Text("No data"));

    final sortedData = List<Map<String, dynamic>>.from(historicalCycles)
      ..sort((a, b) {
        final dA =
            DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
        final dB =
            DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
        return dA.compareTo(dB);
      });

    Map<String, List<FlSpot>> varietySpots = {};
    double maxMinutes = 0;

    for (int i = 0; i < sortedData.length; i++) {
      final cycle = sortedData[i];
      final variety = cycle['variety']?.toString() ?? 'Unknown';

      // Ensure we are working with minutes for accuracy
      final double durationInMinutes =
          (cycle['durationValue'] as num?)?.toDouble() ?? 0.0;

      if (durationInMinutes > maxMinutes) maxMinutes = durationInMinutes;

      varietySpots.putIfAbsent(variety, () => []);
      varietySpots[variety]!.add(FlSpot(i.toDouble(), durationInMinutes));
    }

    final List<LineChartBarData> lineBarsData = varietySpots.entries.map((
      entry,
    ) {
      final color = _getVarietyColor(entry.key);
      return LineChartBarData(
        spots: entry.value,
        isCurved: sortedData.length > 2,
        color: color,
        barWidth: 4,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
      );
    }).toList();

    return LineChart(
      LineChartData(
        // Add padding to maxX so labels on the right don't overflow the screen
        maxX: sortedData.length > 1 ? (sortedData.length - 0.7) : 1.0,
        maxY: (maxMinutes * 1.2).clamp(10, double.infinity),

        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((barSpot) {
                final variety = varietySpots.keys.elementAt(barSpot.barIndex);
                return LineTooltipItem(
                  '$variety\n${_formatDuration(barSpot.y)}',
                  TextStyle(
                    color: _getVarietyColor(variety),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
        ),

        showingTooltipIndicators: lineBarsData.asMap().entries.map((entry) {
          return ShowingTooltipIndicators([
            LineBarSpot(entry.value, entry.key, entry.value.spots.last),
          ]);
        }).toList(),

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < sortedData.length) {
                  // Shows full date (e.g., Oct 12)
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Transform.rotate(
                      angle: -0.5, // Rotate slightly to prevent overlapping
                      child: Text(
                        sortedData[index]['date'].toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (v, m) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  _formatDuration(v), // Dynamic minutes/hours labels
                  style: const TextStyle(fontSize: 9, color: Colors.white70),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: lineBarsData,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
          getDrawingVerticalLine: (v) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
