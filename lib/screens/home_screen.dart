import 'package:flutter/material.dart';
import 'program_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sponsors_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'session_details_screen.dart';
import '../config.dart';
import 'welcome_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _featuredSponsors = [];
  List<dynamic> _upcomingSessions = [];
  List<dynamic> _pinnedSessions = [];
  bool _isLoadingSponsors = false;
  bool _isLoadingSessions = false;
  bool _isLoadingPinned = false;
  Map<String, dynamic>? _welcomeMessage;
  bool _isLoadingWelcomeMessage = false;
  Map<String, dynamic>? _logoData;
  bool _isLoadingLogo = false;
  List<dynamic> _partners = [];
  bool _isLoadingPartners = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedSponsors();
    _fetchUpcomingSessions();
    _fetchPinnedSessions();
    _fetchWelcomeMessage();
    _fetchPartners();
    _fetchLogo();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Refresh all data
    await Future.wait([
      _fetchFeaturedSponsors(),
      _fetchUpcomingSessions(),
      _fetchPinnedSessions(),
      _fetchWelcomeMessage(),
      _fetchPartners(),
      _fetchLogo(),
    ]);
    return;
  }

  Future<void> _fetchFeaturedSponsors() async {
    setState(() {
      _isLoadingSponsors = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/sponsors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> allSponsors = json.decode(response.body);
        // Filter for Platinum and Diamond sponsors only
        final featured = allSponsors.where((sponsor) {
          final rank = sponsor['rank'] ?? '';
          return rank == 'Platinum' || rank == 'Diamond';
        }).toList();
        
        setState(() {
          _featuredSponsors = featured;
          _isLoadingSponsors = false;
        });
      } else {
        setState(() {
          _isLoadingSponsors = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSponsors = false;
      });
    }
  }

  Future<void> _fetchUpcomingSessions() async {
    setState(() {
      _isLoadingSessions = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/sessions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> allSessions = json.decode(response.body);
        // Get current date for comparison
        final now = DateTime.now();
        
        // Filter for upcoming sessions and sort by date
        final upcoming = allSessions.where((session) {
          if (session['date'] == null) return false;
          try {
            final sessionDate = DateTime.parse(session['date']);
            return sessionDate.isAfter(now);
          } catch (e) {
            // Skip sessions with invalid dates
            return false;
          }
        }).toList();
        
        // Sort by date
        upcoming.sort((a, b) {
          try {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0; // Equal if dates can't be parsed
          }
        });
        
        // Take only the next 3 sessions
        setState(() {
          _upcomingSessions = upcoming.take(3).toList();
          _isLoadingSessions = false;
        });
      } else {
        setState(() {
          _isLoadingSessions = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _fetchPinnedSessions() async {
    setState(() {
      _isLoadingPinned = true;
    });

    try {
      // Load pinned session IDs from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final pinnedIds = prefs.getStringList('pinned_sessions') ?? [];
      
      if (pinnedIds.isEmpty) {
        setState(() {
          _pinnedSessions = [];
          _isLoadingPinned = false;
        });
        return;
      }
      
      // Fetch all sessions to filter for pinned ones
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/sessions'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> allSessions = json.decode(response.body);
        
        // Filter for pinned sessions
        final pinned = allSessions.where((session) {
          return pinnedIds.contains(session['_id']);
        }).toList();
        
        setState(() {
          _pinnedSessions = pinned;
          _isLoadingPinned = false;
        });
      } else {
        setState(() {
          _isLoadingPinned = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPinned = false;
      });
    }
  }

  Future<void> _fetchWelcomeMessage() async {
    setState(() {
      _isLoadingWelcomeMessage = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/messages?active=true'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> messages = json.decode(response.body);
        if (messages.isNotEmpty) {
          setState(() {
            _welcomeMessage = messages[0];
            _isLoadingWelcomeMessage = false;
          });
        } else {
          setState(() {
            _isLoadingWelcomeMessage = false;
          });
        }
      } else {
        setState(() {
          _isLoadingWelcomeMessage = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingWelcomeMessage = false;
      });
    }
  }

  Future<void> _fetchPartners() async {
    setState(() {
      _isLoadingPartners = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/partners'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> allPartners = json.decode(response.body);
        setState(() {
          _partners = allPartners;
          _isLoadingPartners = false;
        });
      } else {
        setState(() {
          _isLoadingPartners = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPartners = false;
      });
    }
  }

  Future<void> _fetchLogo() async {
    setState(() {
      _isLoadingLogo = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.defaultApiUrl}/logo'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> logoData = json.decode(response.body);
        setState(() {
          _logoData = logoData;
          _isLoadingLogo = false;
        });
      } else {
        setState(() {
          _isLoadingLogo = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLogo = false;
      });
    }
  }

  Widget _buildWelcomeBanner() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4b9188),
              const Color(0xFF4b9188).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4b9188).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
            Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to AFRAN 2025',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '18th Congress of the African Association of Nephrology',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                  const SizedBox(width: 8),
                  const Text(
                    '15-18 Avril 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 18, color: Colors.white70),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Radisson Blu Hotel & Convention Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProgramScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2e5f75),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Program',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0e1b2b),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://i.imgur.com/VsREPjb.png',
              width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isLoadingWelcomeMessage 
                        ? 'Loading message...' 
                        : (_welcomeMessage != null 
                            ? _welcomeMessage!['title'] ?? 'Welcome Message'
                            : 'Welcome Message'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_welcomeMessage != null && _welcomeMessage!['authors'] != null) ...[
                  Text(
                    (_welcomeMessage!['authors'] as List)
                      .map((author) => author['name'] ?? '')
                      .where((name) => name.isNotEmpty)
                      .join(' & '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if ((_welcomeMessage!['authors'] as List).isNotEmpty && 
                      (_welcomeMessage!['authors'] as List)[0]['title'] != null) 
                    Text(
                      (_welcomeMessage!['authors'] as List)[0]['title'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                ] else ...[
                  const Text(
                    'Pr Ezzedine ABDERRAHIM & Pr Mohamed Hany HAFEZ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Présidents du 18ème Congrès AFRAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _welcomeMessage != null && _welcomeMessage!['content'] != null
                    ? '${_welcomeMessage!['content'].toString().substring(0, _welcomeMessage!['content'].toString().length > 80 ? 80 : _welcomeMessage!['content'].toString().length)}...'
                    : 'Lisez le message de bienvenue officiel des présidents du congrès...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white70),
                    label: const Text(
                      'Read More',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onPressed: () {
                      _showWelcomeMessageDetails();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWelcomeMessageDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomeMessageScreen(),
      ),
    );
  }

  Widget _buildUpcomingSessionsSection() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4b9188).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: Color(0xFF4b9188),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                  const Text(
                  'Upcoming Sessions',
                    style: TextStyle(
                    fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgramScreen(),
                          ),
                        );
                      },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('See All'),
                ),
              ],
            ),
          ),
          
          if (_isLoadingSessions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_upcomingSessions.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No upcoming sessions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back soon for session updates',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: _upcomingSessions
                  .map((session) => _buildUpcomingSessionCard(session))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionCard(Map<String, dynamic> session) {
    // Add safe date parsing with defaults
    String formattedDate = '';
    String formattedTime = '';
    
    if (session['date'] != null) {
      try {
        final sessionDate = DateTime.parse(session['date']);
        formattedDate = '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
        
        // Check if we have specific startTime/endTime fields
        if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
          if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
            String formattedStartTime = _formatTimeValue(session['startTime']);
            String formattedEndTime = _formatTimeValue(session['endTime']);
            formattedTime = '$formattedStartTime - $formattedEndTime';
          } else {
            formattedTime = _formatTimeValue(session['startTime']);
          }
        } else {
          formattedTime = '${sessionDate.hour.toString().padLeft(2, '0')}:${sessionDate.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        // If date parsing fails, check for standalone startTime/endTime fields
        if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
          if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
            String formattedStartTime = _formatTimeValue(session['startTime']);
            String formattedEndTime = _formatTimeValue(session['endTime']);
            formattedTime = '$formattedStartTime - $formattedEndTime';
          } else {
            formattedTime = _formatTimeValue(session['startTime']);
          }
        }
      }
    } else {
      // No date field, try using standalone startTime/endTime
      if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
        if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
          String formattedStartTime = _formatTimeValue(session['startTime']);
          String formattedEndTime = _formatTimeValue(session['endTime']);
          formattedTime = '$formattedStartTime - $formattedEndTime';
        } else {
          formattedTime = _formatTimeValue(session['startTime']);
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate directly to session details when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(
              sessionId: session['_id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (formattedDate.isNotEmpty) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4b9188).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Color(0xFF4b9188),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (formattedDate.isNotEmpty) const SizedBox(width: 8),
                  if (formattedTime.isNotEmpty) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2e5f75).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Color(0xFF2e5f75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session['title'] ?? 'Session sans titre',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (session['speaker'] != null && session['speaker'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session['speaker'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (session['room'] != null && session['room'].toString().isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session['room'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (session['location'] != null && session['location'].toString().isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedSessionsSection() {
    if (_pinnedSessions.isEmpty && !_isLoadingPinned) {
      return const SizedBox.shrink(); // Don't show section if no pinned sessions
    }
    
    return Container(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4b9188).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Color(0xFF4b9188),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Pinned Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgramScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('See All'),
                ),
              ],
            ),
          ),
          
          if (_isLoadingPinned)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: _pinnedSessions
                  .map((session) => _buildPinnedSessionCard(session))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPinnedSessionCard(Map<String, dynamic> session) {
    // Format date and time from session data
    String formattedDate = '';
    String formattedTime = '';
    
    // Try to use the date field first for formatting date
    if (session['date'] != null) {
      try {
        final sessionDate = DateTime.parse(session['date']);
        formattedDate = '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
        
        // Check if we have specific startTime/endTime fields to use instead
        if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
          if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
            String formattedStartTime = _formatTimeValue(session['startTime']);
            String formattedEndTime = _formatTimeValue(session['endTime']);
            formattedTime = '$formattedStartTime - $formattedEndTime';
          } else {
            formattedTime = _formatTimeValue(session['startTime']);
          }
        } else {
          formattedTime = '${sessionDate.hour.toString().padLeft(2, '0')}:${sessionDate.minute.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        // If date parsing fails, check for standalone startTime/endTime fields
        if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
          if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
            String formattedStartTime = _formatTimeValue(session['startTime']);
            String formattedEndTime = _formatTimeValue(session['endTime']);
            formattedTime = '$formattedStartTime - $formattedEndTime';
          } else {
            formattedTime = _formatTimeValue(session['startTime']);
          }
        }
      }
    } else {
      // No date field, try using standalone startTime/endTime
      if (session['startTime'] != null && session['startTime'].toString().isNotEmpty) {
        if (session['endTime'] != null && session['endTime'].toString().isNotEmpty) {
          String formattedStartTime = _formatTimeValue(session['startTime']);
          String formattedEndTime = _formatTimeValue(session['endTime']);
          formattedTime = '$formattedStartTime - $formattedEndTime';
        } else {
          formattedTime = _formatTimeValue(session['startTime']);
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate directly to session details when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionDetailsScreen(
              sessionId: session['_id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4b9188), width: 2),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    if (formattedDate.isNotEmpty) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4b9188).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF4b9188),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (formattedDate.isNotEmpty) const SizedBox(width: 8),
                    if (formattedTime.isNotEmpty) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2e5f75).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Color(0xFF2e5f75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session['title'] ?? 'Session sans titre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (session['type'] != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session['type'] ?? 'Session',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (session['room'] != null && session['room'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.room,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session['room'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Simplified chairpersons display - just text
                if (session['chairpersons'] != null && session['chairpersons'] is List && session['chairpersons'].isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Chairpersons: ${session['chairpersons'].where((c) => c['name'] != null && c['name'].toString().isNotEmpty).map((c) => c['name']).join(', ')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Speakers list without images, just names, flags and countries
                if (session['speakers'] != null && session['speakers'] is List && session['speakers'].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Intervenants:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    session['speakers'].length > 3 ? 3 : session['speakers'].length,
                    (index) {
                      final speaker = session['speakers'][index];
                      if (speaker == null || (speaker['name'] == null || speaker['name'].toString().isEmpty)) {
                        return const SizedBox.shrink(); // Skip speakers with no name
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Speaker image
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 10),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    speaker['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (speaker['country'] != null && speaker['country'].toString().isNotEmpty)
                                    Row(
                                      children: [
                                        if (speaker['flagUrl'] != null) 
                                          Container(
                                            width: 20,
                                            height: 12,
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(speaker['flagUrl']),
                                                fit: BoxFit.cover,
                                              ),
                                              border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                            ),
                                          )
                                        else
                                          Text(
                                            _getCountryFlag(speaker['country']),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        const SizedBox(width: 4),
                                        Text(
                                          speaker['country'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (session['speakers'].length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+ ${session['speakers'].length - 3} other speakers',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
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
    ));
  }

  // Add a helper method to get country flags
  String _getCountryFlag(String countryCode) {
    // This is a simplified version using a few common country codes
    // In a real app, you would have a more comprehensive mapping
    switch (countryCode.toUpperCase()) {
      case 'TN':
        return '🇹🇳';
      case 'FR':
        return '🇫🇷';
      case 'EG':
        return '🇪🇬';
      case 'MA':
        return '🇲🇦';
      case 'DZ':
        return '🇩🇿';
      case 'SN':
        return '🇸🇳';
      case 'CI':
        return '🇨🇮';
      case 'US':
        return '🇺🇸';
      case 'UK':
        return '🇬🇧';
      case 'CM':
        return '🇨🇲';
      case 'CA':
        return '🇨🇦';
      case 'BE':
        return '🇧🇪';
      case 'CH':
        return '🇨🇭';
      case 'DE':
        return '🇩🇪';
      default:
        return '🌍'; // Default globe for unknown countries
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

  Widget _buildPartnersSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4b9188).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.handshake,
                          color: Color(0xFF4b9188),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Nos Partenaires',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to partners screen using our navigation system
                      Navigator.of(context).pushNamed('/partners');
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoadingPartners)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_partners.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.handshake_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Liste des partenaires à venir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les partenaires seront annoncés prochainement',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Show only up to 2 partners
                  ...List.generate(
                    _partners.length > 2 ? 2 : _partners.length,
                    (index) => _buildPartnerCard(_partners[index]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: partner['url'] != null && partner['url'].isNotEmpty
            ? () async {
                // Launch the partner website URL
                final Uri url = Uri.parse(partner['url']);
                try {
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open the website: ${e.toString()}')),
                    );
                  }
                }
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Partner logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: partner['logoUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          partner['logoUrl'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Partner details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner['name'] ?? 'Partenaire',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (partner['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        partner['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (partner['url'] != null && partner['url'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4b9188).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              size: 14,
                              color: Color(0xFF4b9188),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Visiter le site web',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4b9188),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Visit icon
              if (partner['url'] != null && partner['url'].isNotEmpty)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4b9188).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Color(0xFF4b9188),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSponsorsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4b9188).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business,
                    color: Color(0xFF4b9188),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Our Sponsors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SponsorsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingSponsors)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_featuredSponsors.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sponsors available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sponsors will be announced soon',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Show only up to 3 sponsors
                    ...List.generate(
                      _featuredSponsors.length > 3 ? 3 : _featuredSponsors.length,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _featuredSponsors[index]['imageUrl'] != null && _featuredSponsors[index]['imageUrl'].toString().isNotEmpty
                                    ? Image.network(
                                        _featuredSponsors[index]['imageUrl'],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.business,
                                              size: 32,
                                              color: _getRankColor(_featuredSponsors[index]['rank'] ?? '').withOpacity(0.5),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.business,
                                          size: 32,
                                          color: _getRankColor(_featuredSponsors[index]['rank'] ?? '').withOpacity(0.5),
                                        ),
                                      ),
                                ),
                              ),
                              // Name
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: _getRankColor(_featuredSponsors[index]['rank'] ?? '').withOpacity(0.1),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: Text(
                                  _featuredSponsors[index]['name'] ?? 'Sponsor',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toLowerCase()) {
      case 'platinum':
        return const Color(0xFF8E8E8E);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoadingLogo || _logoData == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.network(
                  _logoData!['logoUrl'],
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        toolbarHeight: _isLoadingLogo || _logoData == null ? kToolbarHeight : 140,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(),
              const SizedBox(height: 24),
              _buildWelcomeMessageCard(),
              const SizedBox(height: 24),
              _buildUpcomingSessionsSection(),
              const SizedBox(height: 24),
              _buildPinnedSessionsSection(),
              const SizedBox(height: 24),
              _buildFeaturedSponsorsSection(),
              const SizedBox(height: 24),
              _buildPartnersSection(),
              const SizedBox(height: 24),
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
      ),
    );
  }
} 