import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../models/speaker.dart';
import '../models/sponsor.dart';
import '../models/partner.dart';
import '../data/mock_data.dart';
import '../providers/data_source_provider.dart';
import '../mongo_db_service.dart';
import 'api_client.dart';

// Définition de l'URL du backend
const String BACKEND_URL = 'http://192.168.1.5:8080';

class ApiService {
  // Variable pour indiquer si on utilise des données fictives
  final bool useMockData;
  final String backendUrl;
  final ApiClient _apiClient;
  
  // Constructeur avec un client API
  ApiService({
    this.useMockData = false, 
    this.backendUrl = BACKEND_URL,
    ApiClient? apiClient
  }) : _apiClient = apiClient ?? ApiClient(offlineMode: useMockData);
  
  // Fermer le client quand on n'en a plus besoin
  void dispose() {
    _apiClient.dispose();
  }

  /// Récupère toutes les sessions
  Future<List<dynamic>> getSessions() async {
    try {
      print('Fetching sessions from: $backendUrl/api/sessions');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sessions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère les sessions par jour
  Future<Map<String, dynamic>> getSessionsByDay() async {
    try {
      print('Fetching sessions by day from: $backendUrl/api/sessions/by-day');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sessions/by-day'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sessions par jour: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sessions by day: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère les sessions en vedette
  Future<List<dynamic>> getFeaturedSessions() async {
    try {
      print('Fetching featured sessions from: $backendUrl/api/sessions/featured');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sessions/featured'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sessions en vedette: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching featured sessions: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère une session par ID
  Future<Map<String, dynamic>> getSessionById(String id) async {
    try {
      print('Fetching session by ID from: $backendUrl/api/sessions/$id');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sessions/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de la session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching session by ID: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère les sessions à venir
  Future<List<dynamic>> getUpcomingSessions() async {
    try {
      print('Fetching upcoming sessions from: $backendUrl/api/sessions/upcoming');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sessions/upcoming'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sessions à venir: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching upcoming sessions: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les speakers
  Future<List<dynamic>> getSpeakers() async {
    try {
      print('Fetching speakers from: $backendUrl/api/speakers');
      final response = await http.get(
        Uri.parse('$backendUrl/api/speakers'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des speakers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching speakers: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère un speaker par ID
  Future<Map<String, dynamic>> getSpeakerById(String id) async {
    try {
      print('Fetching speaker by ID from: $backendUrl/api/speakers/$id');
      final response = await http.get(
        Uri.parse('$backendUrl/api/speakers/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du speaker: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching speaker by ID: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les sponsors
  Future<List<dynamic>> getSponsors() async {
    try {
      print('Fetching sponsors from: $backendUrl/api/sponsors');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sponsors'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sponsors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sponsors: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère les sponsors par tier
  Future<Map<String, dynamic>> getSponsorsByTier() async {
    try {
      print('Fetching sponsors by tier from: $backendUrl/api/sponsors/by-tier');
      final response = await http.get(
        Uri.parse('$backendUrl/api/sponsors/by-tier'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sponsors par tier: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sponsors by tier: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les partenaires
  Future<List<dynamic>> getPartners() async {
    try {
      print('Fetching partners from: $backendUrl/api/partners');
      final response = await http.get(
        Uri.parse('$backendUrl/api/partners'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des partenaires: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching partners: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère le message de bienvenue
  Future<Map<String, dynamic>> getWelcomeMessage() async {
    try {
      print('Fetching welcome message from: $backendUrl/api/welcome-message');
      final response = await http.get(
        Uri.parse('$backendUrl/api/welcome-message'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du message de bienvenue: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching welcome message: $e');
      throw Exception('Erreur réseau: $e');
    }
  }
}
