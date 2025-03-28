import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  // Connection details
  final username = "hichem";
  final password = "40221326Hi";
  final dbName = "AfranDB";
  
  // Connection URI using MongoDB Atlas connection format for mongo_dart
  final uri = "mongodb+srv://$username:$password@cluster0.pt98b.mongodb.net/$dbName?retryWrites=true&w=majority";
  
  try {
    // Connect to MongoDB
    print("Connecting to MongoDB...");
    final db = await Db.create(uri);
    await db.open();
    print("✅ Successfully connected to MongoDB Atlas!");
    
    // Get reference to a collection
    final usersCollection = db.collection("users");
    
    // List all collections
    print("\n--- Listing all collections ---");
    final collections = await db.getCollectionNames();
    for (final collection in collections) {
      print(" - $collection");
    }
    
    // Query documents
    print("\n--- Finding users ---");
    final users = await usersCollection.find().toList();
    print("Found ${users.length} users");
    
    // Print user data
    if (users.isNotEmpty) {
      print("\n--- User details ---");
      for (final user in users) {
        print(" - Name: ${user['name']}, Email: ${user['email']}, Age: ${user['age']}");
      }
    }
    
    // Create a new user
    print("\n--- Creating a new user ---");
    final result = await usersCollection.insertOne({
      'name': 'Emma Davis',
      'email': 'emma@example.com',
      'age': 32,
      'createdAt': DateTime.now()
    });
    
    print("Inserted user with ID: ${result.id}");
    
    // Update a document
    print("\n--- Updating a user ---");
    if (users.isNotEmpty) {
      final firstUser = users.first;
      final updateResult = await usersCollection.updateOne(
        where.eq('_id', firstUser['_id']),
        modify.set('lastUpdated', DateTime.now())
              .set('status', 'active')
      );
      
      print("Updated ${updateResult.nModified} user");
    }
    
    // Close the connection
    await db.close();
    print("\nMongoDB connection closed");
    
  } catch (e) {
    print("Error: $e");
  }
} 