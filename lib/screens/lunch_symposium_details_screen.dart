import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config.dart';

class LunchSymposiumDetailsScreen extends StatefulWidget {
  final dynamic lunchSymposium;

  const LunchSymposiumDetailsScreen({
    Key? key,
    required this.lunchSymposium,
  }) : super(key: key);

  @override
  State<LunchSymposiumDetailsScreen> createState() => _LunchSymposiumDetailsScreenState();
}

class _LunchSymposiumDetailsScreenState extends State<LunchSymposiumDetailsScreen> {
  List<dynamic> _subsessions = [];
  bool _isLoading = false;
  dynamic _symposiumData;
  final String apiUrl = Config.defaultApiUrl;

  @override
  void initState() {
    super.initState();
    
    _symposiumData = widget.lunchSymposium;
    
    // Extract subsessions from subsessionTexts array
    if (_symposiumData != null && _symposiumData['subsessionTexts'] != null) {
      setState(() {
        _subsessions = _symposiumData['subsessionTexts'] as List;
      });
      print("Found ${_subsessions.length} subsessions in symposium data");
    }
    
    // If no subsessions found but we have an ID, fetch full symposium details
    if (_subsessions.isEmpty && _symposiumData['_id'] != null) {
      _fetchSymposiumDetails(_symposiumData['_id']);
    }
  }
  
