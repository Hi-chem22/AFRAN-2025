import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoDescription;

  const YouTubePlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoDescription,
  }) : super(key: key);

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    String? videoId = _extractVideoId(widget.videoUrl);
    
    if (videoId == null || videoId.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Impossible d\'extraire l\'ID de la vidéo YouTube.';
      });
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        captionLanguage: 'fr',
        interfaceLanguage: 'fr',
      ),
    );

    _controller.setFullScreenListener((isFullScreen) {
      // Handle fullscreen changes if needed
    });

    _controller.loadVideo(videoId).then((_) {
      setState(() {
        _isPlayerReady = true;
      });
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement de la vidéo: $error';
      });
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasError)
              _buildErrorWidget(context)
            else
              _buildYouTubePlayer(),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.videoTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.videoDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
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

  Widget _buildYouTubePlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: YoutubePlayerScaffold(
        controller: _controller,
        aspectRatio: 16 / 9,
        builder: (context, player) {
          return player;
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Une erreur s\'est produite lors de la lecture de la vidéo.',
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _launchYouTubeVideo(context, widget.videoUrl),
            icon: const Icon(Icons.play_arrow, color: Colors.red),
            label: const Text(
              'Ouvrir sur YouTube',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _extractVideoId(String url) {
    if (url.contains('youtube.com/watch')) {
      // Format: https://www.youtube.com/watch?v=VIDEO_ID
      final uri = Uri.parse(url);
      return uri.queryParameters['v'];
    } else if (url.contains('youtu.be/')) {
      // Format: https://youtu.be/VIDEO_ID
      final segments = Uri.parse(url).pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
    }
    return null;
  }

  Future<void> _launchYouTubeVideo(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // First try to launch in YouTube app
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
      
      // If all methods fail, show error
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir: $url')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
} 