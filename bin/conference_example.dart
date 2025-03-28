import 'dart:io';
import '../lib/conference_db_setup.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Example script demonstrating the conference database functionality
void main() async {
  print('=== Conference Database Example ===');
  print('Connecting to MongoDB Atlas...');
  
  final dbSetup = ConferenceDbSetup.afranDb();
  
  try {
    // Initialize or reset the database
    print('\nDo you want to reset the database? (This will delete all existing data) [y/N]:');
    final resetInput = stdin.readLineSync()?.toLowerCase() ?? '';
    
    if (resetInput == 'y') {
      await dbSetup.resetDatabase();
      print('Database reset complete.');
    } else {
      await dbSetup.initializeDatabase();
    }
    
    // Option to create sample data
    print('\nDo you want to create sample data? [y/N]:');
    final sampleInput = stdin.readLineSync()?.toLowerCase() ?? '';
    
    if (sampleInput == 'y') {
      await dbSetup.createSampleData();
    }
    
    await demonstrateConferenceOperations(dbSetup);
    
  } catch (e) {
    print('Error: $e');
  } finally {
    await dbSetup.close();
    print('\nDatabase connection closed');
  }
}

/// Demonstrate conference data operations
Future<void> demonstrateConferenceOperations(ConferenceDbSetup dbSetup) async {
  while (true) {
    print('\n=== Conference Database Operations ===');
    print('1. List all collections');
    print('2. View speakers');
    print('3. View rooms');
    print('4. View sessions with subsessions');
    print('5. View sponsors');
    print('6. View messages');
    print('7. Add a new speaker');
    print('8. Add a new session');
    print('9. Exit');
    
    stdout.write('\nEnter your choice (1-9): ');
    final choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        await listCollections(dbSetup);
        break;
        
      case '2':
        await viewSpeakers(dbSetup);
        break;
        
      case '3':
        await viewRooms(dbSetup);
        break;
        
      case '4':
        await viewSessionsWithSubsessions(dbSetup);
        break;
        
      case '5':
        await viewSponsors(dbSetup);
        break;
        
      case '6':
        await viewMessages(dbSetup);
        break;
        
      case '7':
        await addNewSpeaker(dbSetup);
        break;
        
      case '8':
        await addNewSession(dbSetup);
        break;
        
      case '9':
        print('\nExiting program...');
        return;
        
      default:
        print('\nInvalid choice. Please try again.');
    }
  }
}

/// List all collections in the database
Future<void> listCollections(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final collections = await db.getCollectionNames();
  
  print('\nCollections in the database:');
  for (var collection in collections) {
    print(' - $collection');
  }
}

/// View all speakers
Future<void> viewSpeakers(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final speakers = await db.findDocuments('speakers');
  
  if (speakers.isEmpty) {
    print('\nNo speakers found');
  } else {
    print('\nSpeakers:');
    for (var speaker in speakers) {
      print(' - ${speaker['full_name']} (${speaker['country_code'] ?? 'N/A'})');
      if (speaker['bio'] != null) {
        print('   Bio: ${speaker['bio']}');
      }
    }
  }
}

/// View all rooms
Future<void> viewRooms(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final rooms = await db.findDocuments('rooms');
  
  if (rooms.isEmpty) {
    print('\nNo rooms found');
  } else {
    print('\nRooms:');
    for (var room in rooms) {
      print(' - ${room['name']} (Capacity: ${room['capacity'] ?? 'N/A'})');
      if (room['location'] != null) {
        print('   Location: ${room['location']}');
      }
    }
  }
}

