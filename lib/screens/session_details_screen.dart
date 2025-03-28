import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../widgets/video_player_widget.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';
import '../config.dart';

class SessionDetailsScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  Map<String, dynamic>? session;
  List<dynamic> subsessions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSessionDetails();
  }
  
  Future<void> fetchSessionDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      // Fetch session details
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/sessions/${widget.sessionId}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final sessionData = json.decode(response.body);
        setState(() {
          session = sessionData;
        });
        
        // Only fetch subsessions if this session should have them
        if (session != null && session!['_id'] != null) {
          // Fetch subsessions for this specific session
          final subsessionsResponse = await http.get(
            Uri.parse('${Config.defaultApiUrl}/subsessions/session/${widget.sessionId}'),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));
          
          if (subsessionsResponse.statusCode == 200) {
            final List<dynamic> fetchedSubsessions = json.decode(subsessionsResponse.body);
            
            // Validate subsessions belong to this session
            final validSubsessions = fetchedSubsessions.where((subsession) {
              final subsessionId = subsession['sessionId'];
              if (subsessionId == null) return false;
              
              if (subsessionId is Map) {
                return subsessionId['_id'] == widget.sessionId;
              } else {
                return subsessionId == widget.sessionId;
              }
            }).toList();
            
      setState(() {
              subsessions = validSubsessions;
              isLoading = false;
            });
          } else {
        setState(() {
              error = 'Failed to load subsessions';
              isLoading = false;
        });
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load session details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      // First try to launch externally (in a browser or YouTube app)
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      // If external launch fails, try universal links
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      // Still failed - show error
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Impossible d\'ouvrir: $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildSpeakerItem(dynamic speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (speaker['bio'] != null && speaker['bio'].toString().isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(speaker['name'] ?? 'Unknown Speaker'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Speaker image
                            if (speaker['speakerImageUrl'] != null)
                              Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                      image: NetworkImage(speaker['speakerImageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Country and flag
                            if (speaker['country'] != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    if (speaker['flagUrl'] != null)
          Container(
                                        width: 30,
                                        height: 20,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(speaker['flagUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                        ),
                                      ),
                                    Text(
                                      speaker['country'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // Title if available
                            if (speaker['title'] != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  speaker['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                            
                            // Biography
                            Text(
                              speaker['bio'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: speaker['speakerImageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(speaker['speakerImageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: speaker['speakerImageUrl'] == null
                ? Icon(Icons.person, color: Colors.grey.shade400)
                : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker['name'] ?? 'Unknown Speaker',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (speaker['country'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (speaker['flagUrl'] != null)
                        Container(
                          width: 20,
                          height: 15,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(speaker['flagUrl']),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: Colors.grey.shade300, width: 0.5),
                          ),
                        ),
                      Text(
                        speaker['country'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (speaker['title'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    speaker['title'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsessionItem(dynamic subsession) {
    try {
      // Check if session is a Lunch Symposium
      final isLunchSymposium = session != null && 
                             session!['type'] != null && 
                             session!['type'] == 'Lunch Symposium';

      // Extract basic subsession data
      final subsessionTitle = subsession['title'] ?? 'Untitled Subsession';
      final subStartTime = _formatTimeValue(subsession['startTime'] ?? '');
      final subEndTime = _formatTimeValue(subsession['endTime'] ?? '');
      
      // Calculate duration
      final duration = _calculateDuration(subStartTime, subEndTime);
      
      // Get speaker data - needed for both regular and lunch symposia
      final List<dynamic> speakerIds = subsession['speakerIds'] is List ? subsession['speakerIds'] : [];
      final List<dynamic> speakers = subsession['speakers'] is List ? subsession['speakers'] : [];
      
      // Get subsubsessions if they exist
      final List<dynamic> subsubsessions = subsession['subsubsessions'] is List ? subsession['subsubsessions'] : [];
      
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isLunchSymposium ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLunchSymposium ? const Color(0xFF4b9188).withOpacity(0.3) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: isLunchSymposium ? const Color(0xFF4b9188).withOpacity(0.1) : Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
      ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Duration badge on the left
            if (duration.isNotEmpty)
                Container(
                margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                  color: const Color(0xFF4b9188).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4b9188).withOpacity(0.3)),
                ),
                child: Text(
                      duration,
                      style: const TextStyle(
                        color: Color(0xFF4b9188),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            
            // Main content
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Time display
                Row(
                  children: [
                    Icon(
                        Icons.schedule,
                      size: 16,
                        color: isLunchSymposium ? const Color(0xFF4b9188) : Colors.grey.shade600,
                    ),
                      const SizedBox(width: 4),
                    Text(
                        '$subStartTime - $subEndTime',
                        style: TextStyle(
                        fontSize: 14,
                          color: isLunchSymposium ? const Color(0xFF4b9188) : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                  
                  // Title with more prominent styling for lunch symposia
                                                    Text(
                    subsessionTitle,
                                                      style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLunchSymposium ? 16 : 14,
                      color: isLunchSymposium ? const Color(0xFF2e5f75) : Colors.black,
                    ),
                  ),
                  
                  // Speakers section - enhanced for lunch symposia
                  if (speakerIds.isNotEmpty || speakers.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    
                    // Regular display for normal sessions
                    if (!isLunchSymposium && speakers.isNotEmpty) ...[
                      ...speakers.map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
                    ]
                    // Enhanced display for lunch symposia
                    else if (isLunchSymposium) ...[
                      ...speakerIds.map<Widget>((speakerId) {
                        // Try to find speaker details
                        Map<String, dynamic>? speakerDetails;
                        
                        // First search in session speakers
                        if (session != null && session!['speakers'] != null && session!['speakers'] is List) {
                          for (var speaker in session!['speakers']) {
                            if (speaker['_id'] == speakerId) {
                              speakerDetails = speaker;
                              break;
                            }
                          }
                        }
                        
                        // If not found, search in subsession speakers
                        if (speakerDetails == null && subsession['speakers'] != null && subsession['speakers'] is List) {
                          for (var speaker in subsession['speakers']) {
                            if (speaker['_id'] == speakerId) {
                              speakerDetails = speaker;
                              break;
                            }
                          }
                        }
                        
                        // If not found, create a minimal speaker object
                        if (speakerDetails == null) {
                          speakerDetails = {
                            '_id': speakerId,
                            'name': 'Speaker $speakerId',
                          };
                        }
                        
                        return _buildSpeakerItem(speakerDetails);
                      }).toList(),
                    ] 
                    // Simple speaker names for normal sessions with only IDs
                    else if (speakerIds.isNotEmpty) ...[
                      Row(
                            children: [
                          Icon(Icons.person, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              speakerIds
                                .map((id) => _findSpeakerName(id))
                                .where((name) => name != null)
                                .join(", "),
                                style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                color: Color(0xFF4b9188),
                                        ),
                                  ),
                                ),
                            ],
                        ),
                      ],
            ],
            
            // Subsubsessions section
                  if (subsubsessions.isNotEmpty) ...[
              const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    ...subsubsessions.map<Widget>((subsubsession) {
                      final subsubTitle = subsubsession['title'] ?? '';
                      final subsubStartTime = _formatTimeValue(subsubsession['startTime'] ?? '');
                      final subsubEndTime = _formatTimeValue(subsubsession['endTime'] ?? '');
                      final List<dynamic> subsubSpeakers = subsubsession['speakers'] is List ? subsubsession['speakers'] : [];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subsubStartTime.isNotEmpty || subsubEndTime.isNotEmpty) ...[
                            Row(
                              children: [
                                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                    '$subsubStartTime - $subsubEndTime',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                              const SizedBox(height: 4),
                            ],
                                      Text(
                              subsubTitle,
                                        style: const TextStyle(
                                fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (subsubSpeakers.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...subsubSpeakers.map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
                                      ],
                                    ],
                                  ),
                      );
                    }).toList(),
                  ],
                  
                  // Add lab logo for lunch symposia if available
                  if (isLunchSymposium && session != null && session!['labLogoUrl'] != null && session!['labLogoUrl'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        height: 60,
                        constraints: const BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(session!['labLogoUrl']),
                            fit: BoxFit.contain,
                          ),
                        ),
                                ),
            ),
          ],
                  ],
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      print("Error building subsession item: $e");
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Text(
          "Error displaying subsession",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildChairpersonItem(dynamic chairperson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Replace avatar with simple icon
          GestureDetector(
            onTap: () {
              if (chairperson['bio'] != null && chairperson['bio'].toString().isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(chairperson['name'] ?? 'Unknown Chairperson'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chairperson image if available
                            if (chairperson['speakerImageUrl'] != null)
                              Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    image: DecorationImage(
                                      image: NetworkImage(chairperson['speakerImageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Chair badge
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4b9188).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Chair',
                                  style: TextStyle(
                                    color: Color(0xFF4b9188),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Country and flag
                            if (chairperson['country'] != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    if (chairperson['flagUrl'] != null)
          Container(
                                        width: 30,
                                        height: 20,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(chairperson['flagUrl']),
                                            fit: BoxFit.cover,
                                          ),
                                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                        ),
                                      ),
                                    Text(
                                      chairperson['country'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // Title if available
                            if (chairperson['title'] != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  chairperson['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                            
                            // Biography
                            Text(
                              chairperson['bio'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4b9188).withOpacity(0.1),
            ),
            child: Icon(
              Icons.person,
              color: const Color(0xFF4b9188),
              size: 24,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chairperson['name'] ?? 'Unknown Chairperson',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4b9188).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Chair',
                        style: TextStyle(
                          color: Color(0xFF4b9188),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (chairperson['title'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    chairperson['title'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (chairperson['country'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chairperson['flagUrl'] != null)
                          Container(
                            width: 24,
                            height: 16,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(chairperson['flagUrl']),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.grey.shade300, width: 0.5),
                            ),
                          ),
                        Text(
                          chairperson['country'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return '';
    
    try {
      // Parse times in "HH:mm" format
      final List<String> startParts = startTime.split(':');
      final List<String> endParts = endTime.split(':');
      
      if (startParts.length != 2 || endParts.length != 2) return '';
      
      final int startHour = int.parse(startParts[0]);
      final int startMinute = int.parse(startParts[1]);
      final int endHour = int.parse(endParts[0]);
      final int endMinute = int.parse(endParts[1]);
      
      // Calculate total minutes
      final int totalMinutes = (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
      
      if (totalMinutes < 0) return '';
      
      // Format result
      if (totalMinutes < 60) {
        return '$totalMinutes min';
      } else {
        final int hours = totalMinutes ~/ 60;
        final int minutes = totalMinutes % 60;
        return hours > 0 
          ? minutes > 0 
            ? '${hours}h ${minutes}min' 
            : '${hours}h'
          : '$minutes min';
      }
    } catch (e) {
      return '';
    }
  }

  // Add a function to format date string
  String _formatDate(String dateString) {
    try {
      // Parse ISO 8601 date format
      final DateTime date = DateTime.parse(dateString);
      // Format date as "15 Apr 2025"
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      // Return the original string if parsing fails
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
      
      // Format with leading zeros for both hours and minutes
      String formattedHours = hours.toString().padLeft(2, '0');
      String formattedMinutes = minutes.toString().padLeft(2, '0');
      
      return '$formattedHours:$formattedMinutes';
    } catch (e) {
      // If parsing fails, try to format the original value
      try {
        if (timeValue is String) {
          // Handle time strings in various formats
          final parts = timeValue.split(':');
          if (parts.length == 2) {
            final hours = int.parse(parts[0]);
            final minutes = int.parse(parts[1]);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
          }
        }
    } catch (e) {
        // If all parsing attempts fail, return the original value
        return timeValue.toString();
      }
      return timeValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract title and chairpersons
    final String sessionTitle = session?['title']?.toString() ?? 'Session Details';
    List<dynamic> chairpersons = [];
    
    // Handle different chairpersons data formats
    if (session?['chairpersons'] != null) {
      if (session!['chairpersons'] is List) {
        chairpersons = session!['chairpersons'];
      } else if (session!['chairpersons'] is String) {
        chairpersons = session!['chairpersons'].toString().split(',').map((e) => e.trim()).toList();
      }
    }
    
    // Get date from dayId if available
    String sessionDate = '';
    if (session != null && session!['dayId'] != null) {
      if (session!['dayId'] is Map && session!['dayId']['date'] != null) {
        sessionDate = session!['dayId']['date'].toString();
      }
    }
    
    // Use the session's direct date as fallback
    if (sessionDate.isEmpty && session?['date'] != null) {
      sessionDate = session!['date'].toString();
    }

    // Format the date
    String formattedDate = '';
    if (sessionDate.isNotEmpty) {
      try {
        final date = DateTime.parse(sessionDate);
        formattedDate = DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        formattedDate = sessionDate;
      }
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2e5f75)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 200,
              child: const VideoPlayerWidget(
                videoUrl: 'https://res.cloudinary.com/dfhhuvxlb/video/upload/v1743201099/AFRAN_Save_the_date_V3_rm3pgh.mp4',
                autoPlay: false,
                showControls: true,
              ),
            ),

            // Title section in blue container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2e5f75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sessionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Chairperson section
            if (chairpersons.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2e5f75).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF2e5f75),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Chair',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2e5f75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2e5f75).withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        chairpersons.map((chair) {
                          if (chair is Map) {
                            return chair['name']?.toString() ?? '';
                          } else if (chair is String) {
                            return chair;
                          }
                          return '';
                        }).where((name) => name.isNotEmpty).join(', '),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Keep existing content below
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date and time
                        if (sessionDate.isNotEmpty || 
                                    session?['startTime'] != null ||
                                    session?['endTime'] != null)
                          _buildInfoRow(
                            Icons.calendar_today,
                                    '${formattedDate} ${session?['startTime'] != null ? '• ${_formatTimeValue(session!['startTime'])}' : ''} ${session?['endTime'] != null ? '- ${_formatTimeValue(session!['endTime'])}' : ''}',
                          ),

                        // Room
                        if (session?['roomId'] != null || session?['room'] != null)
                          _buildInfoRow(
                            Icons.location_on,
                                    _getRoomName(),
                                  ),
                      ],
                    ),
                  ),
                  
                  // Description section
                  if (session != null && 
                      session!['description'] != null && 
                      session!['description'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        session!['description'].toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  
                  // Speakers section
                  if (session?['speakers'] != null && session?['speakers'] is List && session?['speakers'].isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF2e5f75)),
                              const SizedBox(width: 8),
                              Text(
                                        session?['speakers'].length == 1 ? 'Speaker' : 'Speakers',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...session?['speakers'].map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
                        ],
                      ),
                    ),
                  
                  // Subsessions section with enhanced visibility
                  if (subsessions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4b9188).withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4b9188).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Color(0xFF2e5f75), size: 24),
                              const SizedBox(width: 8),
                              Text(
                                        'Schedule (${subsessions.length} Interventions)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF2e5f75), thickness: 1, height: 24),
                          ...sortedSubsessions.map<Widget>((subsession) => _buildSubsessionItem(subsession)).toList(),
                        ],
                      ),
                    ),

                  // Show error message if no subsessions found but they're expected
                  if (isLoading == false && session != null && session!['_id'] != null && subsessions.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200, width: 1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              const Text(
                                "No subsessions available",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "This session does not contain any subsessions or they could not be loaded.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Signature
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  "Powered by J'inspire GROUP",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoomName() {
    if (session == null) return 'Room not specified';
    
    final sessionId = session!['_id'];
    final sessionTitle = session!['title'] ?? '';
    
    try {
      print("Getting room name for session: $sessionTitle (ID: $sessionId)");
      
      // Special fix for specific sessions
      if (sessionId == '67e435574740c1f09021b0e4' || 
          sessionId == '67e435554740c1f09021b0b7') {
        print("Session $sessionTitle: Special fix to BEN AYED Conference Hall");
        // Force set the roomId for these sessions
        if (session!['roomId'] == null) {
          session!['roomId'] = '67e0abdbd899f8432337ca6c'; // ID for Pr. Hassouna BEN AYED Conference Hall
        }
        return 'Pr. Hassouna BEN AYED Conference Hall';
      }
      
      // Check for direct room field first
      if (session!['room'] != null && session!['room'].toString().isNotEmpty) {
        final roomName = session!['room'].toString();
        print("Session $sessionTitle: Used direct room string: $roomName");
        return roomName;
      }
      
      // Check for roomId
      if (session!['roomId'] != null) {
        if (session!['roomId'] is Map && session!['roomId']['name'] != null) {
          final roomName = session!['roomId']['name'];
          print("Session $sessionTitle: Found direct roomId.name: $roomName");
          return roomName;
        }
        
        String roomIdStr = '';
        if (session!['roomId'] is Map && session!['roomId']['_id'] != null) {
          roomIdStr = session!['roomId']['_id'];
        } else if (session!['roomId'] is String) {
          roomIdStr = session!['roomId'];
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
      if (session!['roomName'] != null && session!['roomName'].toString().isNotEmpty) {
        final roomName = session!['roomName'].toString();
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF2e5f75),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add helper method to find speaker name by ID
  String? _findSpeakerName(dynamic speakerId) {
    if (speakerId == null) return null;
    
    // First search in session speakers
    if (session != null && session!['speakers'] != null && session!['speakers'] is List) {
      for (var speaker in session!['speakers']) {
        if (speaker['_id'] == speakerId) {
          return speaker['name'];
        }
      }
    }
    
    // Then search in all subsession speakers
    for (var subsession in subsessions) {
      if (subsession['speakers'] != null && subsession['speakers'] is List) {
        for (var speaker in subsession['speakers']) {
          if (speaker['_id'] == speakerId) {
            return speaker['name'];
          }
        }
      }
    }
    
    return 'Speaker $speakerId';
  }

  // Helper method to sort subsessions by start time
  List<dynamic> get sortedSubsessions {
    if (subsessions.isEmpty) return [];
    
    return List<dynamic>.from(subsessions)..sort((a, b) {
      final aTime = a['startTime']?.toString() ?? '';
      final bTime = b['startTime']?.toString() ?? '';
      return aTime.compareTo(bTime);
    });
  }
} 