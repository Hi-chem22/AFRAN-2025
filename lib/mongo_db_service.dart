import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import './data/mock_data.dart';

/// A service class for MongoDB operations
class MongoDbService {
  final String username;
  final String password;
  final String host;
  final String databaseName;
  final String dataSource;
  Db? _db;
  bool _isConnected = false;
  
  // Paramètres pour l'URI de connexion correcte
  static const String _replicaSet = 'atlas-kh0q9s-shard-0';
  static const List<String> _shardHosts = [
    'cluster0-shard-00-00.pt98b.mongodb.net:27017',
    'cluster0-shard-00-01.pt98b.mongodb.net:27017',
    'cluster0-shard-00-02.pt98b.mongodb.net:27017'
  ];

  // This constructor is for the new MongoDbService style
  MongoDbService({
    required this.username,
    required this.password,
    required this.host,
    required this.databaseName,
    required this.dataSource,
  });
  
  // This constructor is for backward compatibility with the old MongoDBService
  factory MongoDbService.fromUrl({required String mongoUrl}) {
    return MongoDbService(
      username: 'hichem',
      password: '40221326Hi',
      host: 'cluster0.pt98b.mongodb.net',
      databaseName: 'afran_db',
      dataSource: 'AframDB',
    );
  }

  /// Create an instance with the AFRAN project connection details
  factory MongoDbService.afranDb() {
    return MongoDbService(
      username: 'hichem',
      password: '40221326Hi',
      host: 'cluster0.pt98b.mongodb.net',
      databaseName: 'afran_db',
      dataSource: 'AframDB',
    );
  }

  /// Get the MongoDB connection URI
  String get connectionUri {
    // Web platforms require a different approach
    if (kIsWeb) {
      // Use standard connection string based on the mongosh command
      return 'mongodb://${_shardHosts.join(',')}/?replicaSet=$_replicaSet&authSource=admin&tls=true';
    } else {
      // Use SRV protocol for non-web platforms
      return 'mongodb+srv://$username:$password@$host/$databaseName?retryWrites=true&w=majority';
    }
  }

  /// Get the direct connection string for mongosh
  String get mongoshConnectionString {
    return 'mongosh "mongodb://${_shardHosts.join(',')}/?replicaSet=$_replicaSet" --apiVersion 1 --tls --authenticationDatabase admin --username $username --password $password';
  }

  /// Check if connected to MongoDB
  bool get isConnected => _isConnected;

  /// Connect to MongoDB
  Future<void> connect() async {
    // If already connected, don't connect again
    if (_isConnected && _db != null && _db!.state == State.OPEN) {
      return;
    }
    
    // If there's an existing connection but not in OPEN state, close it first
    if (_db != null) {
      try {
        await _db!.close();
      } catch (e) {
        // Ignore close errors
      }
    }
    
    try {
      // Use the connection URI that includes authentication
      final String connectionString = 'mongodb+srv://$username:$password@$host/$databaseName?retryWrites=true&w=majority&authSource=admin';
      
      if (kIsWeb) {
        try {
          // Standard connection attempt for web
          _db = await Db.create(connectionString);
          await _db!.open();
          _isConnected = true;
        } catch (e) {
          print('Web connection error: $e');
          // On web, simulate connection for development purposes
          _isConnected = true;
          return;
        }
      } else {
        // Standard connection for non-web platforms
        _db = await Db.create(connectionString);
        await _db!.open();
        
        if (_db!.state != State.OPEN) {
          throw StateError('Database is not in OPEN state after connection. Current state: ${_db!.state}');
        }
        
        _isConnected = true;
        print('Successfully connected to MongoDB');
      }
    } catch (e) {
      print('Connection error: $e');
      rethrow;
    }
  }

  /// Close the MongoDB connection
  Future<void> close() async {
    if (_db != null) {
      try {
        await _db!.close();
        _isConnected = false;
      } catch (e) {
        // Ignore close errors
      }
    }
  }

  /// Get a collection by name
  DbCollection collection(String name) {
    if (!_isConnected || _db == null) {
      throw StateError('Not connected to MongoDB. Call connect() first.');
    }
    return _db!.collection(name);
  }

  /// List all collection names
  Future<List<String>> getCollectionNames() async {
    if (!_isConnected || _db == null) {
      throw StateError('Not connected to MongoDB. Call connect() first.');
    }
    // Vérifier si la base de données est dans le bon état
    if (_db!.state != State.OPEN) {
      print('Database state is ${_db!.state}, attempting to reconnect...');
      await close(); // Fermer complètement la connexion existante
      await connect(); // Tenter de se reconnecter
      if (_db!.state != State.OPEN) {
        throw StateError('Database is not in OPEN state after reconnection attempt. Current state: ${_db!.state}');
      }
    }
    // Convert nullable String? to non-nullable String
    final collections = await _db!.getCollectionNames();
    return collections.where((name) => name != null).map((name) => name!).toList();
  }

  /// Insert a document into a collection
  Future<ObjectId> insertDocument(String collectionName, Map<String, dynamic> document) async {
    final result = await collection(collectionName).insertOne(document);
    return result.id as ObjectId;
  }

