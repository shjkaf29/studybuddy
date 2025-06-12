import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/attendance.dart';

class AttendanceService extends ChangeNotifier {
  static const String _key = 'attendance_records';
  final List<Attendance> _attendance = [];

  Future<void> addAttendance(Attendance attendance) async {
    _attendance.add(attendance);
    await _saveAttendance();
    notifyListeners();
  }

  Future<List<Attendance>> getAttendance() async {
    await _loadAttendance();
    return _attendance;
  }

  Future<List<Attendance>> getAttendanceByDate(DateTime date) async {
    await _loadAttendance();
    return _attendance.where((a) => 
      a.date.year == date.year && 
      a.date.month == date.month && 
      a.date.day == date.day
    ).toList();
  }

  Future<double> getAttendancePercentage() async {
    await _loadAttendance();
    if (_attendance.isEmpty) return 0.0;
    final present = _attendance.where((a) => a.isPresent).length;
    return present / _attendance.length;
  }

  Future<Map<String, int>> getAttendanceStats() async {
    await _loadAttendance();
    return {
      'total': _attendance.length,
      'present': _attendance.where((a) => a.isPresent).length,
      'absent': _attendance.where((a) => !a.isPresent).length,
    };
  }

  Future<void> _saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _attendance.map((a) => a.toMap()).toList();
      await prefs.setString(_key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  Future<void> _loadAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _attendance.clear();
        _attendance.addAll(decoded.map((item) => Attendance.fromMap(item)));
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }
}