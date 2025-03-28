import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import '../models/speaker.dart';

class SessionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  List<Session> _featuredSessions = [];
  List<Session> get featuredSessions => _featuredSessions;

  List<Session> _upcomingSessions = [];
  List<Session> get upcomingSessions => _upcomingSessions;

  List<Speaker> _speakers = [];
  List<Speaker> get speakers => _speakers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawSessions = await _apiService.getSessions();
      _sessions = rawSessions.map((json) => Session.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sessions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour charger toutes les sessions
  Future<void> loadAllSessions() async {
    if (_sessions.isEmpty) {
      await fetchSessions();
    }
  }

  // Méthode pour charger les sessions à la une
  Future<void> loadFeaturedSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_sessions.isEmpty) {
        await fetchSessions();
      }
      _featuredSessions = _sessions.where((session) => session.isFeatured).toList();
    } catch (e) {
      print('Error loading featured sessions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour charger les sessions à venir
  Future<void> loadUpcomingSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_sessions.isEmpty) {
        await fetchSessions();
      }
      
      // Pour une démo, nous prenons simplement les 3 premières sessions
      // Dans une app réelle, il faudrait les trier par date/heure
      _upcomingSessions = _sessions.take(3).toList();
    } catch (e) {
      print('Error loading upcoming sessions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour charger les speakers
  Future<void> loadSpeakers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawSpeakers = await _apiService.getSpeakers();
      _speakers = rawSpeakers.map((json) => Speaker.fromJson(json)).toList();
    } catch (e) {
      print('Error loading speakers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour récupérer une session par ID
  Future<Session> getSessionById(String id) async {
    if (_sessions.isEmpty) {
      await fetchSessions();
    }
    
    final session = _sessions.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Session not found')
    );
    
    return session;
  }

  // Méthode pour récupérer les sessions d'un jour spécifique
  List<Session> getSessionsByDay(int day) {
    return _sessions.where((session) => session.day == day).toList();
  }
}