/// View sessions with their subsessions
Future<void> viewSessionsWithSubsessions(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final sessions = await db.findDocuments('sessions');
  
  if (sessions.isEmpty) {
    print('\nNo sessions found');
    return;
  }
  
  print('\nSessions and subsessions:');
  for (var session in sessions) {
    final roomId = session['room_id'];
    String roomName = 'N/A';
    
    if (roomId != null) {
      final roomQuery = where.eq('_id', roomId);
      final rooms = await db.findDocuments('rooms', selector: roomQuery);
      if (rooms.isNotEmpty) {
        roomName = rooms.first['name'];
      }
    }
    
    // Format date/time
    final startTime = session['start_time'] as DateTime;
    final endTime = session['end_time'] as DateTime;
    final formattedStart = '${startTime.day}/${startTime.month}/${startTime.year} ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final formattedEnd = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    
    print('\n=== SESSION: ${session['title']} ===');
    print('   Time: $formattedStart - $formattedEnd');
    print('   Room: $roomName');
    if (session['description'] != null) {
      print('   Description: ${session['description']}');
    }
    
    // Get subsessions for this session
    final subsessionQuery = where.eq('session_id', session['_id']);
    final subsessions = await db.findDocuments('subsessions', selector: subsessionQuery);
    
    if (subsessions.isNotEmpty) {
      print('\n   Subsessions:');
      for (var subsession in subsessions) {
        final speakerId = subsession['speaker_id'];
        String speakerName = 'N/A';
        
        if (speakerId != null) {
          final speakerQuery = where.eq('_id', speakerId);
          final speakers = await db.findDocuments('speakers', selector: speakerQuery);
          if (speakers.isNotEmpty) {
            speakerName = speakers.first['full_name'];
          }
        }
        
        // Format subsession time
        final subStartTime = subsession['start_time'] as DateTime;
        final subEndTime = subsession['end_time'] as DateTime;
        final formattedSubStart = '${subStartTime.hour}:${subStartTime.minute.toString().padLeft(2, '0')}';
        final formattedSubEnd = '${subEndTime.hour}:${subEndTime.minute.toString().padLeft(2, '0')}';
        
        print('   -- ${subsession['title']} ($formattedSubStart - $formattedSubEnd)');
        print('      Speaker: $speakerName');
        if (subsession['description'] != null) {
          print('      Description: ${subsession['description']}');
        }
        
        // Get subsubsessions for this subsession
        final subsubsessionQuery = where.eq('subsession_id', subsession['_id']);
        final subsubsessions = await db.findDocuments('subsubsessions', selector: subsubsessionQuery);
        
        if (subsubsessions.isNotEmpty) {
          print('\n      Sub-subsessions:');
          for (var subsubsession in subsubsessions) {
            final subSpeakerId = subsubsession['speaker_id'];
            String subSpeakerName = 'N/A';
            
            if (subSpeakerId != null) {
              final subSpeakerQuery = where.eq('_id', subSpeakerId);
              final subSpeakers = await db.findDocuments('speakers', selector: subSpeakerQuery);
              if (subSpeakers.isNotEmpty) {
                subSpeakerName = subSpeakers.first['full_name'];
              }
            }
            
            // Format subsubsession time
            final subSubStartTime = subsubsession['start_time'] as DateTime;
            final subSubEndTime = subsubsession['end_time'] as DateTime;
            final formattedSubSubStart = '${subSubStartTime.hour}:${subSubStartTime.minute.toString().padLeft(2, '0')}';
            final formattedSubSubEnd = '${subSubEndTime.hour}:${subSubEndTime.minute.toString().padLeft(2, '0')}';
            
            print('      ---- ${subsubsession['title']} ($formattedSubSubStart - $formattedSubSubEnd)');
            print('          Speaker: $subSpeakerName');
            if (subsubsession['description'] != null) {
              print('          Description: ${subsubsession['description']}');
            }
          }
        }
      }
    } else {
      print('   No subsessions found for this session');
    }
  }
}

/// View all sponsors
Future<void> viewSponsors(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final sponsors = await db.findDocuments('sponsors');
  
  if (sponsors.isEmpty) {
    print('\nNo sponsors found');
  } else {
    print('\nSponsors:');
    for (var sponsor in sponsors) {
      print(' - ${sponsor['name']}');
      if (sponsor['website_url'] != null) {
        print('   Website: ${sponsor['website_url']}');
      }
    }
  }
}

