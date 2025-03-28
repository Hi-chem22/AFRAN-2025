import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  String _getDirectVideoUrl(String url) {
    if (url.contains('drive.google.com')) {
      String? fileId;
      if (url.contains('/d/')) {
        fileId = url.split('/d/')[1].split('/')[0];
      } else if (url.contains('id=')) {
        fileId = url.split('id=')[1].split('&')[0];
      }
      
      if (fileId != null) {
        // Use a different approach for Google Drive videos
        return 'https://www.googleapis.com/drive/v3/files/$fileId?alt=media';
      }
    }
    return url;
  }

  Future<void> _initializePlayer() async {
    try {
      // Initialize video controller with Cloudinary URL
      _videoPlayerController = VideoPlayerController.network(
        widget.videoUrl,
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      // Initialize with timeout
      await _videoPlayerController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: widget.showControls,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Error playing video: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _initializePlayer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isInitialized = true;
        _isError = false;
        _errorMessage = '';
      });
    } catch (error) {
      print('Error in video player: $error');
      if (!mounted) return;
      setState(() {
        _isInitialized = false;
        _isError = true;
        _errorMessage = 'Error loading video: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isInitialized && _chewieController != null
          ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
} 