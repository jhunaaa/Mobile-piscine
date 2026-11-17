import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../utils/date_formatter.dart';

class HourlyChart extends StatelessWidget {
  final List<HourlyItem> hourly;

  const HourlyChart({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[
      for (int i = 0; i < hourly.length; i++)
        FlSpot(i.toDouble(), hourly[i].temperature),
    ];

    final temps = spots.map((s) => s.y).toList();
    final minY = (temps.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY = (temps.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Colors.white24, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= hourly.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormatter.formatHour(hourly[i].time),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched
                  .map((t) => LineTooltipItem(
                '${t.y.toStringAsFixed(1)} °C',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.lightBlueAccent,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.lightBlueAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
