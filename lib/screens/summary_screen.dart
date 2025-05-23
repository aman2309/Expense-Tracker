import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../provider/expense_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    final Map<String, double> categoryTotals = {};
    final Map<String, double> monthlyTotals = {};

    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;

      final month = DateFormat.yMMM().format(e.date);
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + e.amount;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title:  Text('Expense Summary',style: TextStyle(fontWeight: FontWeight.bold),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 200, child: _CategoryPieChart()),

            const SizedBox(height: 32),
            const Text('Monthly Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: _MonthlyBarChart(monthlyTotals: monthlyTotals)),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  const _CategoryPieChart();

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    final Map<String, double> data = {};
    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    final total = data.values.fold(0.0, (sum, val) => sum + val);
    if (total == 0) return const Center(child: Text("No data"));

    return PieChart(
      PieChartData(
        sections: data.entries.map((e) {
          final percent = ((e.value / total) * 100).toStringAsFixed(1);
          return PieChartSectionData(
            value: e.value,
            title: '${e.key}\n$percent%',
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12),
          );
        }).toList(),
        sectionsSpace: 4,
        centerSpaceRadius: 32,
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final Map<String, double> monthlyTotals;

  const _MonthlyBarChart({required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    final months = monthlyTotals.keys.toList();
    months.sort((a, b) => DateFormat.yMMM().parse(a).compareTo(DateFormat.yMMM().parse(b)));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyTotals.values.fold<double>(0, (prev, val) => val > prev ? val : prev) + 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Text(months[index].substring(0, 3));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(months.length, (index) {
          final val = monthlyTotals[months[index]]!;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: val, width: 18, color: Colors.black),
            ],
          );
        }),
      ),
    );
  }
}