  /// Find documents in a collection
  Future<List<Map<String, dynamic>>> findDocuments(
    String collectionName, {
    Map<String, dynamic>? query,
    int? limit,
    int? skip,
    SelectorBuilder? selector,
  }) async {
    // Si nous sommes sur le web et qu'il y a des problèmes de connexion, retourner des données fictives
    if (kIsWeb && (_db == null || !_isConnected)) {
      print('Retour de données fictives pour $collectionName sur le web car pas de connexion');
      // Simuler un délai réseau
      await Future.delayed(Duration(milliseconds: 300));
      
      // Retourner des données de test selon la collection
      switch (collectionName) {
        case 'sessions':
          return mockSessions;
        case 'speakers':
          return mockSpeakers;
        case 'sponsors':
          return mockSponsors;
        case 'partners':
          return mockPartners;
        case 'settings':
          if (selector != null) {
            // Si on cherche le message de bienvenue
            final selectorMap = selector.map;
            if (selectorMap.containsKey('key') && selectorMap['key'] == 'welcome_message') {
              return [{'key': 'welcome_message', 'title': welcomeMessage['title'], 'message': welcomeMessage['message']}];
            }
          }
          return [];
        default:
          return [];
      }
    }
    
    // Pour les autres plateformes ou si la connexion web fonctionne
    final queryBuilder = selector ?? where;
    if (query != null && query.isNotEmpty) {
      query.forEach((key, value) {
        queryBuilder.eq(key, value);
      });
    }
    
    var finder = collection(collectionName).find(queryBuilder);
    
    if (skip != null) {
      finder = finder.skip(skip);
    }
    
    if (limit != null) {
      finder = finder.take(limit);
    }
    
    final results = await finder.toList();
    return results;
  }

  /// Update documents in a collection
  Future<int> updateDocuments(
    String collectionName,
    dynamic selector,
    Map<String, dynamic> update, {
    bool upsert = false,
    bool multiUpdate = false,
  }) async {
    final result = await collection(collectionName).update(
      selector is SelectorBuilder ? selector : where.eq('_id', selector),
      {
        '\$set': update,
      },
      upsert: upsert,
      multiUpdate: multiUpdate,
    );
    
    // Return either modified or matched count based on availability
    return result['nModified'] as int? ?? result['n'] as int? ?? 0;
  }

  /// Delete documents from a collection
  Future<int> deleteDocuments(
    String collectionName,
    dynamic selector,
  ) async {
    final result = await collection(collectionName).remove(
      selector is SelectorBuilder ? selector : where.eq('_id', selector),
    );
    
    // Return the number of documents removed
    return result['n'] as int? ?? 0;
  }

  /// Get list of collection names
  Future<List<String>> listCollections() async {
    if (!_isConnected) {
      await connect();
    }
    
    if (_db!.state != State.OPEN) {
      await connect();
      
      if (_db!.state != State.OPEN) {
        return [];
      }
    }
    
    try {
      final collections = await _db!.getCollectionNames();
      return collections;
    } catch (e) {
      if (kIsWeb) {
        // For web, return default collections
        return ['sessions', 'speakers', 'sponsors', 'partners', 'settings'];
      }
      rethrow;
    }
  }

  /// Count documents in a collection
  Future<int> countDocuments(String collectionName, {SelectorBuilder? selector}) async {
    if (!_isConnected) {
      await connect();
    }
    
    final col = collection(collectionName);
    return await col.count(selector);
  }

  /// Import mock data into MongoDB Atlas
  Future<void> importMockData() async {
    if (!_isConnected) {
      await connect();
    }
    
    // Import sessions
    for (final session in mockSessions) {
      await insertDocument('sessions', session);
    }
    
    // Import speakers
    for (final speaker in mockSpeakers) {
      await insertDocument('speakers', speaker);
    }
    
    // Import sponsors
    for (final sponsor in mockSponsors) {
      await insertDocument('sponsors', sponsor);
    }
    
    // Import partners
    for (final partner in mockPartners) {
      await insertDocument('partners', partner);
    }
    
    // Import welcome message
    await insertDocument('settings', {
      'key': 'welcome_message',
      'title': welcomeMessage['title'],
      'message': welcomeMessage['message']
    });
    
    print('Mock data successfully imported to MongoDB Atlas');
  }
  
  // Compatibility methods for old MongoDBService class
  
  // Test connection to MongoDB
  Future<bool> testConnection() async {
    try {
      if (!isConnected) {
        await connect();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Check if database has any data
  Future<bool> isDatabasePopulated() async {
    if (!_isConnected) {
      await connect();
    }
    
    final stats = await getCollectionStats();
    return stats.values.any((count) => count > 0);
  }
  
  /// Get collection stats
  Future<Map<String, int>> getCollectionStats() async {
    final Map<String, int> stats = {
      'sessions': 0,
      'speakers': 0,
      'sponsors': 0,
      'partners': 0,
    };
    
    if (!_isConnected) {
      if (kIsWeb) {
        // Return some mock data for web during development
        return {
          'sessions': 42,
          'speakers': 18,
          'sponsors': 12,
          'partners': 8,
        };
      }
      await connect();
    }
    
    if (_db!.state != State.OPEN) {
      await connect();
    }
    
    try {
      for (final String collectionName in stats.keys) {
        stats[collectionName] = await countDocuments(collectionName);
      }
      return stats;
    } catch (e) {
      if (kIsWeb) {
        // Return some mock data for web during development
        return {
          'sessions': 42,
          'speakers': 18,
          'sponsors': 12,
          'partners': 8,
        };
      }
      rethrow;
    }
  }

  /// Create an index on a collection
  Future<void> createIndex(
    String collectionName,
    Map<String, dynamic> keys, {
    String? name,
    bool unique = false,
  }) async {
    if (!_isConnected || _db == null) {
      throw StateError('Not connected to MongoDB. Call connect() first.');
    }
    
    final collection = _db!.collection(collectionName);
    await collection.createIndex(
      keys,
      name: name,
      unique: unique,
    );
  }

  /// Get the database instance
  Db? get db => _db;
} 