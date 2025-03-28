import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/speaker.dart';
import '../models/sponsor.dart';
import '../models/partner.dart';
import '../data/mock_data.dart'; // Pour le fallback en mode hors ligne
import '../config.dart';

class ApiClient {
  // URL de base pour l'API 
  final String _baseUrl;
  
  // Timeout pour les requêtes
  static const Duration _timeout = Duration(seconds: 10);
  
  // Instance http client
  final http.Client _client;
  
  // Mode hors ligne (utilise des données fictives)
  final bool _offlineMode;
  
  // Getter pour l'URL de base
  String get apiUrl => _baseUrl;
  
  // Constructeur
  ApiClient({
    http.Client? client, 
    bool offlineMode = false,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _offlineMode = offlineMode,
       _baseUrl = baseUrl ?? Config.defaultApiUrl {
    debugPrint('Initializing ApiClient with base URL: $_baseUrl');
  }
      
  // Fermer le client quand on n'en a plus besoin
  void dispose() {
    _client.close();
  }
  
  // Méthode générique pour effectuer des requêtes GET
  Future<List<dynamic>> _get(String endpoint) async {
    // Si on est en mode hors ligne, on retourne des données fictives
    if (_offlineMode) {
      debugPrint('Using offline mode for endpoint: $endpoint');
      return _getMockData(endpoint);
    }
    
    try {
      final url = '$_baseUrl/api$endpoint';
      debugPrint('Making GET request to: $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        // Fallback vers des données fictives en cas d'erreur
        return _getMockData(endpoint);
      }
    } catch (e) {
      debugPrint('Exception lors de la requête API: $e');
      // Fallback vers des données fictives en cas d'exception
      return _getMockData(endpoint);
    }
  }
  
  // Méthode générique pour effectuer des requêtes GET qui retournent un seul objet
  Future<Map<String, dynamic>> _getSingle(String endpoint) async {
    // Si on est en mode hors ligne, on retourne des données fictives
    if (_offlineMode) {
      debugPrint('Using offline mode for endpoint: $endpoint');
      return _getMockDataSingle(endpoint);
    }
    
    try {
      final url = '$_baseUrl$endpoint';
      debugPrint('Making GET request to: $url');
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        // Fallback vers des données fictives en cas d'erreur
        return _getMockDataSingle(endpoint);
      }
    } catch (e) {
      debugPrint('Exception lors de la requête API: $e');
      // Fallback vers des données fictives en cas d'exception
      return _getMockDataSingle(endpoint);
    }
  }
  
  // Méthodes spécifiques pour chaque type de données
  
  // Récupérer toutes les sessions
  Future<List<Session>> getSessions() async {
    final data = await _get('/sessions');
    return data.map((json) => Session.fromJson(json)).toList();
  }
  
  // Récupérer les sessions d'un jour spécifique
  Future<List<Session>> getSessionsByDay(int day) async {
    final data = await _get('/sessions/day/$day');
    return data.map((json) => Session.fromJson(json)).toList();
  }
  
  // Récupérer les sessions en vedette
  Future<List<Session>> getFeaturedSessions() async {
    final data = await _get('/sessions/featured');
    return data.map((json) => Session.fromJson(json)).toList();
  }
  
  // Récupérer tous les speakers
  Future<List<Speaker>> getSpeakers() async {
    final data = await _get('/speakers');
    return data.map((json) => Speaker.fromJson(json)).toList();
  }
  
  // Récupérer un speaker par ID
  Future<Speaker> getSpeakerById(String id) async {
    final data = await _getSingle('/speakers/$id');
    return Speaker.fromJson(data);
  }
  
  // Récupérer tous les sponsors
  Future<List<Sponsor>> getSponsors() async {
    final data = await _get('/sponsors');
    return data.map((json) => Sponsor.fromJson(json)).toList();
  }
  
  // Récupérer les sponsors par tier
  Future<List<Sponsor>> getSponsorsByTier(String tier) async {
    final data = await _get('/sponsors/tier/$tier');
    return data.map((json) => Sponsor.fromJson(json)).toList();
  }
  
  // Récupérer tous les partenaires
  Future<List<Partner>> getPartners() async {
    final data = await _get('/partners');
    return data.map((json) => Partner.fromJson(json)).toList();
  }
  
  // Récupérer le message de bienvenue
  Future<Map<String, String>> getWelcomeMessage() async {
    final data = await _getSingle('/welcome');
    return {
      'title': data['title'] ?? 'Bienvenue',
      'message': data['message'] ?? 'Bienvenue au Congrès AFRAN 2025'
    };
  }
  
  // Méthode pour simuler des données en mode hors ligne ou en cas d'erreur
  List<dynamic> _getMockData(String endpoint) {
    // Retourner les données fictives correspondant à l'endpoint
    if (endpoint.startsWith('/sessions/day/')) {
      // Extraire le numéro du jour depuis l'endpoint
      final day = int.parse(endpoint.split('/').last);
      return mockSessions.where((session) => session['day'] == day).toList();
    } else if (endpoint == '/sessions/featured') {
      return mockSessions.where((session) => session['isFeatured'] == true).toList();
    } else if (endpoint == '/sessions') {
      return mockSessions;
    } else if (endpoint == '/speakers') {
      return mockSpeakers;
    } else if (endpoint.startsWith('/sponsors/tier/')) {
      // Extraire le tier depuis l'endpoint
      final tier = endpoint.split('/').last.toLowerCase();
      return mockSponsors.where((sponsor) => sponsor['tier'].toLowerCase() == tier).toList();
    } else if (endpoint == '/sponsors') {
      return mockSponsors;
    } else if (endpoint == '/partners') {
      return mockPartners;
    }
    
    // Par défaut, retourner une liste vide
    return [];
  }
  
  // Méthode pour simuler des données uniques en mode hors ligne ou en cas d'erreur
  Map<String, dynamic> _getMockDataSingle(String endpoint) {
    // Retourner les données fictives correspondant à l'endpoint
    if (endpoint.startsWith('/speakers/')) {
      // Extraire l'ID du speaker depuis l'endpoint
      final speakerId = endpoint.split('/').last;
      final speaker = mockSpeakers.firstWhere(
        (speaker) => speaker['id'] == speakerId,
        orElse: () => mockSpeakers.first,
      );
      return speaker;
    } else if (endpoint == '/welcome') {
      return welcomeMessage;
    }
    
    // Par défaut, retourner un objet vide
    return {};
  }
} 