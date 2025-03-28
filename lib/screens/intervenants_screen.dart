import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class IntervenantsScreen extends StatefulWidget {
  const IntervenantsScreen({super.key});

  @override
  State<IntervenantsScreen> createState() => _IntervenantsScreenState();
}

class _IntervenantsScreenState extends State<IntervenantsScreen> {
  List<dynamic> _speakers = [];
  List<dynamic> _filteredSpeakers = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSpeakers();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpeakers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/speakers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> speakers = json.decode(response.body);
          
          // Sort speakers alphabetically by name (case-insensitive)
          speakers.sort((a, b) {
            final String nameA = (a['name'] ?? '').toString().toLowerCase().trim();
            final String nameB = (b['name'] ?? '').toString().toLowerCase().trim();
            return nameA.compareTo(nameB);
          });
          
          setState(() {
            _speakers = speakers;
            _filteredSpeakers = speakers;
            _isLoading = false;
          });
        } catch (parseError) {
          setState(() {
            _error = 'Error parsing data: $parseError';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load speakers (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  void _filterSpeakers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSpeakers = _speakers;
      } else {
        _filteredSpeakers = _speakers.where((speaker) {
          final name = speaker['name'] ?? '';
          final country = speaker['country'] ?? '';
          final bio = speaker['bio'] ?? '';
          
          return name.toString().toLowerCase().contains(query.toLowerCase()) ||
                 country.toString().toLowerCase().contains(query.toLowerCase()) ||
                 bio.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _testAPIEndpoint() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing API connection...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/speakers'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final int speakerCount = data is List ? data.length : 0;
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API working: Found $speakerCount speakers'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          _fetchSpeakers();
        } catch (e) {
          _showErrorSnackbar('API returned invalid data: $e');
        }
      } else {
        _showErrorSnackbar('API returned error code: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Connection error: $e');
    }
  }
  
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'Our Speakers',
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
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
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
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search speakers by name, country...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSpeakers('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: _filterSpeakers,
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchSpeakers,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _testAPIEndpoint,
              child: const Text('Test API Endpoint'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredSpeakers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty 
                ? 'No speakers available' 
                : 'No speakers found for "${_searchController.text}"',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _filterSpeakers('');
                },
                child: const Text('Clear search'),
              )
            ]
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchSpeakers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSpeakers.length,
        itemBuilder: (context, index) {
          final speaker = _filteredSpeakers[index];
          return _buildSpeakerCard(speaker);
        },
      ),
    );
  }

  Widget _buildSpeakerCard(dynamic speaker) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showSpeakerDetails(context, speaker);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Speaker image
              Container(
                width: 70,
                height: 70,
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
                    ? Icon(Icons.person, color: Colors.grey.shade400, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Speaker info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speaker['name'] ?? 'Unknown Speaker',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (speaker['country'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCountryColor(
                              speaker['country']),
                          borderRadius:
                              BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (speaker['flagUrl'] != null) ...[
                              Container(
                                width: 20,
                                height: 14,
                                margin: const EdgeInsets.only(
                                    right: 6),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        speaker['flagUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              speaker['country'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (speaker['bio'] != null &&
                        speaker['bio'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        speaker['bio'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voir plus',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeakerDetails(BuildContext context, dynamic speaker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Speaker image
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: speaker['speakerImageUrl'] != null
                          ? DecorationImage(
                              image: NetworkImage(speaker['speakerImageUrl']),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: speaker['speakerImageUrl'] == null
                        ? Icon(Icons.person,
                            color: Colors.grey.shade400, size: 50)
                        : null,
                  ),

                  // Speaker name
                  Text(
                    speaker['name'] ?? 'Unknown Speaker',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Country with flag
                  if (speaker['country'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _getCountryColor(speaker['country']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (speaker['flagUrl'] != null) ...[
                            Container(
                              width: 24,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(speaker['flagUrl']),
                                  fit: BoxFit.cover,
                                ),
                                border:
                                    Border.all(color: Colors.white, width: 0.5),
                              ),
                            ),
                          ],
                          Text(
                            speaker['country'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Speaker bio
                  if (speaker['bio'] != null &&
                      speaker['bio'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      speaker['bio'],
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No biography available for this speaker.',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Close button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCountryColor(String country) {
    switch (country.toUpperCase()) {
      case 'FRANCE':
        return Colors.blue;
      case 'TUNISIE':
        return Colors.grey.shade600;
      case 'ALGERIA':
        return Colors.green;
      case 'UK':
        return Colors.indigo;
      default:
        return Colors.blue.shade700;
    }
  }
} 