import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'video_player_screen.dart';
import 'youtube_player_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class SubsessionText {
  final String title;
  final String startTime;
  final String endTime;
  final String duration;
  final List<String> speakerIds;
  final String description;

  SubsessionText({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.speakerIds,
    required this.description,
  });

  factory SubsessionText.fromJson(Map<String, dynamic> json) {
    List<String> speakerIds = [];
    if (json['speakerIds'] != null) {
      speakerIds = List<String>.from(json['speakerIds']);
    }

    return SubsessionText(
      title: json['title'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? '',
      speakerIds: speakerIds,
      description: json['description'] ?? '',
    );
  }
}

class SessionInfo {
  final String id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String duration;
  final String room;
  final String description;
  // New fields for the updated format
  final String chairpersons;
  final List<SubsessionText> subsessionTexts;
  // Keep these for backward compatibility
  final List<Chairperson> chairpersonRefs;
  final List<Speaker> speakers;

  SessionInfo({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.room,
    required this.description,
    required this.chairpersons,
    required this.subsessionTexts,
    required this.chairpersonRefs,
    required this.speakers,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    // Handle chairpersonRefs (for backward compatibility)
    List<Chairperson> chairpersonRefs = [];
    if (json['chairpersonRefs'] != null) {
      chairpersonRefs = List<Chairperson>.from(
        (json['chairpersonRefs'] as List).map((x) => Chairperson.fromJson(x))
      );
    }

    // Handle speakers (for backward compatibility)
    List<Speaker> speakers = [];
    if (json['speakers'] != null) {
      speakers = List<Speaker>.from(
        (json['speakers'] as List).map((x) => Speaker.fromJson(x))
      );
    }

    // Handle subsessionTexts (new field)
    List<SubsessionText> subsessionTexts = [];
    if (json['subsessionTexts'] != null) {
      subsessionTexts = List<SubsessionText>.from(
        (json['subsessionTexts'] as List).map((x) => SubsessionText.fromJson(x))
      );
    }

    return SessionInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: json['duration'] ?? '',
      room: json['room'] ?? '',
      description: json['description'] ?? '',
      chairpersons: json['chairpersons'] ?? '',
      subsessionTexts: subsessionTexts,
      chairpersonRefs: chairpersonRefs,
      speakers: speakers,
    );
  }
}

class Chairperson {
  final String id;
  final String name;
  final String title;
  final String institution;

  Chairperson({
    required this.id,
    required this.name,
    required this.title,
    required this.institution,
  });

  factory Chairperson.fromJson(Map<String, dynamic> json) {
    return Chairperson(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      institution: json['institution'] ?? '',
    );
  }
}

class Speaker {
  final String id;
  final String name;
  final String country;
  final String bio;

  Speaker({
    required this.id,
    required this.name,
    required this.country,
    required this.bio,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      bio: json['bio'] ?? '',
    );
  }
}

