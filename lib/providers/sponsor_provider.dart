import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sponsor.dart';

class SponsorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Sponsor> _sponsors = [];
  List<Sponsor> get sponsors => _sponsors;
  
  List<Sponsor> get featuredSponsors => 
      _sponsors.where((sponsor) => sponsor.tier.toLowerCase() == 'platinum').toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSponsors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawSponsors = await _apiService.getSponsors();
      _sponsors = rawSponsors.map((json) => Sponsor.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sponsors: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour charger les sponsors
  Future<void> loadSponsors() async {
    if (_sponsors.isEmpty) {
      await fetchSponsors();
    }
  }

  // Get sponsors by tier (gold, silver, bronze, etc.)
  List<Sponsor> getSponsorsByTier(String tier) {
    return _sponsors.where((sponsor) => sponsor.tier.toLowerCase() == tier.toLowerCase()).toList();
  }
}
