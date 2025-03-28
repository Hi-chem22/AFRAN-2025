/// MongoDB schema definitions for the conference database
/// Converted from SQL to MongoDB document structure

/// Example document structures for each collection in the MongoDB database
class MongoDBSchemas {
  /// speakers collection schema
  static const Map<String, dynamic> speakerSchema = {
    'full_name': 'String', // Required
    'bio': 'String?',
    'country_code': 'String?', // ISO country code (e.g., US, FR)
    'image_url': 'String?',
    'created_at': 'DateTime'
  };

  /// rooms collection schema
  static const Map<String, dynamic> roomSchema = {
    'name': 'String', // Required
    'capacity': 'int?',
    'location': 'String?',
    'created_at': 'DateTime'
  };

  /// sessions collection schema
  static const Map<String, dynamic> sessionSchema = {
    'title': 'String', // Required
    'description': 'String?',
    'room_id': 'ObjectId?', // Reference to rooms collection
    'start_time': 'DateTime', // Required
    'end_time': 'DateTime', // Required
    'created_at': 'DateTime'
  };

  /// subsessions collection schema
  static const Map<String, dynamic> subsessionSchema = {
    'session_id': 'ObjectId', // Reference to sessions collection
    'title': 'String', // Required
    'description': 'String?',
    'speaker_id': 'ObjectId?', // Reference to speakers collection
    'start_time': 'DateTime', // Required
    'end_time': 'DateTime', // Required
    'created_at': 'DateTime'
  };

  /// subsubsessions collection schema
  static const Map<String, dynamic> subsubsessionSchema = {
    'subsession_id': 'ObjectId', // Reference to subsessions collection
    'title': 'String', // Required
    'description': 'String?',
    'speaker_id': 'ObjectId?', // Reference to speakers collection
    'start_time': 'DateTime', // Required
    'end_time': 'DateTime', // Required
    'created_at': 'DateTime'
  };

  /// sponsors collection schema
  static const Map<String, dynamic> sponsorSchema = {
    'name': 'String', // Required
    'logo_url': 'String?',
    'website_url': 'String?',
    'created_at': 'DateTime'
  };

  /// messages collection schema
  static const Map<String, dynamic> messageSchema = {
    'title': 'String', // Required
    'content': 'String?',
    'created_at': 'DateTime'
  };

  /// ads collection schema
  static const Map<String, dynamic> adSchema = {
    'image_url': 'String?',
    'link_url': 'String?',
    'created_at': 'DateTime'
  };

  /// Get all collection names
  static List<String> getCollectionNames() {
    return [
      'speakers',
      'rooms',
      'sessions',
      'subsessions',
      'subsubsessions',
      'sponsors',
      'messages',
      'ads'
    ];
  }

  /// MongoDB indexes to create
  static Map<String, List<Map<String, dynamic>>> getIndexes() {
    return {
      'speakers': [
        {'keys': {'full_name': 1}, 'name': 'idx_speaker_name'}
      ],
      'rooms': [
        {'keys': {'name': 1}, 'name': 'idx_room_name', 'unique': true}
      ],
      'sessions': [
        {'keys': {'start_time': 1}, 'name': 'idx_session_start_time'},
        {'keys': {'room_id': 1}, 'name': 'idx_session_room'}
      ],
      'subsessions': [
        {'keys': {'session_id': 1}, 'name': 'idx_subsession_session'},
        {'keys': {'speaker_id': 1}, 'name': 'idx_subsession_speaker'}
      ],
      'subsubsessions': [
        {'keys': {'subsession_id': 1}, 'name': 'idx_subsubsession_subsession'},
        {'keys': {'speaker_id': 1}, 'name': 'idx_subsubsession_speaker'}
      ],
      'sponsors': [
        {'keys': {'name': 1}, 'name': 'idx_sponsor_name', 'unique': true}
      ]
    };
  }

  /// Create a sample document for each collection
  static Map<String, Map<String, dynamic>> getSampleDocuments() {
    final now = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    
    return {
      'speakers': {
        'full_name': 'John Doe',
        'bio': 'Expert en science',
        'country_code': 'US',
        'image_url': 'https://example.com/john.jpg',
        'created_at': now
      },
      'rooms': {
        'name': 'Salle A',
        'capacity': 200,
        'location': '1er étage',
        'created_at': now
      },
      'sessions': {
        'title': 'Session 1',
        'description': 'Introduction à la recherche',
        'room_id': null, // This would be set to an actual ObjectId in practice
        'start_time': tomorrow.add(const Duration(hours: 9)),
        'end_time': tomorrow.add(const Duration(hours: 11)),
        'created_at': now
      },
      'subsessions': {
        'session_id': null, // This would be set to an actual ObjectId in practice
        'title': 'Intervention A',
        'description': 'Présentation scientifique',
        'speaker_id': null, // This would be set to an actual ObjectId in practice
        'start_time': tomorrow.add(const Duration(hours: 9, minutes: 30)),
        'end_time': tomorrow.add(const Duration(hours: 10)),
        'created_at': now
      },
      'subsubsessions': {
        'subsession_id': null, // This would be set to an actual ObjectId in practice
        'title': 'Sous-intervention 1',
        'description': 'Discussion approfondie',
        'speaker_id': null, // This would be set to an actual ObjectId in practice
        'start_time': tomorrow.add(const Duration(hours: 9, minutes: 45)),
        'end_time': tomorrow.add(const Duration(hours: 10)),
        'created_at': now
      },
      'sponsors': {
        'name': 'PharmaCorp',
        'logo_url': 'https://example.com/pharma.png',
        'website_url': 'https://pharmacorp.com',
        'created_at': now
      },
      'messages': {
        'title': 'Message du président',
        'content': 'Bienvenue au congrès annuel !',
        'created_at': now
      },
      'ads': {
        'image_url': 'https://example.com/ad1.png',
        'link_url': 'https://pharma.com',
        'created_at': now
      }
    };
  }
} 