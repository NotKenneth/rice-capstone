import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Interactive moisture trend chart with pinch-to-zoom and pan gestures
class MoistureTrendChartWidget extends StatefulWidget {
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
  State<MoistureTrendChartWidget> createState() =>
      _MoistureTrendChartWidgetState();
}

class _MoistureTrendChartWidgetState extends State<MoistureTrendChartWidget> {
  double _minX = 0;
  double _maxX = 24;
  final double _minY = 0;
  double _maxY = 30;
  int? _touchedSpotIndex;

  @override
  void initState() {
    super.initState();
    _calculateAxisBounds();
  }

  void _calculateAxisBounds() {
    if (widget.chartData.isEmpty) return;

    double maxHour = 0;
    double maxMoisture = 0;

    for (var data in widget.chartData) {
      final hour = (data['hour'] as num).toDouble();
      final moisture = (data['moisture'] as num).toDouble();
      if (hour > maxHour) maxHour = hour;
      if (moisture > maxMoisture) maxMoisture = moisture;
    }

    setState(() {
      _maxX = maxHour + 2;
      _maxY = (maxMoisture + 5).ceilToDouble();
    });
  }

  List<LineChartBarData> _buildChartLines() {
    final List<LineChartBarData> lines = [];

    for (var variety in widget.varieties) {
      final varietyName = variety['name'] as String;
      if (!widget.selectedVarieties.contains(varietyName)) continue;

      final varietyColor = variety['color'] as Color;
      final varietyData = widget.chartData
          .where((d) => d['variety'] == varietyName)
          .toList();

      if (varietyData.isEmpty) continue;

      final spots = varietyData.map((d) {
        return FlSpot(
          (d['hour'] as num).toDouble(),
          (d['moisture'] as num).toDouble(),
        );
      }).toList();

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: varietyColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: varietyColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: varietyColor.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moisture Content Trend',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Semantics(
              label:
                  'Moisture content trend chart showing drying progress over time',
              child: GestureDetector(
                onScaleUpdate: (details) {
                  if (details.scale != 1.0) {
                    setState(() {
                      final range = _maxX - _minX;
                      final newRange = range / details.scale;
                      final center = (_maxX + _minX) / 2;
                      _minX = (center - newRange / 2).clamp(0, _maxX - 1);
                      _maxX = (center + newRange / 2).clamp(_minX + 1, 48);
                    });
                  }
                },
                child: LineChart(
                  LineChartData(
                    minX: _minX,
                    maxX: _maxX,
                    minY: _minY,
                    maxY: _maxY,
                    lineBarsData: _buildChartLines(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
                        axisNameWidget: Text(
                          'Moisture %',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}h',
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
                        axisNameWidget: Text(
                          'Time (hours)',
                          style: theme.textTheme.labelSmall,
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
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                            if (response?.lineBarSpots != null &&
                                response!.lineBarSpots!.isNotEmpty) {
                              setState(() {
                                _touchedSpotIndex =
                                    response.lineBarSpots!.first.spotIndex;
                              });
                            } else {
                              setState(() {
                                _touchedSpotIndex = null;
                              });
                            }
                          },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final varietyIndex = touchedSpots.indexOf(spot);
                            final variety = widget.varieties[varietyIndex];
                            return LineTooltipItem(
                              '${variety['name']}\n${spot.y.toStringAsFixed(1)}%',
                              theme.textTheme.bodySmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
