import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'lunch_symposium_details_screen.dart';
import '../config.dart';

class ProgramScreen extends StatefulWidget {
  final String? initialSessionId;
  
  const ProgramScreen({super.key, this.initialSessionId});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  List<dynamic> days = [];
  List<dynamic> sessions = [];
  List<dynamic> rooms = [];
  List<dynamic> filteredSessions = [];
  dynamic selectedDay;
  String? selectedRoom;
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isLoading = true;
  bool isShowingBreak = false;
  Set<String> _pinnedSessions = {};
  final String _pinnedSessionsKey = 'pinned_sessions';
  String? _error;
  bool queryIncludedRoomFilter = false;
  final String apiUrl = Config.defaultApiUrl;

  @override
  void initState() {
    super.initState();
    _loadPinnedSessions();
    fetchDays();
  }

  Future<void> _loadPinnedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinnedSessions = Set<String>.from(prefs.getStringList(_pinnedSessionsKey) ?? []);
    });
  }

  Future<void> _togglePinSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_pinnedSessions.contains(sessionId)) {
        _pinnedSessions.remove(sessionId);
      } else {
        _pinnedSessions.add(sessionId);
      }
    });
    await prefs.setStringList(_pinnedSessionsKey, _pinnedSessions.toList());
  }

  Future<void> fetchDays() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await http.get(Uri.parse('$apiUrl/days'));
      print('Fetching days from: $apiUrl/days');
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final fetchedDays = json.decode(response.body);
        print('Fetched ${fetchedDays.length} days');
        
        setState(() {
          days = fetchedDays;
          // Automatically select first day
          if (days.isNotEmpty) {
            selectedDay = days[0];
            // Fetch sessions for the first day
            fetchSessionsByDay(days[0]['_id']);
          } else {
            print('WARNING: No days returned from API');
            isLoading = false;
          }
        });
      } else {
        print('Failed to load days: ${response.statusCode}');
        setState(() {
          isLoading = false;
          _error = 'Failed to load days: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error fetching days: $e');
      setState(() {
        isLoading = false;
        _error = 'Error fetching days: $e';
      });
    }
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/rooms'));
      if (response.statusCode == 200) {
        final fetchedRooms = json.decode(response.body);
        
        // Vérifiez que nous avons bien récupéré les trois salles attendues
        print("Fetched ${fetchedRooms.length} rooms from API");
        
        setState(() {
          rooms = fetchedRooms;
        });
      } else {
        print("Failed to fetch rooms: ${response.statusCode}");
        setState(() {
          _error = "Failed to fetch rooms: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Error fetching rooms: $e");
      setState(() {
        _error = "Error fetching rooms: $e";
      });
    }
  }

  // Assign room IDs to sessions to ensure filtering works properly
  void assignRoomIdsToSessions() {
    print("Starting room ID assignment for ${sessions.length} sessions");
    int assignedCount = 0;
    int alreadyAssignedCount = 0;
    int forceAssignedCount = 0;
    
    // Iterate through all sessions and add roomId property if missing
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final sessionId = session['_id'] ?? '';
      final sessionTitle = session['title'] ?? 'Unknown Session';
      
      if (sessionTitle.contains("AFRAN - ISN Workshop")) {
        // Trouver l'ID de la salle Pr. Hassouna BEN AYED Conference Hall
        String benAyedRoomId = '';
        for (var room in rooms) {
          if (room['name'] == 'Pr. Hassouna BEN AYED Conference Hall') {
            benAyedRoomId = room['_id'];
            break;
          }
        }
        
        if (benAyedRoomId.isNotEmpty) {
          final updatedSession = Map<String, dynamic>.from(session);
          updatedSession['roomId'] = benAyedRoomId;
          sessions[i] = updatedSession;
          print("FORCE assigned roomId $benAyedRoomId to session '$sessionTitle'");
          forceAssignedCount++;
          continue;
        }
      }
      
      // Skip if roomId is already set
      String existingRoomId = extractRoomId(session);
      if (existingRoomId.isNotEmpty) {
        alreadyAssignedCount++;
        continue;
      }
      
      // Get the room name for this session
      final roomName = getRoomNameForSession(session);
      
      // Find the corresponding room ID
      String roomId = '';
      for (var room in rooms) {
        if (room['name'] == roomName) {
          roomId = room['_id'];
          break;
        }
      }
      
      // Add the roomId to the session
      if (roomId.isNotEmpty) {
        // Create a new map to avoid modifying the original session
        final updatedSession = Map<String, dynamic>.from(session);
        updatedSession['roomId'] = roomId;
        sessions[i] = updatedSession;
        print("Assigned roomId $roomId to session '$sessionTitle'");
        assignedCount++;
      } else {
        print("Failed to assign roomId for session '$sessionTitle' with room name: $roomName");
      }
    }
    
    print("Finished room ID assignment: $assignedCount new assignments, $alreadyAssignedCount already assigned, $forceAssignedCount force assigned");
  }

  Future<void> fetchSessionsByDay(String dayId) async {
    setState(() {
      isLoading = true;
      queryIncludedRoomFilter = false; // Reset this flag
    });

    try {
      // Fetch rooms first to ensure they're available for filtering
      await fetchRooms();
      
      List<dynamic> fetchedSessions = [];
      
      // Fetch lunch symposia first
      final lunchSymposiaResponse = await http.get(Uri.parse('$apiUrl/api/lunch-symposia'));
      if (lunchSymposiaResponse.statusCode == 200) {
        final List<dynamic> lunchSymposia = json.decode(lunchSymposiaResponse.body);
        print('Found ${lunchSymposia.length} total lunch symposia');
        
        // Filter lunch symposia by day
        if (dayId.isNotEmpty) {
          final filteredLunchSymposia = lunchSymposia.where((symposium) {
            final symposiumDayId = symposium['dayId']?['_id']?.toString() ?? '';
            print('Comparing symposium dayId: $symposiumDayId with selected dayId: $dayId');
            return symposiumDayId == dayId;
          }).toList();
          
          print('Filtered to ${filteredLunchSymposia.length} lunch symposia for day $dayId');
          
          // Add filtered lunch symposia to sessions list with special styling
          fetchedSessions.addAll(filteredLunchSymposia.map((symposium) {
            // Ensure the time is properly formatted
            final timeString = symposium['time']?.toString() ?? '';
            final List<String> timeParts = timeString.split('-');
            String formattedTime = '';
            
            if (timeParts.length == 2) {
              try {
                final startTime = _convertDecimalToTime(double.parse(timeParts[0]));
                final endTime = _convertDecimalToTime(double.parse(timeParts[1]));
                formattedTime = '$startTime - $endTime';
              } catch (e) {
                print('Error formatting time: $e');
                formattedTime = timeString;
              }
            }
            
            return {
              ...symposium,
              'type': 'Lunch Symposium',
              'isLunchSymposium': true,
              'time': formattedTime,
              'startTime': timeParts[0],
              'endTime': timeParts[1],
              'style': getLunchSymposiumStyle(),
            };
          }).toList());
          
          print('Added lunch symposia to sessions list. Total sessions now: ${fetchedSessions.length}');
        }
      }
      
      // Then fetch regular sessions
      String queryParams = '';
      if (dayId.isNotEmpty) {
        queryParams = '?dayId=$dayId';
      }

      final url = Uri.parse('$apiUrl/sessions$queryParams');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final regularSessions = json.decode(response.body);
        fetchedSessions.addAll(regularSessions);
      }
        
      setState(() {
        sessions = fetchedSessions;
        assignRoomIdsToSessions();
        applyFilters(); // This will handle room filtering client-side
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching sessions: $e');
      setState(() {
        sessions = [];
        filteredSessions = [];
        isLoading = false;
        _error = 'Error fetching sessions: $e';
      });
    }
  }

  // Helper method to convert decimal time to formatted string
  String _convertDecimalToTime(double decimal) {
    final hours = decimal * 24;
    final hoursInt = hours.floor();
    final minutes = ((hours - hoursInt) * 60).round();
    return '${hoursInt.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Update the isLunchSymposium check
  bool isLunchSymposium(dynamic session) {
    return session['isLunchSymposium'] == true || 
           session['type'] == 'Lunch Symposium' ||
           (session['title'] != null && 
            (session['title'].toString().toLowerCase().contains('lunch symposium') ||
             session['title'].toString().toLowerCase().contains('lunch symposia')));
  }
  
  // Helper pour extraire l'ID de la salle à partir d'une session
  String extractRoomId(dynamic session) {
    // Vérifier si la session a une propriété roomId
    if (session['roomId'] != null) {
      // Si roomId est un objet (référence MongoDB populée)
      if (session['roomId'] is Map && session['roomId']['_id'] != null) {
        return session['roomId']['_id'];
      } 
      // Si roomId est directement un String
      else if (session['roomId'] is String) {
        return session['roomId'];
      }
    }
    
    // Si la room est un objet qui contient un _id
    if (session['room'] != null && session['room'] is Map && session['room']['_id'] != null) {
      return session['room']['_id'];
    }
    
    return '';
  }

  // Nouvel helper pour extraire l'ID du jour d'une session
  String extractDayId(dynamic session) {
    // Vérifier si la session a une propriété dayId
    if (session['dayId'] != null) {
      // Si dayId est un objet (référence MongoDB populée)
      if (session['dayId'] is Map && session['dayId']['_id'] != null) {
        return session['dayId']['_id'];
      } 
      // Si dayId est directement un String
      else if (session['dayId'] is String) {
        return session['dayId'];
      }
    }
    
    return '';
  }

  // Navigate to session details
  void _navigateToSessionDetails(dynamic session) {
    // Check if this is a lunch symposium
    final bool isLunchSymposium = session['type'] == 'Lunch Symposium' || 
                                (session['title'] != null && 
                                 (session['title'].toString().toLowerCase().contains('lunch symposium') ||
                                  session['title'].toString().toLowerCase().contains('lunch symposia')));
    
    if (isLunchSymposium) {
      // Use the dedicated lunch symposium details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LunchSymposiumDetailsScreen(lunchSymposium: session),
        ),
      );
    } else {
      // Use the regular session details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionDetailsScreen(
            sessionId: session['_id'],
          ),
        ),
      );
    }
  }

  void applyFilters() {
    List<dynamic> tempSessions = [];
    
    try {
      // Start with all sessions
      tempSessions = List.from(sessions);
      print('Initial sessions count before any filtering: ${tempSessions.length}');
      
      if (tempSessions.isEmpty) {
        print('WARNING: No sessions available to filter - check API response and session loading');
        setState(() {
          filteredSessions = [];
        });
        return;
      }
      
      // First filter by day if a day is selected
      if (selectedDay != null) {
        String selectedDayId = selectedDay['_id'];
        print("Applying day filter for day ID: $selectedDayId");
        
        tempSessions = tempSessions.where((session) {
          String sessionDayId = extractDayId(session);
          
          if (sessionDayId.isEmpty) {
            return false;
          }
          
          // For lunch symposia, ensure we're comparing the correct dayId structure
          if (session['isLunchSymposium'] == true) {
            final symposiumDayId = session['dayId']?['_id']?.toString() ?? '';
            return symposiumDayId == selectedDayId;
          }
          
          return sessionDayId == selectedDayId;
        }).toList();
        
        print("After day filtering: ${tempSessions.length} sessions remaining");
      }
      
      // Then filter by room if a room is selected
      if (selectedRoom != null) {
        print("Applying room filter for room ID: $selectedRoom");
        
        tempSessions = tempSessions.where((session) {
          String sessionRoomId = extractRoomId(session);
          
          // If session has no room ID, try to get it from the room name
          if (sessionRoomId.isEmpty) {
            String roomName = getRoomNameForSession(session);
            for (var room in rooms) {
              if (room['name'] == roomName && room['_id'] == selectedRoom) {
                return true;
              }
            }
            return false;
          }
          
          return sessionRoomId == selectedRoom;
        }).toList();
        
        print("After room filtering: ${tempSessions.length} sessions remaining");
      }
      
      // Finally apply search filter (always applied client-side)
      if (searchQuery.isNotEmpty) {
        tempSessions = tempSessions.where((session) {
          String title = session['title'] ?? '';
          String description = session['description'] ?? '';
          
          return title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        
        print("After search filtering: ${tempSessions.length} sessions remaining");
      }
      
      // Sort sessions by start time and room name
      tempSessions.sort((a, b) {
        var timeA = a['startTime'];
        var timeB = b['startTime'];
        
        if (timeA != null && timeA is! String) timeA = timeA.toString();
        if (timeB != null && timeB is! String) timeB = timeB.toString();
        
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        
        int timeComparison = timeA.compareTo(timeB);
        
        if (timeComparison == 0) {
          final roomNameA = getRoomNameForSession(a);
          final roomNameB = getRoomNameForSession(b);
          return roomNameA.compareTo(roomNameB);
        }
        
        return timeComparison;
      });
      
      print("FINAL FILTERING RESULT: ${tempSessions.length} sessions after all filters");
      
    } catch (e) {
      print("ERROR IN APPLY FILTERS: $e");
      tempSessions = List.from(sessions);
    }
    
    setState(() {
      filteredSessions = tempSessions;
    });
  }

  String getRoomNameForSession(dynamic session) {
    final sessionId = session['_id'];
    final sessionTitle = session['title'] ?? '';
    
    try {
      print("Getting room name for session: $sessionTitle (ID: $sessionId)");
      
      // Special fix for specific sessions
      if (sessionId == '67e435574740c1f09021b0e4' || 
          sessionId == '67e435554740c1f09021b0b7') {
        print("Session $sessionTitle: Special fix to BEN AYED Conference Hall");
        // Force set the roomId for these sessions
        if (session['roomId'] == null) {
          session['roomId'] = '67e0abdbd899f8432337ca6c'; // ID for Pr. Hassouna BEN AYED Conference Hall
        }
        return 'Pr. Hassouna BEN AYED Conference Hall';
      }
      
      // Check for direct room field first
      if (session['room'] != null && session['room'].toString().isNotEmpty) {
        final roomName = session['room'].toString();
        print("Session $sessionTitle: Used direct room string: $roomName");
        return roomName;
      }
      
      // Check for roomId
      if (session['roomId'] != null) {
        if (session['roomId'] is Map && session['roomId']['name'] != null) {
          final roomName = session['roomId']['name'];
          print("Session $sessionTitle: Found direct roomId.name: $roomName");
          return roomName;
        }
        
        String roomIdStr = '';
        if (session['roomId'] is Map && session['roomId']['_id'] != null) {
          roomIdStr = session['roomId']['_id'];
        } else if (session['roomId'] is String) {
          roomIdStr = session['roomId'];
        }
        
        if (roomIdStr.isNotEmpty) {
          final Map<String, String> roomIdToNameMap = {
            '67e0abdbd899f8432337ca6c': 'Pr. Hassouna BEN AYED Conference Hall',
            '67e0abdad899f8432337ca5f': 'Pr. Adel KHEDHER Conference Room',
            '67e0adead88f9dbce65b5e7b': 'Pr. Abdelhamid JARRAYA Conference Room',
          };
          
          if (roomIdToNameMap.containsKey(roomIdStr)) {
            final roomName = roomIdToNameMap[roomIdStr]!;
            print("Session $sessionTitle: Mapped roomId $roomIdStr to room: $roomName");
            return roomName;
          }
        }
      }
      
      // Check for roomName
      if (session['roomName'] != null && session['roomName'].toString().isNotEmpty) {
        final roomName = session['roomName'].toString();
        print("Session $sessionTitle: Used roomName property: $roomName");
        return roomName;
      }
      
      // Default to Hassouna BEN AYED Conference Hall
      print("Session $sessionTitle: Using default room (no matching criteria)");
      return 'Pr. Hassouna BEN AYED Conference Hall';
    } catch (e) {
      print("Session $sessionTitle: Error getting room name: $e, using default");
      return 'Pr. Hassouna BEN AYED Conference Hall';
    }
  }

  String getDayNumberForSession(dynamic session) {
    // If the session has a dayId that's populated as an object
    if (session['dayId'] != null) {
      if (session['dayId'] is Map) {
        if (session['dayId']['name'] != null) {
          return session['dayId']['name'];
        } else if (session['dayId']['number'] != null) {
          return 'Day ${session['dayId']['number']}';
        } else if (session['dayId']['_id'] != null) {
          // Try to find day in days list by ID
          final dayId = session['dayId']['_id'];
          for (var day in days) {
            if (day['_id'] == dayId) {
              return day['name'] ?? 'Day ${day['number'] ?? ''}';
            }
          }
        }
      } else if (session['dayId'] is String) {
        // Try to find day in the days list by ID
        final dayId = session['dayId'];
        for (var day in days) {
          if (day['_id'] == dayId) {
            return day['name'] ?? 'Day ${day['number'] ?? ''}';
          }
        }
      }
    }
    
    // If the session has a day property as a direct number
    if (session['day'] != null) {
      return 'Day ${session['day']}';
    }
    
    // Default fallback
    return '';
  }

  Widget _buildSpeakerItem(dynamic speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Speaker image
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: speaker['speakerImageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(speaker['speakerImageUrl']),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
            : null,
            ),
            child: speaker['speakerImageUrl'] == null
                ? Icon(Icons.person, color: Colors.grey.shade400)
            : null,
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker['name'] ?? 'Unknown Speaker',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (speaker['country'] != null) 
                  Row(
                    children: [
                      if (speaker['flagUrl'] != null)
                        Container(
                          width: 16,
                          height: 12,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(speaker['flagUrl']),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                            border: Border.all(color: Colors.grey.shade300, width: 0.5),
                          ),
                        ),
                      Text(
                        speaker['country'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsessionItem(dynamic subsession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Time
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: const Color(0xFF4b9188),
              ),
              const SizedBox(width: 4),
            Text(
                '${_formatTimeValue(subsession['startTime'] ?? '')} - ${_formatTimeValue(subsession['endTime'] ?? '')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4b9188),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Title
          Text(
            subsession['title'] ?? 'Untitled Subsession',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          
          // Speakers if available
          if (subsession['speakers'] != null && subsession['speakers'] is List && subsession['speakers'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Speakers:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                ...subsession['speakers'].map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
              ],
            ),
        ],
      ),
    );
  }

  // Define a method to get special session style based on title
  Map<String, dynamic> getSpecialSessionStyle(String title) {
    // Normalize title for case-insensitive comparison
    final normalizedTitle = title.trim().toLowerCase();
    
    // Special style for registration sessions
    if (normalizedTitle.contains('registration') || normalizedTitle.contains('check-in')) {
      return {
        'color': const Color(0xFF2196F3),
        'icon': Icons.how_to_reg,
        'gradient': LinearGradient(
          colors: [const Color(0xFFBBDEFB), const Color(0xFF2196F3).withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    }
    
    // Special styles for different session types
    if (normalizedTitle.contains('exhibition') || normalizedTitle.contains('poster session')) {
      return {
        'color': const Color(0xFF6B8E23),
        'icon': Icons.museum,
        'gradient': LinearGradient(
          colors: [const Color(0xFFD5E8B7), const Color(0xFF6B8E23).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else if (normalizedTitle.contains('opening ceremony')) {
      return {
        'color': const Color(0xFF1976D2),
        'icon': Icons.celebration,
        'gradient': LinearGradient(
          colors: [const Color(0xFFBBDEFB), const Color(0xFF1976D2).withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else if (normalizedTitle.contains('closing ceremony') || normalizedTitle.contains('awards')) {
      return {
        'color': const Color(0xFF673AB7),
        'icon': Icons.emoji_events,
        'gradient': LinearGradient(
          colors: [const Color(0xFFD1C4E9), const Color(0xFF673AB7).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      };
    } else if (normalizedTitle.contains('coffee break')) {
      return getCoffeeBreakStyle();
    }
    
    // Return empty map if not a special session
    return {};
  }

  // Add a new method specifically for coffee break styling
  Map<String, dynamic> getCoffeeBreakStyle() {
    return {
      'color': const Color(0xFFE6A817),
      'icon': Icons.coffee,
      'gradient': LinearGradient(
        colors: [const Color(0xFFF9E2B0), const Color(0xFFE6A817).withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  // Add a new method specifically for lunch symposium styling
  Map<String, dynamic> getLunchSymposiumStyle() {
    return {
      'backgroundColor': const Color(0xFFFCE4EC), // Light pink background
      'borderColor': const Color(0xFFE91E63), // Pink border
      'textColor': const Color(0xFFC2185B), // Dark pink text
      'iconColor': const Color(0xFFE91E63), // Pink icon
      'gradient': LinearGradient(
        colors: [
          const Color(0xFFFCE4EC),
          const Color(0xFFF8BBD0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  // Check if a session is one of the highlighted sessions by ID
  bool isHighlightedSession(dynamic session) {
    final String sessionId = session['_id'] ?? '';
    final List<String> highlightedIds = [
      '67dbf637cb578444db5b070e',
      '67dbf642cb578444db5b070f',
      '67dc0508c4a831287a336da3',
    ];
    return highlightedIds.contains(sessionId);
  }

  Widget _buildSessionCard(dynamic session) {
    final roomName = getRoomNameForSession(session);
    final dayNumber = getDayNumberForSession(session);
    final String sessionId = session['_id']?.toString() ?? '';
    final String sessionTitle = session['title'] ?? '';
    
    // Check if this is a lunch symposium
    final bool isLunchSymp = session['isLunchSymposium'] == true || 
                            session['type'] == 'Lunch Symposium' ||
                            (session['title'] != null && 
                             (session['title'].toString().toLowerCase().contains('lunch symposium') ||
                              session['title'].toString().toLowerCase().contains('lunch symposia')));
    
    // Check if this is a registration session
    final bool isRegistration = sessionTitle.toLowerCase().contains('registration') || 
                              sessionTitle.toLowerCase().contains('check-in');
    
    // Get special styling if this is a special session
    final Map<String, dynamic> specialStyle = isRegistration 
        ? getSpecialSessionStyle(sessionTitle)
        : (isLunchSymp 
            ? getLunchSymposiumStyle()
            : getSpecialSessionStyle(sessionTitle));
    final bool isSpecialSession = specialStyle.isNotEmpty;
    
    // Check if this is a coffee break
    final bool isCoffeeBreakSession = isCoffeeBreak(session);
    
    // Check if session has subsessions and filter them
    List<dynamic> validSubsessions = [];
    final hasSubsessions = session['subsessions'] != null && 
                          session['subsessions'] is List && 
                          session['subsessions'].isNotEmpty;
    
    // Filter subsessions to only include those that belong to this session
    if (hasSubsessions) {
      validSubsessions = (session['subsessions'] as List).where((subsession) {
        // If subsession has no sessionId field, we can't validate it
        if (subsession['sessionId'] == null) return false;
        
        // Check if subsession sessionId matches current session
        if (subsession['sessionId'] is String) {
          return subsession['sessionId'] == sessionId;
        } else if (subsession['sessionId'] is Map && subsession['sessionId']['_id'] != null) {
          return subsession['sessionId']['_id'] == sessionId;
        }
        
        return false; // Exclude if we can't determine
      }).toList();
    }
    
    final hasValidSubsessions = validSubsessions.isNotEmpty;
    
    // Check if session has speakers
    final hasSpeakers = session['speakers'] != null && 
                       session['speakers'] is List && 
                       session['speakers'].isNotEmpty;
    
    // Format time properly
    String sessionTime = '';
    if (session['startTime'] != null && session['endTime'] != null) {
      final startTime = _formatTimeValue(session['startTime']);
      final endTime = _formatTimeValue(session['endTime']);
      sessionTime = '$startTime - $endTime';
    } else if (session['time'] != null) {
      sessionTime = session['time'].toString();
    }

    final isPinned = _pinnedSessions.contains(sessionId);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSpecialSession ? null : Colors.white,
        gradient: isSpecialSession ? specialStyle['gradient'] : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLunchSymp ? const Color(0xFFE91E63) : Colors.grey.shade300,
          width: isLunchSymp ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _navigateToSessionDetails(session),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (sessionTime.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLunchSymp 
                                ? const Color(0xFFE91E63).withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sessionTime,
                            style: TextStyle(
                              color: isLunchSymp ? const Color(0xFFE91E63) : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (isLunchSymp)
                        const Icon(
                          Icons.restaurant,
                          color: Color(0xFFE91E63),
                          size: 24,
                        ),
                      if (isRegistration)
                        Icon(
                          Icons.how_to_reg,
                          color: const Color(0xFF2196F3),
                          size: 24,
                        ),
                      if (!isSpecialSession && !isLunchSymp && !isRegistration)
                        IconButton(
                          icon: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: isPinned ? const Color(0xFF4b9188) : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _togglePinSession(sessionId),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: isPinned ? 'Retirer des favoris' : 'Ajouter aux favoris',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sessionTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isRegistration ? const Color(0xFF2196F3) : 
                             (isLunchSymp ? const Color(0xFFC2185B) : null),
                    ),
                  ),
                  if (session['description'] != null && session['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      session['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLunchSymp ? const Color(0xFFC2185B) : Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.room,
                        size: 16,
                        color: isLunchSymp ? const Color(0xFFE91E63) : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          roomName,
                          style: TextStyle(
                            color: isLunchSymp ? const Color(0xFFE91E63) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLunchSymp && session['chairpersons'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: const Color(0xFFE91E63),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chair: ${session['chairpersons']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLunchSymp 
                          ? const Color(0xFFE91E63).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLunchSymp ? 'Lunch Symposium' : (session['type'] ?? 'Session'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isLunchSymp ? const Color(0xFFE91E63) : Colors.grey.shade700,
                        fontWeight: isLunchSymp ? FontWeight.w500 : null,
                      ),
                    ),
                  ),
                  if (isLunchSymp && hasSpeakers) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1BEE7).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: Color(0xFF9C27B0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Featured Speakers',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF007F),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...session['speakers'].take(5).map<Widget>((speaker) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (speaker['speakerImageUrl'] != null || speaker['image'] != null)
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(speaker['speakerImageUrl'] ?? speaker['image']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF9C27B0).withOpacity(0.1),
                                          ),
                                          child: const Icon(Icons.person, size: 16, color: Color(0xFF9C27B0)),
                                        ),
                                      Text(
                                        speaker['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFFF007F),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (speaker['flagUrl'] != null)
                                        Container(
                                          width: 16,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(speaker['flagUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                            border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              if (session['speakers'].length > 5)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${session['speakers'].length - 5} more',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color(0xFFFF007F),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!isLunchSymp && (hasSpeakers || hasValidSubsessions)) ...[
                    const SizedBox(height: 12),
                    if (hasSpeakers) ...[
                      const Text(
                        'Speakers:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...session['speakers'].map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
                    ],
                    if (hasValidSubsessions) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const Text(
                        'Subsessions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...validSubsessions.take(3).map<Widget>((subsession) => _buildSubsessionItem(subsession)).toList(),
                      if (validSubsessions.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '+${validSubsessions.length - 3} more subsessions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _navigateToSessionDetails(session),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(hasValidSubsessions ? 'View Session Details' : 'View Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isPinned)
            Positioned(
              top: -5,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4b9188),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Épinglé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionsMessage() {
    String message;
    String submessage;
    
    if (selectedRoom != null) {
      // Si une salle est sélectionnée mais aucune session trouvée
      final roomName = rooms.firstWhere(
        (room) => room['_id'] == selectedRoom, 
        orElse: () => {'name': 'Selected Room'}
      )['name'];
      
      message = 'No sessions found in $roomName';
      submessage = 'Try selecting a different room or day';
      
    } else if (searchQuery.isNotEmpty) {
      // Si une recherche est effectuée mais aucun résultat
      message = 'No sessions match your search';
      submessage = 'Try different search terms';
      
    } else if (selectedCategory != 'All') {
      // Si une catégorie est sélectionnée mais aucune session ne correspond
      message = 'No $selectedCategory sessions found';
      submessage = 'Try selecting a different category';
      
    } else {
      // Message par défaut
      message = 'No sessions available';
      submessage = 'Check back soon for session updates';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              submessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (selectedRoom != null || searchQuery.isNotEmpty || selectedCategory != 'All')
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    // Réinitialiser tous les filtres sauf le jour sélectionné
                    selectedRoom = null;
                    searchQuery = '';
                    selectedCategory = 'All';
                    queryIncludedRoomFilter = false;
                  });
                  
                  // Récupérer toutes les sessions pour le jour sélectionné
                  if (selectedDay != null) {
                    fetchSessionsByDay(selectedDay['_id']);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to format time values, handling decimal format
  String _formatTimeValue(dynamic timeValue) {
    // If it's already a formatted time string like "09:00", return as is
    if (timeValue is String && !timeValue.toString().contains('.')) {
      return timeValue;
    }
    
    try {
      // Handle numeric or decimal string time values
      double decimalTime = double.parse(timeValue.toString());
      int hours = (decimalTime * 24).floor();
      int minutes = ((decimalTime * 24 * 60) % 60).round();
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      // If parsing fails, return the original value
      return timeValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compter le nombre de sessions dans chaque salle pour tous les jours affichés
    Map<String, int> roomSessionCounts = {};
    Map<String, String> roomIdToName = {};
    
    // Initialiser les compteurs pour toutes les salles
    for (var room in rooms) {
      String roomId = room['_id'] ?? '';
      String roomName = room['name'] ?? 'Unknown';
      roomSessionCounts[roomId] = 0;
      roomIdToName[roomId] = roomName;
    }
    
    // Compter les sessions correspondantes pour le jour sélectionné
    for (var session in sessions) {
      String sessionTitle = session['title'] ?? 'Untitled';
      String roomId = extractRoomId(session);
      String roomName = getRoomNameForSession(session);
      
      if (roomId.isNotEmpty && roomSessionCounts.containsKey(roomId)) {
        roomSessionCounts[roomId] = (roomSessionCounts[roomId] ?? 0) + 1;
        print("Counted session '$sessionTitle' for room with ID: $roomId ($roomName)");
      } else {
        // Si la session n'a pas d'ID de salle explicite, utiliser le nom de salle attribué
        for (var room in rooms) {
          if (room['name'] == roomName) {
            String roomId = room['_id'] ?? '';
            roomSessionCounts[roomId] = (roomSessionCounts[roomId] ?? 0) + 1;
            print("Counted session '$sessionTitle' for room with name: $roomName (ID: $roomId)");
            break;
          }
        }
      }
    }
    
    // Compter le nombre total de sessions pour "All Rooms"
    int totalSessionCount = sessions.length;
    
    print("========== ROOM COUNTS ==========");
    roomSessionCounts.forEach((roomId, count) {
      String roomName = roomIdToName[roomId] ?? 'Unknown';
      print("Room: $roomName (ID: $roomId) - $count sessions");
    });
    print("Total sessions: $totalSessionCount");
    print("================================");
    
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 2,
                width: 30,
                color: Theme.of(context).primaryColor,
                margin: const EdgeInsets.only(right: 12),
              ),
              Text(
                'Scientific Program',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 2,
                width: 30,
                color: Theme.of(context).primaryColor,
                margin: const EdgeInsets.only(left: 12),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 140,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? _buildErrorMessage() 
          : Column(
              children: [
                // Day tabs
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0, left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Select Day:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          child: days.isEmpty
                              ? Center(
                                  child: Text(
                                    "No days available",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  final day = days[index]; 
                                  final isSelected = selectedDay != null && selectedDay['_id'] == day['_id'];
                                  final dayName = day['name'] ?? 'Day ${index + 1}';
                                  
                                  // Format the date to show month and day
                                  String dateDisplay = '';
                                  if (day['date'] != null) {
                                    try {
                                      final date = DateTime.parse(day['date']);
                                      final dateFormat = DateFormat('MMM d');
                                      dateDisplay = dateFormat.format(date);
                                    } catch (e) {
                                      dateDisplay = day['date'].toString().substring(0, 10);
                                    }
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: InkWell(
                          onTap: () {
                                        // If already selected, do nothing
                                        if (isSelected) return;
                                        
                            setState(() {
                              selectedDay = day;
                                          // Clear the search and reset category filters when changing day
                                          searchQuery = '';
                                          selectedCategory = 'All';
                                          // Keep room filter as is - do not reset it
                            });
                                        
                                        // Always fetch from API when changing day
                            fetchSessionsByDay(day['_id']);
                                        print("Selected day: ${day['name']}, ID: ${day['_id']}, Room filter: ${selectedRoom ?? 'None'}");
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF4b9188) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : const Color(0xFF4b9188).withOpacity(0.5),
                                            width: 1,
                                          ),
                                          boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF4b9188).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                            ),
                            child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                            Flexible(
                                              child: Text(
                                                dayName,
                                  style: TextStyle(
                                                  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (dateDisplay.isNotEmpty) ...[
                                              const SizedBox(height: 3),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? Colors.white.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  dateDisplay,
                                  style: TextStyle(
                                                    color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                              ],
                            ),
                          ),
                        ),
                      );
                                },
                              ),
                        ),
                      ],
                  ),
                ),
                // Search and room filter
                  Container(
                    color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search sessions...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF4b9188)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Color(0xFF4b9188)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Color(0xFF4b9188), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                          applyFilters();
                        },
                      ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.meeting_room,
                                size: 18,
                                color: Color(0xFF4b9188),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Filter by Room:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF4b9188),
                                ),
                              ),
                            ],
                          ),
                      ),
                      const SizedBox(height: 8),
                        rooms.isEmpty 
                            ? Center(
                                child: Text(
                                  "No rooms available",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                        label: Text('All Rooms'),
                                selected: selectedRoom == null,
                                        backgroundColor: Colors.grey.shade100,
                                        selectedColor: const Color(0xFF4b9188).withOpacity(0.2),
                                        checkmarkColor: const Color(0xFF4b9188),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: selectedRoom == null ? const Color(0xFF4b9188) : Colors.grey.shade300,
                                            width: selectedRoom == null ? 1.5 : 1.0,
                                          ),
                                        ),
                                onSelected: (bool selected) {
                                          if (selected && selectedRoom != null) { // Only if not already selected
                                    setState(() {
                                      selectedRoom = null;
                                              queryIncludedRoomFilter = false;
                                              
                                              // Clear search when changing room filter
                                              searchQuery = '';
                                            });
                                            
                                            print("Selected: All Rooms");
                                            // Always refetch from backend with the current day filter only
                                            if (selectedDay != null) {
                                              fetchSessionsByDay(selectedDay['_id']);
                                            }
                                  }
                                },
                              ),
                            ),
                            ...rooms.map((room) {
                              final roomId = room['_id'] ?? '';
                              final roomName = room['name'] ?? 'Unknown';
                                      final bool isSelected = selectedRoom == roomId;
                                      
                                      // Toujours afficher toutes les salles
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(roomName),
                                          selected: isSelected,
                                          backgroundColor: Colors.grey.shade100,
                                          selectedColor: const Color(0xFF4b9188).withOpacity(0.2),
                                          checkmarkColor: const Color(0xFF4b9188),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: BorderSide(
                                              color: isSelected ? const Color(0xFF4b9188) : Colors.grey.shade300,
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                  onSelected: (bool selected) {
                                            if (selected != isSelected) {
                                    setState(() {
                                      selectedRoom = selected ? roomId : null;
                                                
                                                // Important: We will include room filter in API query
                                                // Don't apply client-side filtering when we filter at API level
                                                queryIncludedRoomFilter = selected;
                                                
                                                // Clear search when changing room filter
                                                searchQuery = '';
                                              });
                                              
                                              print("Selected Room: $roomName, ID: $roomId");
                                              // Fetch sessions with the current day and new room filter
                                    if (selectedDay != null) {
                                      fetchSessionsByDay(selectedDay['_id']);
                                              }
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                    ),
                  ),
                  // Display current filter information
                  if (!isLoading && filteredSessions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, size: 16, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing ${filteredSessions.length} sessions: ${selectedDay != null ? selectedDay['name'] ?? 'Day' : 'All days'}${selectedRoom != null ? ' • ${rooms.firstWhere((r) => r['_id'] == selectedRoom, orElse: () => {'name': 'Selected Room'})['name']}' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
                // Sessions list
                Expanded(
                    child: filteredSessions.isEmpty
                        ? _buildEmptySessionsMessage()
                        : ListView.builder(
                            itemCount: filteredSessions.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              return _buildSessionCard(filteredSessions[index]);
                            },
                  ),
                ),
                // Signature with fixed height and null safety
                const SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      "Powered by J'inspire GROUP",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              _error ?? 'Could not connect to the server',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Make sure your backend server is running at:\n$apiUrl',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  isLoading = true;
                });
                fetchDays();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to check if a session is a coffee break
  bool isCoffeeBreak(dynamic session) {
    return session['type'] == 'Coffee Break' || 
           (session['title'] != null && 
            session['title'].toString().toLowerCase().contains('coffee break'));
  }
} 