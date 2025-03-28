import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'youtube_player_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String videoDescription;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoTitle,
    required this.videoDescription,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  String _getDirectVideoUrl(String url) {
    if (url.contains('drive.google.com')) {
      // Extract file ID from Google Drive URL
      String? fileId;
      if (url.contains('/d/')) {
        fileId = url.split('/d/')[1].split('/')[0];
      } else if (url.contains('id=')) {
        fileId = url.split('id=')[1].split('&')[0];
      }
      
      if (fileId != null) {
        // Convert to direct download URL
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }
    return url;
  }

  Future<void> _initializePlayer() async {
    String videoUrl = _getDirectVideoUrl(widget.videoUrl);
    
    // Check if it's a YouTube URL and launch it externally instead
    bool isYouTubeUrl = videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');
    
    if (isYouTubeUrl) {
      // Use external launcher for YouTube URLs
      if (mounted) {
        try {
          final Uri uri = Uri.parse(videoUrl);
          
          // First try to launch in external application (browser or YouTube app)
          bool launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          // If external launch fails, try platformDefault
          if (!launched) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
          }
          
          // If all methods fail, show error
          if (!launched && mounted) {
            setState(() {
              _isError = true;
              _isLoading = false;
              _errorMessage = 'Could not open: $videoUrl';
            });
          } else {
            // Close this screen after successful launch
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        } catch (e) {
          setState(() {
            _isError = true;
            _isLoading = false;
            _errorMessage = 'Error opening video: ${e.toString()}';
          });
        }
      }
      return;
    }
    
    // Check if video URL is valid
    if (!videoUrl.startsWith('http') && !videoUrl.startsWith('/uploads/')) {
      setState(() {
        _isError = true;
        _isLoading = false;
        _errorMessage = 'Invalid video URL. Please check the link.';
      });
      return;
    }
    
    try {
      _videoPlayerController = VideoPlayerController.network(videoUrl);
      
      final playFuture = _videoPlayerController!.initialize();
      
      // Add a timeout to handle videos that may not load
      await playFuture.timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Video is taking too long to load.');
      });
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error playing video: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _initializePlayer(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
        _errorMessage = 'Error loading video: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.videoTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
          else if (_isError)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (widget.videoUrl.contains('youtube.com') || widget.videoUrl.contains('youtu.be'))
                        ElevatedButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse(widget.videoUrl);
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not open: ${widget.videoUrl}')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Open on YouTube'),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _initializePlayer(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _chewieController!.aspectRatio ?? 16 / 9,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            ),
          
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.videoTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.videoDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.videoDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
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
} 