  // Fetch full symposium details from API
  Future<void> _fetchSymposiumDetails(String symposiumId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final response = await http.get(
        Uri.parse('$apiUrl/sessions/$symposiumId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null) {
          setState(() {
            _symposiumData = data;
            if (data['subsessionTexts'] != null) {
              _subsessions = data['subsessionTexts'] as List;
            }
            _isLoading = false;
          });
          print("Successfully fetched ${_subsessions.length} subsessions");
        }
      } else {
        print("Error fetching session details: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception when fetching session details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Format date from ISO string
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, y').format(date);
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
  
  // Helper method to find speaker name by ID
  String? _findSpeakerName(String speakerId) {
    if (_symposiumData != null && _symposiumData['speakers'] != null && _symposiumData['speakers'] is List) {
      for (var speaker in _symposiumData['speakers']) {
        if (speaker['_id'] == speakerId) {
          return speaker['name'];
        }
      }
    }
    
    return null;
  }
  
  // Helper method to build info row with icon and text
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9C27B0)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Extract symposium data
    final String symposiumTitle = _symposiumData['title'] ?? 'Lunch Symposium';
    final String symposiumDate = _symposiumData['dayId'] != null && _symposiumData['dayId'] is Map 
        ? _formatDate(_symposiumData['dayId']['date'] ?? '')
        : _formatDate(_symposiumData['date'] ?? '');
    final String startTime = _formatTimeValue(_symposiumData['startTime'] ?? '');
    final String endTime = _formatTimeValue(_symposiumData['endTime'] ?? '');
    final String room = _symposiumData['roomId'] != null && _symposiumData['roomId'] is Map 
        ? _symposiumData['roomId']['name'] 
        : (_symposiumData['room'] ?? 'Room not specified');

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 2,
                color: const Color(0xFF9C27B0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Lunch Symposium',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ),
              Container(
                width: 55,
                height: 2,
                color: const Color(0xFF9C27B0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9C27B0),
        toolbarHeight: 140,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symposium Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symposiumTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              symposiumDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '$startTime - $endTime',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              room,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Lab Logo if available
                  if (_symposiumData['labLogoUrl'] != null && _symposiumData['labLogoUrl'].toString().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Presented by',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Image.network(
                            _symposiumData['labLogoUrl'],
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                  // Interventions Section
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_note, color: Color(0xFF9C27B0)),
                            const SizedBox(width: 8),
                            Text(
                              'Program (${_subsessions.length} Interventions)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF9C27B0), height: 24),
                        ..._subsessions.map((subsession) => _buildSubsessionItem(subsession)).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Build the speakers section
  Widget _buildSpeakersSection() {
    return Container(
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
          const Text(
            'Featured Speakers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 16),
          ...(_symposiumData['speakers'] as List).map<Widget>((speaker) => _buildSpeakerItem(speaker)).toList(),
        ],
      ),
    );
  }
  
  // Build the subsessions section
  Widget _buildSubsessionsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
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
              const Icon(Icons.schedule, color: Color(0xFF9C27B0), size: 24),
              const SizedBox(width: 8),
              Text(
                'Symposium Schedule (${_subsessions.length} Sessions)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF9C27B0), thickness: 1, height: 24),
          ..._subsessions.map<Widget>((subsession) => _buildSubsessionItem(subsession)).toList(),
        ],
      ),
    );
  }
  
  // Build individual speaker item
  Widget _buildSpeakerItem(dynamic speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Speaker image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF9C27B0), width: 2),
                image: (speaker['image'] != null || speaker['speakerImageUrl'] != null)
                    ? DecorationImage(
                        image: NetworkImage(speaker['image'] ?? speaker['speakerImageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (speaker['image'] == null && speaker['speakerImageUrl'] == null)
                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            // Speaker details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speaker['name'] ?? 'Unknown Speaker',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                  if (speaker['title'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      speaker['title'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  if (speaker['country'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (speaker['flagUrl'] != null)
                          Container(
                            width: 24,
                            height: 16,
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
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Add this new method to show speaker bio
  void _showSpeakerBio(dynamic speaker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaker Header
                Row(
                  children: [
                    // Speaker image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: const Color(0xFF9C27B0).withOpacity(0.3),
                          width: 2,
                        ),
                        image: (speaker['image'] != null || speaker['speakerImageUrl'] != null)
                            ? DecorationImage(
                                image: NetworkImage(speaker['image'] ?? speaker['speakerImageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (speaker['image'] == null && speaker['speakerImageUrl'] == null)
                          ? Icon(Icons.person, color: Colors.grey.shade400, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Speaker name and title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            speaker['name'] ?? 'Unknown Speaker',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          if (speaker['title'] != null)
                            Text(
                              speaker['title'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Speaker Bio
                if (speaker['bio'] != null && speaker['bio'].toString().isNotEmpty)
                  Text(
                    speaker['bio'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    'No biography available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 20),
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF9C27B0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Update the speaker item in _buildSubsessionItem to be tappable
  Widget _buildSubsessionItem(dynamic subsession) {
    try {
      // Extract subsession data
      final subsessionTitle = subsession['title'] ?? 'Untitled Subsession';
      final speakerIds = subsession['speakerIds'] as List? ?? [];
      
      // Get speaker details from symposium data
      List<dynamic> speakers = [];
      if (_symposiumData != null && _symposiumData['speakers'] != null) {
        speakers = (_symposiumData['speakers'] as List).where((speaker) => 
          speakerIds.contains(speaker['_id'])
        ).toList();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subsession Title
            Text(
              subsessionTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            // Speaker Details
            if (speakers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...speakers.map<Widget>((speaker) {
                return GestureDetector(
                  onTap: () => _showSpeakerBio(speaker),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Speaker image
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                            border: Border.all(
                              color: const Color(0xFF9C27B0).withOpacity(0.3),
                              width: 2,
                            ),
                            image: (speaker['image'] != null || speaker['speakerImageUrl'] != null)
                                ? DecorationImage(
                                    image: NetworkImage(speaker['image'] ?? speaker['speakerImageUrl']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (speaker['image'] == null && speaker['speakerImageUrl'] == null)
                              ? Icon(Icons.person, color: Colors.grey.shade400, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        
                        // Speaker details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                speaker['name'] ?? 'Unknown Speaker',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF9C27B0),
                                ),
                              ),
                              if (speaker['title'] != null)
                                Text(
                                  speaker['title'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              if (speaker['country'] != null)
                                Row(
                                  children: [
                                    if (speaker['flagUrl'] != null)
                                      Container(
                                        width: 16,
                                        height: 10,
                                        margin: const EdgeInsets.only(right: 4),
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
                                        fontSize: 11,
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
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      );
    } catch (e) {
      print("Error building subsession item: $e");
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
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

  // Add new subsession
  Future<void> addSubsession(Map<String, dynamic> subsession) async {
    try {
      // Ensure required fields are present
      subsession = {
        '_id': DateTime.now().millisecondsSinceEpoch.toString(), // Generate a temporary ID
        'title': subsession['title'] ?? '',
        'startTime': subsession['startTime'] ?? '',
        'endTime': subsession['endTime'] ?? '',
        'subsessionText': subsession['subsessionText'] ?? '',
        'speakerIds': subsession['speakerIds'] ?? [],
        'lunchSymposiumId': _symposiumData['_id'], // Link to parent symposium
      };
      
      final response = await http.post(
        Uri.parse('$apiUrl/api/lunch-symposia/${_symposiumData['_id']}/subsessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(subsession),
      );
      
      if (response.statusCode == 201) {
        final newSubsession = json.decode(response.body);
        setState(() {
          _subsessions = [..._subsessions, newSubsession];
        });
        print("Successfully added new subsession with ID: ${newSubsession['_id']}");
      } else {
        print("Error adding subsession: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when adding subsession: $e");
    }
  }

  // Update existing subsession
  Future<void> updateSubsession(String subsessionId, Map<String, dynamic> updatedData) async {
    try {
      // Ensure required fields are present
      updatedData = {
        '_id': subsessionId, // Preserve the existing ID
        'title': updatedData['title'] ?? '',
        'startTime': updatedData['startTime'] ?? '',
        'endTime': updatedData['endTime'] ?? '',
        'subsessionText': updatedData['subsessionText'] ?? '',
        'speakerIds': updatedData['speakerIds'] ?? [],
        'lunchSymposiumId': _symposiumData['_id'], // Link to parent symposium
      };
      
      final response = await http.put(
        Uri.parse('$apiUrl/api/lunch-symposia/${_symposiumData['_id']}/subsessions/$subsessionId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );
      
      if (response.statusCode == 200) {
        final updatedSubsession = json.decode(response.body);
        setState(() {
          _subsessions = _subsessions.map((s) => 
            s['_id'] == subsessionId ? updatedSubsession : s
          ).toList();
        });
        print("Successfully updated subsession with ID: $subsessionId");
      } else {
        print("Error updating subsession: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when updating subsession: $e");
    }
  }

  // Delete subsession
  Future<void> deleteSubsession(String subsessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/lunch-symposia/${_symposiumData['_id']}/subsessions/$subsessionId'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _subsessions = _subsessions.where((s) => s['_id'] != subsessionId).toList();
        });
        print("Successfully deleted subsession with ID: $subsessionId");
      } else {
        print("Error deleting subsession: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when deleting subsession: $e");
    }
  }

  // Import subsessions from Excel
  Future<void> importSubsessionsFromExcel(String symposiumId, List<Map<String, dynamic>> excelData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/lunch-symposia/$symposiumId/import-subsessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subsessions': excelData.map((row) => {
            'title': row['Title'] ?? '',
            'startTime': row['Start Time'] ?? '',
            'endTime': row['End Time'] ?? '',
            'description': row['Description'] ?? '',
            'speakerId': row['Speaker ID'] ?? '',
          }).toList()
        }),
      );

      if (response.statusCode == 201) {
        final importedSubsessions = json.decode(response.body);
        setState(() {
          final existingIds = _subsessions.map((s) => s['_id']).toSet();
          final newSubsessions = (importedSubsessions as List)
              .where((s) => !existingIds.contains(s['_id']))
              .toList();
          _subsessions = [..._subsessions, ...newSubsessions];
        });
        print("Successfully imported ${importedSubsessions.length} subsessions from Excel");
      } else {
        print("Error importing subsessions: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when importing subsessions: $e");
    }
  }

  // Import full lunch symposium from Excel
  Future<void> importLunchSymposiumFromExcel(Map<String, dynamic> excelData) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/lunch-symposia/import'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': excelData['Symposium Title'] ?? '',
          'description': excelData['Description'] ?? '',
          'date': excelData['Date'] ?? '',
          'startTime': excelData['Start Time'] ?? '',
          'endTime': excelData['End Time'] ?? '',
          'roomId': excelData['Room'] ?? '',
          'labLogoUrl': excelData['Lab Logo URL'] ?? '',
          'dayId': excelData['Day ID'] ?? '',
          'chairpersons': excelData['Chairpersons'] ?? '',
          'subsessions': (excelData['Subsessions'] as List<Map<String, dynamic>>?)?.map((subsession) => {
            'title': subsession['Title'] ?? '',
            'startTime': subsession['Start Time'] ?? '',
            'endTime': subsession['End Time'] ?? '',
            'description': subsession['Description'] ?? '',
            'speakerId': subsession['Speaker ID'] ?? '',
          }).toList() ?? []
        }),
      );

      if (response.statusCode == 201) {
        final importedSymposium = json.decode(response.body);
        setState(() {
          _symposiumData = importedSymposium;
          _subsessions = importedSymposium['subsessions'] ?? [];
        });
        print("Successfully imported lunch symposium from Excel");
      } else {
        print("Error importing lunch symposium: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception when importing lunch symposium: $e");
    }
  }
} 