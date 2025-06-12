import 'package:flutter/foundation.dart';
import '../models/study_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudySessionService extends ChangeNotifier {
  final List<StudySession> _sessions = [];

  Future<void> addSession(StudySession session) async {
    _sessions.add(session);
    await _saveSessions();
    notifyListeners();
  }

  Future<List<StudySession>> getSessions() async {
    await _loadSessions();
    return _sessions;
  }

  Future<Map<String, Duration>> getSubjectDurations() async {
    await _loadSessions();
    final Map<String, Duration> totals = {};
    
    for (var session in _sessions) {
      totals[session.subject] = (totals[session.subject] ?? Duration.zero) + session.duration;
    }
    
    return totals;
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _sessions.map((s) => s.toMap()).toList();
      await prefs.setString('study_sessions', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving sessions: $e');
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('study_sessions');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _sessions.clear();
        _sessions.addAll(decoded.map((item) => StudySession.fromMap(item)));
      }
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    }
  }
}