class Video {
  final String id;
  final String title;
  final String description;
  final String url;
  final String thumbnailUrl;
  final String category;
  final String duration;
  final String speaker;
  final String date;
  final bool featured;
  final SessionInfo? session;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnailUrl,
    required this.category,
    required this.duration,
    required this.speaker,
    required this.date,
    required this.featured,
    this.session,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      speaker: json['speaker'] ?? '',
      date: json['date'] ?? '',
      featured: json['featured'] ?? false,
      session: json['sessionId'] != null
          ? SessionInfo.fromJson(json['sessionId'])
          : null,
    );
  }
}

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<List<Video>> _videosFuture;
  String _selectedCategory = 'Tous';
  List<String> _categories = ['Tous'];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _videosFuture = _fetchVideos();
  }

  Future<List<Video>> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/videos'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = json.decode(response.body);
        final List<Video> allVideos = videosJson.map((json) => Video.fromJson(json)).toList();
        
        // Extract unique categories
        final Set<String> categoriesSet = {'Tous'};
        for (var video in allVideos) {
          if (video.category.isNotEmpty) {
            categoriesSet.add(video.category);
          }
        }
        
        setState(() {
          _categories = categoriesSet.toList();
          _isLoading = false;
        });
        
        return allVideos;
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading videos: ${e.toString()}';
      });
      return [];
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getColorForVideo(Video video) {
    String seed = video.category.isNotEmpty ? video.category : video.id;
    int hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = seed.codeUnitAt(i) + ((hash << 5) - hash);
    }
    String color = '2e5f75';
    if (seed.isNotEmpty) {
      final List<String> colors = [
        '2e5f75',
        '3a7d95',
        '1d4655',
        '5a8fa2',
        '386a7a',
      ];
      color = colors[hash.abs() % colors.length];
    }
    return color;
  }

  Widget _buildThumbnailFallback(Video video) {
    final color = Color(int.parse('0xFF${_getColorForVideo(video)}'));
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              size: 50,
              color: Colors.white70,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                video.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
      
      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    selectedColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(isSelected ? 0 : 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _videosFuture = _fetchVideos();
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : FutureBuilder<List<Video>>(
                        future: _videosFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _videosFuture = _fetchVideos();
                                      });
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.filter_alt,
                                      size: 64,
                                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No videos in category "$_selectedCategory"',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = 'Tous';
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Show all videos'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final List<Video> videos = snapshot.data!;
                            final List<Video> filteredVideos = _selectedCategory == 'Tous'
                                ? videos
                                : videos.where((video) => video.category == _selectedCategory).toList();
                            
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  _videosFuture = _fetchVideos();
                                });
                                await _videosFuture;
                                return;
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredVideos.length,
                                itemBuilder: (context, index) {
                                  final video = filteredVideos[index];
                                  String formattedDate = '';
                                  if (video.session != null && video.session!.date.isNotEmpty) {
                                    try {
                                      final date = DateTime.parse(video.session!.date);
                                      formattedDate = DateFormat('dd MMM yyyy').format(date);
                                    } catch (e) {
                                      formattedDate = 'Date not available';
                                    }
                                  } else if (video.date.isNotEmpty) {
                                    try {
                                      final date = DateTime.parse(video.date);
                                      formattedDate = DateFormat('dd MMM yyyy').format(date);
                                    } catch (e) {
                                      formattedDate = 'Date not available';
                                    }
                                  }

                                  final displayTitle = video.session != null && video.session!.title.isNotEmpty
                                      ? video.session!.title
                                      : video.title;

                                  String thumbnailUrl = video.thumbnailUrl;
                                  if (thumbnailUrl.isNotEmpty && thumbnailUrl.startsWith('/uploads/')) {
                                    thumbnailUrl = 'http://localhost:8080${thumbnailUrl}';
                                  }

                                  return _VideoCard(
                                    video: video,
                                    displayTitle: displayTitle,
                                    thumbnailUrl: thumbnailUrl,
                                    formattedDate: formattedDate,
                                    launchUrlCallback: _launchUrl,
                                    buildThumbnailFallback: _buildThumbnailFallback,
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
          ),
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
    );
  }
}

// Nouvelle classe pour gérer l'état interne de la carte vidéo
class _VideoCard extends StatefulWidget {
  final Video video;
  final String displayTitle;
  final String thumbnailUrl;
  final String formattedDate;
  final Function(String) launchUrlCallback;
  final Widget Function(Video) buildThumbnailFallback;

