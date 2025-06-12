import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/study_session.dart';
import '../services/study_session_service.dart';
import 'package:provider/provider.dart';

class StudyTimerPage extends StatefulWidget {
  const StudyTimerPage({Key? key}) : super(key: key);

  @override
  State<StudyTimerPage> createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _isRunning = false;
  String _selectedSubject = 'General';
  double _progress = 0.0;
  int _targetMinutes = 25; // Default Pomodoro time

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) {
      setState(() {
        _progress = value / (_targetMinutes * 60 * 1000);
        if (_progress >= 1.0) {
          _stopTimer();
          _showCompletionDialog();
        }
      });
    });
  }

  void _stopTimer() {
    _stopWatchTimer.onStopTimer();
    setState(() => _isRunning = false);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text('You\'ve completed $_targetMinutes minutes of studying!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSession();
            },
            child: const Text('Save Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSession() async {
    final session = StudySession(
      id: DateTime.now().toString(),
      subject: _selectedSubject,
      startTime: DateTime.now().subtract(Duration(minutes: _targetMinutes)),
      endTime: DateTime.now(),
      targetDuration: _targetMinutes,
    );

    await Provider.of<StudySessionService>(context, listen: false)
        .addSession(session);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Timer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Select Subject',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedSubject,
                        items: [
                          'General',
                          'Math',
                          'Science',
                          'History',
                          'English',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedSubject = newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Set Timer Duration',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTimeButton(25, 'Pomodoro'),
                          _buildTimeButton(45, 'Long'),
                          _buildTimeButton(15, 'Short'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CircularPercentIndicator(
                radius: 130.0,
                lineWidth: 15.0,
                animation: true,
                percent: _progress.clamp(0.0, 1.0),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: 0,
                      builder: (context, snap) {
                        final value = snap.data!;
                        final displayTime = StopWatchTimer.getDisplayTime(
                          value,
                          hours: false,
                          milliSecond: false,
                        );
                        return Text(
                          displayTime,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    Text(
                      _selectedSubject,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isRunning) {
                          _stopWatchTimer.onStopTimer();
                        } else {
                          _stopWatchTimer.onStartTimer();
                        }
                        _isRunning = !_isRunning;
                      });
                    },
                    icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(_isRunning ? 'Stop' : 'Start'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      _stopWatchTimer.onResetTimer();
                      setState(() {
                        _progress = 0.0;
                        _isRunning = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(int minutes, String label) {
    final isSelected = _targetMinutes == minutes;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
      ),
      onPressed: () => setState(() => _targetMinutes = minutes),
      child: Text('$minutes min\n$label'),
    );
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }
}