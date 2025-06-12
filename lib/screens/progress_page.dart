import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/study_session.dart';
import '../services/study_session_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String _selectedView = 'chart'; // 'chart' or 'list'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Progress'),
        actions: [
          IconButton(
            icon: Icon(_selectedView == 'chart' ? Icons.list : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'chart' ? 'list' : 'chart';
              });
            },
          ),
        ],
      ),
      body: Consumer<StudySessionService>(
        builder: (context, sessionService, child) {
          return FutureBuilder<Map<String, Duration>>(
            future: sessionService.getSubjectDurations(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final durations = snapshot.data!;
              if (durations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "No study data yet.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Return to previous screen
                        },
                        child: const Text('Start Studying'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (_selectedView == 'chart') ...[
                      _buildChart(durations),
                      const SizedBox(height: 20),
                      _buildTotalTime(durations),
                    ],
                    if (_selectedView == 'list') 
                      _buildList(durations),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChart(Map<String, Duration> durations) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: durations.values
                  .map((d) => d.inHours.toDouble())
                  .reduce((a, b) => a > b ? a : b) +
              1,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= durations.keys.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      durations.keys.elementAt(value.toInt()),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: durations.entries
              .map(
                (entry) => BarChartGroupData(
                  x: durations.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.inHours.toDouble(),
                      color: Colors.blue,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTotalTime(Map<String, Duration> durations) {
    final totalDuration = durations.values.reduce((a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Total Study Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Map<String, Duration> durations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: durations.length,
      itemBuilder: (context, index) {
        final entry = durations.entries.elementAt(index);
        return Card(
          child: ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${entry.value.inHours}h ${entry.value.inMinutes % 60}m',
            ),
            leading: const CircleAvatar(
              child: Icon(Icons.timer),
            ),
            trailing: Text(
              '${((entry.value.inMinutes / durations.values.map((d) => d.inMinutes).reduce((a, b) => a + b)) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
}