  const _VideoCard({
    required this.video,
    required this.displayTitle,
    required this.thumbnailUrl,
    required this.formattedDate,
    required this.launchUrlCallback,
    required this.buildThumbnailFallback,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool isPlaying = false;
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  bool isInitializing = false;

  @override
  void dispose() {
    _cleanupControllers();
    super.dispose();
  }

  void _cleanupControllers() {
    chewieController?.dispose();
    videoController?.dispose();
    videoController = null;
    chewieController = null;
  }

  void playVideo() {
    String videoUrl = widget.video.url;
    
    // Si l'URL est un chemin relatif du backend, construire l'URL complète
    if (videoUrl.startsWith('/uploads/')) {
      videoUrl = 'http://localhost:8080${videoUrl}';
    }
    
    // Vérifier s'il s'agit d'une vidéo YouTube
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      widget.launchUrlCallback(videoUrl);
      return;
    }
    
    setState(() {
      if (isPlaying) {
        _cleanupControllers();
        isPlaying = false;
      } else {
        isInitializing = true;
        _initializeVideo(videoUrl);
      }
    });
  }
  
  Future<void> _initializeVideo(String url) async {
    try {
      videoController = VideoPlayerController.network(url);
      
      await videoController!.initialize();
      
      if (mounted) {
        setState(() {
          chewieController = ChewieController(
            videoPlayerController: videoController!,
            autoPlay: true,
            looping: false,
            aspectRatio: videoController!.value.aspectRatio,
            allowFullScreen: true,
            allowMuting: true,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(
                  'Erreur: $errorMessage',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
          isInitializing = false;
          isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
      setState(() {
          isInitializing = false;
          isPlaying = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de lecture: ${e.toString()}')),
          );
        });
      }
    }
  }

  // Build the people list (chair + speakers)
  Widget _buildSessionPeople(SessionInfo? sessionInfo) {
    // If there's no session info, return an empty widget
    if (sessionInfo == null) {
      return const SizedBox.shrink();
    }

    // If there are no chairpersons or subsessions, return an empty widget
    if ((sessionInfo.chairpersons == null || sessionInfo.chairpersons!.isEmpty) &&
        sessionInfo.subsessionTexts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Define title styles
    const titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14.0,
    );
    
    // Define content styles
    const contentStyle = TextStyle(
      fontSize: 13.0,
    );

    // Build chairpersons section
    Widget chairpersonsSection = const SizedBox.shrink();
    if (sessionInfo.chairpersons != null && sessionInfo.chairpersons!.isNotEmpty) {
      chairpersonsSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chairpersons:', style: titleStyle),
          Text(sessionInfo.chairpersons!, style: contentStyle),
          const SizedBox(height: 8),
        ],
      );
    }

    // Build subsessions section
    Widget subsessionsSection = const SizedBox.shrink();
    if (sessionInfo.subsessionTexts.isNotEmpty) {
      List<Widget> subsessionWidgets = [];
      
      for (var subsession in sessionInfo.subsessionTexts) {
        subsessionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              subsession.title,
              style: contentStyle,
            ),
          ),
        );
      }
      
      subsessionsSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subsessions:', style: titleStyle),
          ...subsessionWidgets,
        ],
      );
    }

    // Return the complete widget with both sections
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sessionInfo.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8),
          chairpersonsSection,
          subsessionsSection,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title at top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced padding
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.displayTitle,
                    style: TextStyle(
                      fontSize: 16, // Smaller text
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 2, // Reduced max lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Session chairpersons and speakers
                _buildSessionPeople(widget.video.session),
                
                // Video player or thumbnail
                isInitializing
                  ? const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : isPlaying && chewieController != null
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Chewie(controller: chewieController!),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                  color: Colors.grey[300],
                              child: widget.thumbnailUrl.isNotEmpty
                    ? Image.network(
                                    widget.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                                      return widget.buildThumbnailFallback(widget.video);
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                          color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      )
                                : widget.buildThumbnailFallback(widget.video),
                            ),
                          ),
                          
                          // Play button in center
                          InkWell(
                            onTap: playVideo,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(10), // Smaller padding
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 48, // Smaller icon
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          // Duration badge
                          if (widget.video.duration.isNotEmpty)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4), // Smaller radius
                                ),
                                child: Text(
                                  widget.video.duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12, // Smaller text
                                    fontWeight: FontWeight.w500,
                        ),
                      ),
                ),
                ),
              ],
                ),
                
                // Description and metadata at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.video.description.isNotEmpty) ...[
                  Text(
                          widget.video.description,
                          maxLines: 2, // Reduced max lines
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12, // Smaller text
                          ),
                        ),
                        const SizedBox(height: 8), // Reduced spacing
                      ],
                      
                      // Date and metadata row
                      Row(
                        children: [
                          if (widget.formattedDate.isNotEmpty) ...[
                            Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor), // Smaller icon
                            const SizedBox(width: 4), // Reduced spacing
                            Text(
                              widget.formattedDate,
                              style: const TextStyle(
                                fontSize: 12, // Smaller text
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                          ],
                          
                          // Speaker pill
                          if (widget.video.speaker.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reduced padding
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 12, color: Theme.of(context).primaryColor), // Smaller icon
                                  const SizedBox(width: 2), // Reduced spacing
                                  Text(
                                    widget.video.speaker,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 10, // Smaller text
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      if (widget.video.session != null && widget.video.session!.room.isNotEmpty) ...[
                        const SizedBox(height: 4), // Reduced spacing
                        Row(
                          children: [
                            Icon(Icons.meeting_room, size: 12, color: Theme.of(context).primaryColor), // Smaller icon
                            const SizedBox(width: 4), // Reduced spacing
                            Text(
                              widget.video.session!.room,
                              style: const TextStyle(
                                fontSize: 12, // Smaller text
                          ),
                        ),
                      ],
                    ),
                  ],
                      
                      // Show session duration if available
                      if (widget.video.session != null && widget.video.session!.duration.isNotEmpty) ...[
                        const SizedBox(height: 4), // Reduced spacing
                    Row(
                      children: [
                            Icon(Icons.access_time, size: 12, color: Theme.of(context).primaryColor), // Smaller icon
                            const SizedBox(width: 4), // Reduced spacing
                            Text(
                              "Duration: ${widget.video.session!.duration}",
                              style: const TextStyle(
                                fontSize: 12, // Smaller text
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
    );
  }
} 