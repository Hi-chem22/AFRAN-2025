// Configuration de l'application
class Config {
  // URLs de l'API
  static const String apiBaseUrlProd = 'https://api.afran2025.org';
  static const String apiBaseUrlDev = 'http://localhost:8080/api';
  
  // Clés pour les préférences partagées
  static const String prefsApiUrlKey = 'api_url';
  static const String prefsUseMockDataKey = 'use_mock_data';
  
  // Valeurs par défaut
  static const String defaultApiUrl = apiBaseUrlDev;
  static const bool defaultUseMockData = false;
  
  // Autres constantes
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration sessionCacheDuration = Duration(hours: 2);

  // Format de date standard
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  
  // Pour le mode éditeur
  static const bool isDebugMode = true;
} 