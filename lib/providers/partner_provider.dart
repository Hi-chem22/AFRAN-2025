import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/partner.dart';

class PartnerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Partner> _partners = [];
  List<Partner> get partners => _partners;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchPartners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawPartners = await _apiService.getPartners();
      _partners = rawPartners.map((json) => Partner.fromJson(json)).toList();
    } catch (e) {
      print('Error loading partners: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Méthode pour charger les partenaires
  Future<void> loadPartners() async {
    if (_partners.isEmpty) {
      await fetchPartners();
    }
  }

  // Get partners by type
  List<Partner> getPartnersByType(String type) {
    return _partners.where((partner) => partner.type.toLowerCase() == type.toLowerCase()).toList();
  }
} 