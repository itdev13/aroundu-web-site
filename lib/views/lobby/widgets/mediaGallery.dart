import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Media source abstraction
class MediaSource {
  final String? url;
  final File? file;

  MediaSource.fromUrl(this.url) : file = null;
  MediaSource.fromFile(this.file) : url = null;

  bool get isVideo {
    final path = url ?? file?.path;
    return path?.endsWith('.mp4') == true || path?.endsWith('.mov') == true;
  }

  bool get isNetworkSource => url != null;
}

class MediaGallery extends StatelessWidget {
  MediaGallery({super.key, required this.mediaSources});

  final List<MediaSource> mediaSources;

  MediaGallery.fromUrls(List<String> urls, {super.key})
      : mediaSources = urls.map((url) => MediaSource.fromUrl(url)).toList();

  MediaGallery.fromFiles(List<File> files, {super.key})
      : mediaSources = files.map((file) => MediaSource.fromFile(file)).toList();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return GestureDetector(
      onTap: () {
        Get.to(() => SwipeMediaScreen(mediaSources: mediaSources));
      },
      child: PageView.builder(
        itemCount: mediaSources.length,
        itemBuilder: (context, index) {
          return buildMediaWidget(mediaSources[index], height: sh(0.3));
        },
      ),
    );
  }

  Widget buildMediaWidget(MediaSource source, {double? height, double? width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: height,
        width: width,
        color: Colors.grey[300],
        child: source.isVideo
            ? FutureBuilder<String?>(
                future: _generateVideoThumbnail(
                    source.isNetworkSource ? source.url! : source.file!.path),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Icon(Icons.error, color: Colors.red));
                  } else {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    );
                  }
                },
              )
            : source.isNetworkSource
                ? Image.network(
                    source.url!,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    source.file!,
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }

  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        timeMs: 2000, // Generate thumbnail at 2 seconds
        quality: 75,
      );

      return thumbnailPath;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
}

// Rest of the classes remain the same...
class SwipeMediaScreen extends StatefulWidget {
  final List<MediaSource> mediaSources;
  final int initialIndex;

  SwipeMediaScreen({required this.mediaSources, this.initialIndex = 0});

  @override
  _SwipeMediaScreenState createState() => _SwipeMediaScreenState();
}

class _SwipeMediaScreenState extends State<SwipeMediaScreen> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
      msg: 'Swipe to see more media',
      fontSize: 18,
      backgroundColor: Colors.white12,
    );
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaSources.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final source = widget.mediaSources[index];
          return source.isVideo
              ? VideoPlayerScreen(source: source)
              : FullScreenImagePreview(source: source);
        },
      ),
    );
  }
}

class FullScreenImagePreview extends StatelessWidget {
  final MediaSource source;

  FullScreenImagePreview({required this.source});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: source.isNetworkSource
          ? Image.network(
              source.url!,
              fit: BoxFit.contain,
            )
          : Image.file(
              source.file!,
              fit: BoxFit.contain,
            ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final MediaSource source;

  VideoPlayerScreen({required this.source});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.source.isNetworkSource
        ? VideoPlayerController.networkUrl(Uri.parse(widget.source.url!))
        : VideoPlayerController.file(widget.source.file!)
      ..initialize().then((_) {
        setState(() {});
        _controller.setVolume(1.0);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      if (_isMuted) {
        _controller.setVolume(1.0);
      } else {
        _controller.setVolume(0.0);
      }
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ),
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