/// View all messages
Future<void> viewMessages(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  final messages = await db.findDocuments('messages');
  
  if (messages.isEmpty) {
    print('\nNo messages found');
  } else {
    print('\nMessages:');
    for (var message in messages) {
      print('\n=== ${message['title']} ===');
      if (message['content'] != null) {
        print(message['content']);
      }
    }
  }
}

/// Add a new speaker
Future<void> addNewSpeaker(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  
  stdout.write('\nEnter speaker name: ');
  final name = stdin.readLineSync() ?? '';
  if (name.isEmpty) {
    print('Speaker name cannot be empty');
    return;
  }
  
  stdout.write('Enter speaker bio (optional): ');
  final bio = stdin.readLineSync();
  
  stdout.write('Enter country code (e.g., US, FR): ');
  final countryCode = stdin.readLineSync();
  
  stdout.write('Enter image URL (optional): ');
  final imageUrl = stdin.readLineSync();
  
  final speaker = {
    'full_name': name,
    'created_at': DateTime.now(),
  };
  
  if (bio?.isNotEmpty == true) speaker['bio'] = bio;
  if (countryCode?.isNotEmpty == true) speaker['country_code'] = countryCode;
  if (imageUrl?.isNotEmpty == true) speaker['image_url'] = imageUrl;
  
  final id = await db.insertDocument('speakers', speaker);
  print('\nSpeaker added successfully with ID: $id');
}

/// Add a new session
Future<void> addNewSession(ConferenceDbSetup dbSetup) async {
  final db = dbSetup._dbService;
  
  // First, show available rooms
  final rooms = await db.findDocuments('rooms');
  if (rooms.isEmpty) {
    print('\nNo rooms available. Please add a room first.');
    return;
  }
  
  print('\nAvailable rooms:');
  for (var i = 0; i < rooms.length; i++) {
    print('${i + 1}. ${rooms[i]['name']} (${rooms[i]['location'] ?? 'No location'})');
  }
  
  stdout.write('\nSelect room number: ');
  final roomNumInput = stdin.readLineSync() ?? '';
  final roomNum = int.tryParse(roomNumInput);
  if (roomNum == null || roomNum < 1 || roomNum > rooms.length) {
    print('Invalid room selection');
    return;
  }
  
  final selectedRoom = rooms[roomNum - 1];
  
  stdout.write('\nEnter session title: ');
  final title = stdin.readLineSync() ?? '';
  if (title.isEmpty) {
    print('Session title cannot be empty');
    return;
  }
  
  stdout.write('Enter session description (optional): ');
  final description = stdin.readLineSync();
  
  // Date input
  stdout.write('Enter session date (DD/MM/YYYY): ');
  final dateInput = stdin.readLineSync() ?? '';
  final dateParts = dateInput.split('/');
  if (dateParts.length != 3) {
    print('Invalid date format. Use DD/MM/YYYY');
    return;
  }
  
  // Start time
  stdout.write('Enter start time (HH:MM): ');
  final startTimeInput = stdin.readLineSync() ?? '';
  final startTimeParts = startTimeInput.split(':');
  if (startTimeParts.length != 2) {
    print('Invalid time format. Use HH:MM');
    return;
  }
  
  // End time
  stdout.write('Enter end time (HH:MM): ');
  final endTimeInput = stdin.readLineSync() ?? '';
  final endTimeParts = endTimeInput.split(':');
  if (endTimeParts.length != 2) {
    print('Invalid time format. Use HH:MM');
    return;
  }
  
  try {
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1]);
    
    final startTime = DateTime(year, month, day, startHour, startMinute);
    final endTime = DateTime(year, month, day, endHour, endMinute);
    
    if (endTime.isBefore(startTime)) {
      print('End time cannot be before start time');
      return;
    }
    
    final session = {
      'title': title,
      'room_id': selectedRoom['_id'],
      'start_time': startTime,
      'end_time': endTime,
      'created_at': DateTime.now(),
    };
    
    if (description?.isNotEmpty == true) {
      session['description'] = description;
    }
    
    final id = await db.insertDocument('sessions', session);
    print('\nSession added successfully with ID: $id');
    
  } catch (e) {
    print('Error creating session: $e');
  }
} 