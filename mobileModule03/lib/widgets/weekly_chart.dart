import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../utils/date_formatter.dart';

class WeeklyChart extends StatelessWidget {
  final List<DailyItem> daily;

  const WeeklyChart({super.key, required this.daily});

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final maxSpots = <FlSpot>[
      for (int i = 0; i < daily.length; i++)
        FlSpot(i.toDouble(), daily[i].tempMax),
    ];
    final minSpots = <FlSpot>[
      for (int i = 0; i < daily.length; i++)
        FlSpot(i.toDouble(), daily[i].tempMin),
    ];

    final allTemps = [...maxSpots, ...minSpots].map((s) => s.y).toList();
    final minY = (allTemps.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY = (allTemps.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(Colors.orangeAccent, 'Max'),
              const SizedBox(width: 16),
              _legendDot(Colors.lightBlueAccent, 'Min'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
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
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}°',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= daily.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormatter.formatDate(daily[i].date),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10),
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
                      TextStyle(
                        color: t.bar.color ?? Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: maxSpots,
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: minSpots,
                    isCurved: true,
                    color: Colors.lightBlueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
