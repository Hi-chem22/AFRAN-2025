import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import '../config.dart';

class DataSourceProvider with ChangeNotifier {
  // État de la source de données
  bool _useMockData = false;
  String _apiUrl = Config.defaultApiUrl;
  ApiClient? _apiClient;
  
  // Getters
  bool get useMockData => _useMockData;
  String get apiUrl => _apiUrl;
  ApiClient get apiClient {
    if (_apiClient == null) {
      debugPrint('Creating new ApiClient with URL: $_apiUrl');
      _apiClient = ApiClient(baseUrl: _apiUrl, offlineMode: _useMockData);
    }
    return _apiClient!;
  }
  
  DataSourceProvider() {
    debugPrint('Initializing DataSourceProvider with API URL: $_apiUrl');
    _loadSettings();
  }
  
  // Charger les paramètres depuis les préférences partagées
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer l'URL de l'API
      final savedApiUrl = prefs.getString(Config.prefsApiUrlKey);
      if (savedApiUrl != null && savedApiUrl.isNotEmpty) {
        _apiUrl = savedApiUrl;
        debugPrint('Loaded saved API URL: $_apiUrl');
      } else {
        debugPrint('Using default API URL: $_apiUrl');
      }
      
      // Récupérer le paramètre de données fictives
      final savedUseMockData = prefs.getBool(Config.prefsUseMockDataKey);
      if (savedUseMockData != null) {
        _useMockData = savedUseMockData;
      } else {
        // Par défaut, utiliser les vraies données
        _useMockData = false;
      }
      
      // Initialiser le client API
      _apiClient = ApiClient(baseUrl: _apiUrl);
      debugPrint('Initialized ApiClient with URL: ${_apiClient?.apiUrl}');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres: $e');
    }
  }
  
  // Définir l'URL de l'API
  Future<void> setApiUrl(String url) async {
    if (url != _apiUrl) {
      debugPrint('Updating API URL from $_apiUrl to $url');
      _apiUrl = url;
      _apiClient?.dispose();
      _apiClient = ApiClient(baseUrl: _apiUrl, offlineMode: _useMockData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Config.prefsApiUrlKey, _apiUrl);
      
      notifyListeners();
    }
  }
  
  // Définir le mode de données fictives
  Future<void> setUseMockData(bool value) async {
    if (value != _useMockData) {
      _useMockData = value;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(Config.prefsUseMockDataKey, _useMockData);
      
      notifyListeners();
    }
  }
  
  // Réinitialiser les paramètres
  Future<void> resetSettings() async {
    debugPrint('Resetting settings to default values');
    _apiUrl = Config.defaultApiUrl;
    _useMockData = Config.defaultUseMockData;
    _apiClient = ApiClient(baseUrl: _apiUrl);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Config.prefsApiUrlKey, _apiUrl);
    await prefs.setBool(Config.prefsUseMockDataKey, _useMockData);
    
    notifyListeners();
  }
} 