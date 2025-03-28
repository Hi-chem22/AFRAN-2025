import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import '../lib/mongo_db_service.dart';

void main() async {
  // Create MongoDB service using factory method with predefined connection details
  final mongoService = MongoDbService.afranDb();
  
  try {
    // Connect to MongoDB
    print('Connecting to MongoDB Atlas...');
    await mongoService.connect();
    
    // List all collections
    print('\n=== Collections in database ===');
    final collections = await mongoService.getCollectionNames();
    for (final collection in collections) {
      print(' - $collection');
    }
    
    // Select a collection to work with
    final usersCollection = 'users';
    
    // Find all users
    print('\n=== Finding all users ===');
    final users = await mongoService.findDocuments(usersCollection);
    print('Found ${users.length} users');
    
    // Print user details
    if (users.isNotEmpty) {
      print('\n=== User details ===');
      for (final user in users) {
        print(' - Name: ${user['name']}, Email: ${user['email']}, Age: ${user['age']}');
      }
    }
    
    // Interactive menu
    await showMenu(mongoService);
    
  } catch (e) {
    print('Error: $e');
  } finally {
    // Close the connection
    await mongoService.close();
  }
}

/// Interactive menu for MongoDB operations
Future<void> showMenu(MongoDbService mongoService) async {
  final collectionName = 'users';
  
  while (true) {
    print('\n=== MongoDB Operations Menu ===');
    print('1. List all collections');
    print('2. View all users');
    print('3. Add a new user');
    print('4. Update a user');
    print('5. Delete a user');
    print('6. Search users by criteria');
    print('7. Exit');
    
    stdout.write('\nEnter your choice (1-7): ');
    final choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        // List collections
        final collections = await mongoService.getCollectionNames();
        print('\nCollections:');
        for (final collection in collections) {
          print(' - $collection');
        }
        break;
        
      case '2':
        // View users
        final users = await mongoService.findDocuments(collectionName);
        
        if (users.isEmpty) {
          print('\nNo users found');
        } else {
          print('\nUsers:');
          for (int i = 0; i < users.length; i++) {
            final user = users[i];
            print('${i + 1}. ${user['name']} - ${user['email']} (Age: ${user['age']})');
          }
        }
        break;
        
      case '3':
        // Add new user
        stdout.write('\nEnter name: ');
        final name = stdin.readLineSync() ?? '';
        
        stdout.write('Enter email: ');
        final email = stdin.readLineSync() ?? '';
        
        stdout.write('Enter age: ');
        final ageInput = stdin.readLineSync() ?? '0';
        final age = int.tryParse(ageInput) ?? 0;
        
        final newUser = {
          'name': name,
          'email': email,
          'age': age,
          'createdAt': DateTime.now()
        };
        
        final id = await mongoService.insertDocument(collectionName, newUser);
        print('\nUser added successfully with ID: $id');
        break;
        
      case '4':
        // Update user
        final users = await mongoService.findDocuments(collectionName);
        
        if (users.isEmpty) {
          print('\nNo users found to update');
          break;
        }
        
        print('\nSelect a user to update:');
        for (int i = 0; i < users.length; i++) {
          print('${i + 1}. ${users[i]['name']} - ${users[i]['email']}');
        }
        
        stdout.write('\nEnter user number: ');
        final userNumInput = stdin.readLineSync() ?? '0';
        final userNum = int.tryParse(userNumInput) ?? 0;
        
        if (userNum < 1 || userNum > users.length) {
          print('\nInvalid selection');
          break;
        }
        
        final selectedUser = users[userNum - 1];
        
        stdout.write('\nEnter new name (leave empty to keep current): ');
        final name = stdin.readLineSync() ?? '';
        
        stdout.write('Enter new email (leave empty to keep current): ');
        final email = stdin.readLineSync() ?? '';
        
        stdout.write('Enter new age (leave empty to keep current): ');
        final ageInput = stdin.readLineSync() ?? '';
        
        Map<String, dynamic> updates = {};
        if (name.isNotEmpty) updates['name'] = name;
        if (email.isNotEmpty) updates['email'] = email;
        if (ageInput.isNotEmpty) {
          final age = int.tryParse(ageInput);
          if (age != null) updates['age'] = age;
        }
        
        updates['lastUpdated'] = DateTime.now();
        
        final updateCount = await mongoService.updateDocuments(
          collectionName, 
          selectedUser['_id'],
          updates
        );
        
        print('\nUpdated $updateCount user');
        break;
        
      case '5':
        // Delete user
        final users = await mongoService.findDocuments(collectionName);
        
        if (users.isEmpty) {
          print('\nNo users found to delete');
          break;
        }
        
        print('\nSelect a user to delete:');
        for (int i = 0; i < users.length; i++) {
          print('${i + 1}. ${users[i]['name']} - ${users[i]['email']}');
        }
        
        stdout.write('\nEnter user number: ');
        final userNumInput = stdin.readLineSync() ?? '0';
        final userNum = int.tryParse(userNumInput) ?? 0;
        
        if (userNum < 1 || userNum > users.length) {
          print('\nInvalid selection');
          break;
        }
        
        final selectedUser = users[userNum - 1];
        
        stdout.write('\nAre you sure you want to delete ${selectedUser['name']}? (y/n): ');
        final confirm = stdin.readLineSync()?.toLowerCase() ?? 'n';
        
        if (confirm == 'y') {
          final deleteCount = await mongoService.deleteDocuments(
            collectionName, 
            selectedUser['_id']
          );
          
          print('\nDeleted $deleteCount user');
        } else {
          print('\nDeletion cancelled');
        }
        break;
        
      case '6':
        // Search users
        print('\nSearch options:');
        print('1. Search by name');
        print('2. Search by email');
        print('3. Search by age range');
        
        stdout.write('\nEnter search option (1-3): ');
        final searchOption = stdin.readLineSync() ?? '1';
        
        SelectorBuilder query = where;
        
        switch (searchOption) {
          case '1':
            stdout.write('Enter name to search: ');
            final name = stdin.readLineSync() ?? '';
            query = where.match('name', name, caseInsensitive: true);
            break;
            
          case '2':
            stdout.write('Enter email to search: ');
            final email = stdin.readLineSync() ?? '';
            query = where.match('email', email, caseInsensitive: true);
            break;
            
          case '3':
            stdout.write('Enter minimum age: ');
            final minAgeInput = stdin.readLineSync() ?? '0';
            final minAge = int.tryParse(minAgeInput) ?? 0;
            
            stdout.write('Enter maximum age: ');
            final maxAgeInput = stdin.readLineSync() ?? '200';
            final maxAge = int.tryParse(maxAgeInput) ?? 200;
            
            query = where.gte('age', minAge).lte('age', maxAge);
            break;
            
          default:
            print('\nInvalid option');
            continue;
        }
        
        final results = await mongoService.findDocuments(
          collectionName,
          selector: query
        );
        
        if (results.isEmpty) {
          print('\nNo matching users found');
        } else {
          print('\nMatching users:');
          for (int i = 0; i < results.length; i++) {
            final user = results[i];
            print('${i + 1}. ${user['name']} - ${user['email']} (Age: ${user['age']})');
          }
        }
        break;
        
      case '7':
        // Exit
        print('\nExiting program...');
        return;
        
      default:
        print('\nInvalid choice. Please try again.');
    }
  }
} 