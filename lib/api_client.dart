import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiClient {
  final String baseUrl;
  final Duration timeout;
  
  ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
  });
  
  /// Récupère toutes les sessions
  Future<List<dynamic>> getSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sessions: $e');
    }
  }
  
  /// Récupère une session par ID
  Future<Map<String, dynamic>> getSessionById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions/$id'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de la session');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les speakers
  Future<List<dynamic>> getSpeakers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/speakers'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des speakers');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère un speaker par ID
  Future<Map<String, dynamic>> getSpeakerById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/speakers/$id'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération de l\'intervenant');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les sponsors
  Future<List<dynamic>> getSponsors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sponsors'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des sponsors');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère un sponsor par ID
  Future<Map<String, dynamic>> getSponsorById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sponsors/$id'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du sponsor');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère tous les partners
  Future<List<dynamic>> getPartners() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/partners'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des partenaires');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Récupère un partner par ID
  Future<Map<String, dynamic>> getPartnerById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/partners/$id'),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du partenaire');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  
  /// Import des données (admin)
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/import'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 