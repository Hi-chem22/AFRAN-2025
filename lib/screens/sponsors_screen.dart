import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SponsorsScreen extends StatefulWidget {
  const SponsorsScreen({super.key});

  @override
  State<SponsorsScreen> createState() => _SponsorsScreenState();
}

class _SponsorsScreenState extends State<SponsorsScreen> {
  List<dynamic> _sponsors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSponsors();
  }

  Future<void> _fetchSponsors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/sponsors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> sponsors = json.decode(response.body);
        setState(() {
          _sponsors = sponsors;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des sponsors (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, List<dynamic>> _groupSponsorsByRank() {
    final Map<String, List<dynamic>> grouped = {
      'Platinum': [],
      'Diamond': [],
      'Gold': [],
      'Silver': [],
      'Bronze': [],
    };

    for (var sponsor in _sponsors) {
      final rank = sponsor['rank'] ?? 'Bronze';
      if (grouped.containsKey(rank)) {
        grouped[rank]!.add(sponsor);
      }
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  Widget _buildRankSection(String rank, List<dynamic> sponsors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rank header with icon
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _buildRankIcon(rank),
              const SizedBox(width: 8),
              Text(
                rank,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(rank),
                ),
              ),
            ],
          ),
        ),
        // Sponsors grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: sponsors.length,
          itemBuilder: (context, index) {
            final sponsor = sponsors[index];
            return _buildSponsorCard(sponsor);
          },
        ),
      ],
    );
  }

  Widget _buildSponsorCard(dynamic sponsor) {
    final String name = sponsor['name'] ?? 'Sponsor sans nom';
    final String rank = sponsor['rank'] ?? 'Bronze';
    final String imageUrl = sponsor['imageUrl'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sponsor logo
              Expanded(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: 32,
                            color: _getRankColor(rank).withOpacity(0.5),
                          );
                        },
                      )
                    : Icon(
                        Icons.business,
                        size: 32,
                        color: _getRankColor(rank).withOpacity(0.5),
                      ),
              ),
              const SizedBox(height: 4),
              // Sponsor name
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankIcon(String rank) {
    IconData iconData;
    double size = 20;

    switch (rank.toLowerCase()) {
      case 'platinum':
        iconData = Icons.workspace_premium;
        break;
      case 'diamond':
        iconData = Icons.diamond;
        break;
      case 'gold':
        iconData = Icons.star;
        break;
      case 'silver':
        iconData = Icons.trending_up;
        break;
      case 'bronze':
        iconData = Icons.verified;
        break;
      default:
        iconData = Icons.shield;
    }

    return Icon(
      iconData,
      color: _getRankColor(rank),
      size: size,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun sponsor disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les sponsors seront affichés ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSponsors,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _error!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSponsors,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
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
                'Our Sponsors',
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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? _buildErrorState()
            : _sponsors.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _fetchSponsors,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        ..._groupSponsorsByRank().entries.map((entry) {
                          return _buildRankSection(entry.key, entry.value);
                        }).toList(),
                        // Signature with fixed height
                        SizedBox(
                          height: 48,
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),
    );
  }
} 