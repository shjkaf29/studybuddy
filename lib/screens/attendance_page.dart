import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';  // Updated import path
import 'package:provider/provider.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Tracker')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<AttendanceService>(
                builder: (context, attendanceService, _) {
                  return FutureBuilder<double>(
                    future: attendanceService.getAttendancePercentage(),
                    builder: (context, snapshot) {
                      final percentage = snapshot.data ?? 0.0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 8.0,
                            percent: percentage,
                            center: Text(
                              "${(percentage * 100).toInt()}%",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            progressColor: Colors.green,
                            backgroundColor: Colors.green.withOpacity(0.2),
                          ),
                          Column(
                            children: [
                              const Text(
                                'Total Sessions',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<List<Attendance>>(
                                future: attendanceService.getAttendance(),
                                builder: (context, snapshot) {
                                  final count = snapshot.data?.length ?? 0;
                                  return Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAttendanceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAttendanceDialog(BuildContext context) {
    String selectedSubject = 'General';
    int duration = 60;
    bool isPresent = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mark Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: ['General', 'Math', 'Science', 'History', 'English']
                    .map((subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedSubject = value!);
                },
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: duration.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                onChanged: (value) {
                  duration = int.tryParse(value) ?? 60;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Present'),
                value: isPresent,
                onChanged: (value) {
                  setState(() => isPresent = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final attendance = Attendance(
                  id: DateTime.now().toString(),
                  date: DateTime.now(),
                  subject: selectedSubject,
                  isPresent: isPresent,
                  studyDuration: duration,
                );
                
                Provider.of<AttendanceService>(context, listen: false)
                    .addAttendance(attendance);
                    
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}