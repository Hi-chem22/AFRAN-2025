import 'package:mongo_dart/mongo_dart.dart';
import '../mongo_db_service.dart';

/// This is a compatibility wrapper around the new MongoDbService
/// It provides the interface expected by the existing code
class MongoDBService {
  final String mongoUrl;
  final MongoDbService _service;
  
  MongoDBService({required this.mongoUrl}) : _service = MongoDbService.fromUrl(mongoUrl: mongoUrl);
  
  Future<bool> testConnection() async {
    return await _service.testConnection();
  }
  
  Future<void> close() async {
    await _service.close();
  }
  
  Future<Map<String, int>> getCollectionStats() async {
    return await _service.getCollectionStats();
  }
  
  Future<bool> isDatabasePopulated() async {
    return await _service.isDatabasePopulated();
  }
  
  Future<void> importMockData() async {
    await _service.importMockData();
  }
  
  // Ajout des méthodes pour que la classe soit un remplacement complet
  Future<void> connect() async {
    await _service.connect();
  }
  
  Future<List<String>> getCollectionNames() async {
    return await _service.listCollections();
  }
  
  Future<List<Map<String, dynamic>>> findDocuments(
    String collectionName, {
    Map<String, dynamic>? query,
    int? limit,
    int? skip,
    SelectorBuilder? selector,
  }) async {
    return await _service.findDocuments(
      collectionName,
      query: query,
      limit: limit,
      skip: skip,
      selector: selector,
    );
  }
  
  DbCollection collection(String name) {
    return _service.collection(name);
  }
  
  bool get isConnected => _service.isConnected;
} 