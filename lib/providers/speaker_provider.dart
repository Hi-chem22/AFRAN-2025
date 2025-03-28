import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/speaker.dart';

class SpeakerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Speaker> _speakers = [];
  List<Speaker> get speakers => _speakers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSpeakers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _speakers = await _apiService.getSpeakers();
    } catch (e) {
      print('Error loading speakers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Speaker? getSpeakerById(String id) {
    try {
      return _speakers.firstWhere((speaker) => speaker.id == id);
    } catch (e) {
      return null;
    }
  }
}
