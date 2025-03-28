import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Partner {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String websiteUrl;

  Partner({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.websiteUrl,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      websiteUrl: json['websiteUrl'] ?? json['url'] ?? '',
    );
  }
}

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  List<Partner> _partners = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/partners'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> partnersJson = json.decode(response.body);
        final List<Partner> partners = partnersJson
            .map((json) => Partner.fromJson(json))
            .toList();

        setState(() {
          _partners = partners;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load partners (${response.statusCode})';
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

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $e')),
      );
    }
  }

  void _showPartnerDetails(Partner partner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Logo
                  SizedBox(
                    height: 120,
                    child: partner.logoUrl.isNotEmpty
                        ? Image.network(
                            partner.logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey.shade300,
                              );
                            },
                          )
                        : Icon(
                            Icons.business,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name
                  Text(
                    partner.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  if (partner.description.isNotEmpty)
                    Text(
                      partner.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 32),
                  
                  // Website button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: partner.websiteUrl.isNotEmpty 
                          ? () => _launchUrl(partner.websiteUrl)
                          : null,
                      icon: const Icon(
                        Icons.language,
                        size: 18,
                      ),
                      label: const Text('Visiter le site'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(
                          color: Colors.teal.shade100,
                          width: 1,
                        ),
                        backgroundColor: Colors.teal.shade50.withOpacity(0.3),
                        foregroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, 
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 1,
                  color: Colors.blue.shade800,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Nos Partenaires',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 1,
                  color: Colors.blue.shade800,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _partners.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchPartners,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _partners.length,
                        itemBuilder: (context, index) {
                          return _buildPartnerCard(_partners[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
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
            onPressed: _fetchPartners,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No partners found'),
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showPartnerDetails(partner),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo with fixed height
              SizedBox(
                height: 80,
                child: Center(
                  child: partner.logoUrl.isNotEmpty
                      ? Image.network(
                          partner.logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey.shade300,
                            );
                          },
                        )
                      : Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.grey.shade300,
                        ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Name
              Text(
                partner.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              if (partner.description.isNotEmpty)
                Text(
                  partner.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 8),
              
              // Website button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: partner.websiteUrl.isNotEmpty 
                      ? () => _launchUrl(partner.websiteUrl)
                      : null,
                  icon: const Icon(
                    Icons.language,
                    size: 12,
                  ),
                  label: const Text(
                    'Visiter le site',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(
                      color: Colors.teal.shade100,
                      width: 1,
                    ),
                    backgroundColor: Colors.teal.shade50.withOpacity(0.3),
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, 
                      vertical: 2,
                    ),
                    disabledBackgroundColor: Colors.grey.shade100,
                    disabledForegroundColor: Colors.grey.shade400,
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