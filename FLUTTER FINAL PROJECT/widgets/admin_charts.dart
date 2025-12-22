import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_dashboard_service.dart';

/// Widget for displaying admin dashboard charts
class AdminChartsWidget extends StatelessWidget {
  final DashboardStats stats;

  const AdminChartsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        // Game Status Distribution Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Status Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildPieChart(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Payouts Over Time Chart
        if (stats.payoutsByMonth.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payouts Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildLineChart(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPieChart() {
    if (stats.gameStats.isEmpty) {
      return const Center(child: Text('No game data available'));
    }

    final sections = stats.gameStats.entries.map((entry) {
      final color = _getStatusColor(entry.key);
      final percentage = (entry.value /
              stats.gameStats.values.fold(0, (sum, count) => sum + count)) *
          100;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.gameStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.key),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key.toUpperCase()}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (stats.payoutsByMonth.isEmpty) {
      return const Center(child: Text('No payout data available'));
    }

    final sortedEntries = stats.payoutsByMonth.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
    }

    final maxY =
        sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  final monthKey = sortedEntries[index].key;
                  final parts = monthKey.split('-');
                  if (parts.length == 2) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${parts[1]}/${parts[0].substring(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 5,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: (sortedEntries.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.blue],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.purple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.purple.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  final monthKey = sortedEntries[index].key;
                  final amount = barSpot.y;
                  return LineTooltipItem(
                    '$monthKey\n\$${amount.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
