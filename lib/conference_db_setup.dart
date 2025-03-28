import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_db_service.dart';
import 'mongodb_schema.dart';

/// Utility class to set up and initialize the conference database
class ConferenceDbSetup {
  final MongoDbService _dbService;
  
  /// Create a new instance with the provided MongoDB service
  ConferenceDbSetup(this._dbService);
  
  /// Create a new instance with the AFRAN project MongoDB service
  factory ConferenceDbSetup.afranDb() {
    return ConferenceDbSetup(MongoDbService.afranDb());
  }
  
  /// Initialize the database with all collections and indexes
  Future<void> initializeDatabase() async {
    if (!_dbService.isConnected) {
      await _dbService.connect();
    }
    
    // Create all collections and indexes
    await _createCollections();
    await _createIndexes();
    
    print('Conference database initialized successfully!');
  }
  
  /// Create sample data for demonstration purposes
  Future<void> createSampleData() async {
    if (!_dbService.isConnected) {
      await _dbService.connect();
    }
    
    final sampleData = MongoDBSchemas.getSampleDocuments();
    
    // Insert sample speakers
    final speakerId = await _dbService.insertDocument('speakers', sampleData['speakers']!);
    print('Created sample speaker with ID: $speakerId');
    
    // Insert sample room
    final roomId = await _dbService.insertDocument('rooms', sampleData['rooms']!);
    print('Created sample room with ID: $roomId');
    
    // Insert sample session with room reference
    final sessionData = Map<String, dynamic>.from(sampleData['sessions']!);
    sessionData['room_id'] = roomId;
    final sessionId = await _dbService.insertDocument('sessions', sessionData);
    print('Created sample session with ID: $sessionId');
    
    // Insert sample subsession with session and speaker references
    final subsessionData = Map<String, dynamic>.from(sampleData['subsessions']!);
    subsessionData['session_id'] = sessionId;
    subsessionData['speaker_id'] = speakerId;
    final subsessionId = await _dbService.insertDocument('subsessions', subsessionData);
    print('Created sample subsession with ID: $subsessionId');
    
    // Insert sample subsubsession with subsession and speaker references
    final subsubsessionData = Map<String, dynamic>.from(sampleData['subsubsessions']!);
    subsubsessionData['subsession_id'] = subsessionId;
    subsubsessionData['speaker_id'] = speakerId;
    final subsubsessionId = await _dbService.insertDocument('subsubsessions', subsubsessionData);
    print('Created sample subsubsession with ID: $subsubsessionId');
    
    // Insert sample sponsor
    await _dbService.insertDocument('sponsors', sampleData['sponsors']!);
    print('Created sample sponsor');
    
    // Insert sample message
    await _dbService.insertDocument('messages', sampleData['messages']!);
    print('Created sample message');
    
    // Insert sample ad
    await _dbService.insertDocument('ads', sampleData['ads']!);
    print('Created sample ad');
    
    print('Sample data created successfully!');
  }
  
  /// Create all collections needed for the conference database
  Future<void> _createCollections() async {
    final collectionNames = MongoDBSchemas.getCollectionNames();
    
    for (final collectionName in collectionNames) {
      // Check if collection exists
      final collections = await _dbService.getCollectionNames();
      if (!collections.contains(collectionName)) {
        // Create the collection by inserting and then deleting a document
        // This is a common pattern since mongo_dart doesn't have a direct "createCollection" method
        final tempDoc = {'_temp': true};
        final collection = _dbService.collection(collectionName);
        await collection.insertOne(tempDoc);
        await collection.deleteOne({'_temp': true});
        print('Created collection: $collectionName');
      } else {
        print('Collection already exists: $collectionName');
      }
    }
  }
  
  /// Create indexes for all collections
  Future<void> _createIndexes() async {
    final indexes = MongoDBSchemas.getIndexes();
    
    for (final entry in indexes.entries) {
      final collectionName = entry.key;
      final collectionIndexes = entry.value;
      
      for (final indexDef in collectionIndexes) {
        final name = indexDef['name'] as String;
        final keys = indexDef['keys'] as Map<String, dynamic>;
        final unique = indexDef['unique'] == true;
        
        try {
          await _dbService.createIndex(
            collectionName,
            keys,
            name: name,
            unique: unique,
          );
          print('Created index $name on $collectionName');
        } catch (e) {
          print('Error creating index $name on $collectionName: $e');
        }
      }
    }
  }
  
  /// Drop all collections and recreate the database structure
  Future<void> resetDatabase() async {
    if (!_dbService.isConnected) {
      await _dbService.connect();
    }
    
    // Drop all existing collections
    final collections = await _dbService.getCollectionNames();
    
    for (final collectionName in collections) {
      if (collectionName != 'system.indexes') {
        await _dbService._db!.dropCollection(collectionName);
        print('Dropped collection: $collectionName');
      }
    }
    
    // Recreate collections and indexes
    await _createCollections();
    await _createIndexes();
    
    print('Database reset successfully!');
  }
  
  /// Close the database connection
  Future<void> close() async {
    await _dbService.close();
  }
} 