import 'dart:io';


import 'package:aroundu/designs/colors.designs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? fileName;

  const VideoPlayerPage({
    Key? key,
    required this.videoUrl,
    this.fileName,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late AnimationController _playPauseController;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isFullScreen = false; // Add this line to track orientation state

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _initializeVideo();
    _fadeController.forward();
    _hideControlsAfterDelay();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..play()
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _duration = _controller.value.duration;
        });
        _controller.addListener(_videoListener);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      });
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _position = _controller.value.position;
        _isPlaying = _controller.value.isPlaying;
        if (_isPlaying) {
          _playPauseController.forward();
        } else {
          _playPauseController.reverse();
        }
      });
    }
  }

  void _toggleOrientation() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  void dispose() {
    // Reset orientation when widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _fadeController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    // Add this to handle responsive sizing based on orientation
    final isLandscape = _isFullScreen || MediaQuery.of(context).orientation == Orientation.landscape;

    // Define size multipliers for landscape mode
    final iconSizeMultiplier = isLandscape ? 0.8 : 1.0;
    final textSizeMultiplier = isLandscape ? 0.5 : 1.0;
    final paddingMultiplier = isLandscape ? 0.6 : 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            leading: Container(
              // margin: EdgeInsets.all((8 * paddingMultiplier)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: DesignColors.white, size: 24 * iconSizeMultiplier),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              widget.fileName ?? '',
              style: TextStyle(
                color: DesignColors.white,
                fontSize: (16 * textSizeMultiplier),
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              Container(
                // margin: EdgeInsets.all((8 * paddingMultiplier)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: DesignColors.white, size: 24 * iconSizeMultiplier),
                  onPressed: () => _showVideoOptions(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeController,
          child: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Video Player
                Center(
                  child: _buildVideoContent(),
                ),

                // Play/Pause Overlay
                // Update the play/pause overlay
                if (!_showControls && !_isLoading && !_hasError)
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: AnimatedBuilder(
                        animation: _playPauseController,
                        builder: (context, child) {
                          return AnimatedOpacity(
                            opacity: _isPlaying ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: EdgeInsets.all((20 * paddingMultiplier)),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: DesignColors.accent.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: DesignColors.white,
                                size: (40 * iconSizeMultiplier + ((isLandscape ? 48 : 0))),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Bottom Controls
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: _showControls ? 0 : -150,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all((20 * paddingMultiplier)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Bar
                          Row(
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: TextStyle(
                                  color: DesignColors.white,
                                  fontSize: (12 * textSizeMultiplier),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: (12 * paddingMultiplier)),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: DesignColors.accent,
                                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                                    thumbColor: DesignColors.accent,
                                    overlayColor: DesignColors.accent.withOpacity(0.3),
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: (6 * paddingMultiplier),
                                    ),
                                    trackHeight: (3 * paddingMultiplier),
                                  ),
                                  child: Slider(
                                    value: _duration.inMilliseconds > 0 ? _position.inMilliseconds.toDouble() : 0.0,
                                    max: _duration.inMilliseconds.toDouble(),
                                    onChanged: (value) {
                                      _seekTo(Duration(milliseconds: value.toInt()));
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: (12 * paddingMultiplier)),
                              Text(
                                _formatDuration(_duration),
                                style: TextStyle(
                                  color: DesignColors.white,
                                  fontSize: (12 * textSizeMultiplier),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.replay_10_rounded,
                                onTap: () {
                                  final newPosition = _position - const Duration(seconds: 10);
                                  _seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
                                },
                              ),
                              _buildPlayPauseButton(),
                              _buildControlButton(
                                icon: Icons.forward_10_rounded,
                                onTap: () {
                                  final newPosition = _position + const Duration(seconds: 10);
                                  _seekTo(newPosition < _duration ? newPosition : _duration);
                                },
                              ),
                              _buildControlButton(
                                icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                onTap: _toggleOrientation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DesignColors.accent),
            ),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: DesignColors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: DesignColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initializeVideo();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: DesignColors.white),
              ),
            ),
          ],
        ),
      );
    }

    Widget videoPlayer = VideoPlayer(_controller);

    if (_isFullScreen) {
      // In horizontal mode (landscape), use the device width and maintain aspect ratio
      return OrientationBuilder(
        builder: (context, orientation) {
          // Force landscape orientation
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: videoPlayer,
              ),
            ),
          );
        },
      );
    } else {
      // In vertical mode (portrait), use AspectRatio
      // Reset to portrait orientation
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: videoPlayer,
      );
    }
  }

  Widget _buildPlayPauseButton() {
    // Add this to handle responsive sizing based on orientation
    final isLandscape = _isFullScreen || MediaQuery.of(context).orientation == Orientation.landscape;
    final iconSizeMultiplier = isLandscape ? 0.8 : 1.0;
    final paddingMultiplier = isLandscape ? 0.8 : 1.0;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        padding: EdgeInsets.all((16 * paddingMultiplier)),
        decoration: BoxDecoration(
          color: DesignColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DesignColors.accent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _playPauseController,
          builder: (context, child) {
            return Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: DesignColors.white,
              size: (32 * iconSizeMultiplier),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Add this to handle responsive sizing based on orientation
    final isLandscape = _isFullScreen || MediaQuery.of(context).orientation == Orientation.landscape;
    final iconSizeMultiplier = isLandscape ? 0.8 : 1.0;
    final paddingMultiplier = isLandscape ? 0.8 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all((12 * paddingMultiplier)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: DesignColors.accent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: DesignColors.white,
          size: (24 * iconSizeMultiplier + ((isLandscape ? 32 : 0))),
        ),
      ),
    );
  }

  void _showVideoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Video Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.accent,
                  ),
                ),
                SizedBox(height: 20),
                _buildOptionTile(
                  icon: Icons.download_rounded,
                  title: 'Download Video',
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => VideoDownloadDialog(
                        videoUrl: widget.videoUrl,
                        videoTitle: widget.fileName ?? "", // Add this if you have video title
                      ),
                    );
                  },
                ),
                // _buildOptionTile(
                //   icon: Icons.share_rounded,
                //   title: 'Share Video',
                //   onTap: () {
                //     Navigator.pop(context);
                //     // Add share logic
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle video download functionality

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DesignColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: DesignColors.accent),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}




class VideoDownloadManager {
  static final VideoDownloadManager _instance = VideoDownloadManager._internal();
  factory VideoDownloadManager() => _instance;
  VideoDownloadManager._internal();

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, ValueNotifier<DownloadState>> _downloadStates = {};

  Future<void> downloadVideo(String url, String fileName) async {
    final cancelToken = CancelToken();
    _cancelTokens[url] = cancelToken;
    
    final stateNotifier = ValueNotifier(DownloadState(
      status: DownloadStatus.downloading,
      progress: 0.0,
      fileName: fileName,
    ));
    _downloadStates[url] = stateNotifier;

    try {
      // Request permissions with a simpler approach
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        // Try different permission strategies
        // First try the modern approach for newer Android versions
        var storagePermission = await Permission.storage.request();
        var manageStoragePermission = await Permission.manageExternalStorage.request();
        
        // Check if we have any of the required permissions
        hasPermission = storagePermission.isGranted || 
                       manageStoragePermission.isGranted ||
                       await Permission.storage.isGranted ||
                       await Permission.manageExternalStorage.isGranted;
        
        // For newer Android versions, also try media permissions
        if (!hasPermission) {
          var photosPermission = await Permission.photos.request();
          var videosPermission = await Permission.videos.request();
          hasPermission = photosPermission.isGranted && videosPermission.isGranted;
        }
      } else {
        // For iOS and other platforms
        hasPermission = await Permission.storage.request().isGranted;
      }

      if (!hasPermission) {
        stateNotifier.value = DownloadState(
          status: DownloadStatus.error,
          progress: 0.0,
          fileName: fileName,
          error: 'Storage permission is required to download videos. Please grant permission in app settings.',
        );
        return;
      }

      // Get download directory
      Directory? directory;
      String downloadPath;
      
      if (Platform.isAndroid) {
        // Try to use Downloads directory first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app's external storage
          directory = await getExternalStorageDirectory();
          downloadPath = '${directory!.path}/Downloads';
        } else {
          downloadPath = directory.path;
        }
      } else {
        // For iOS and other platforms
        directory = await getApplicationDocumentsDirectory();
        downloadPath = '${directory.path}/Downloads';
      }
      
      await Directory(downloadPath).create(recursive: true);
      final filePath = '$downloadPath/$fileName';

      final dio = Dio();
      
      await dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            stateNotifier.value = DownloadState(
              status: DownloadStatus.downloading,
              progress: progress,
              fileName: fileName,
            );
          }
        },
      );

      stateNotifier.value = DownloadState(
        status: DownloadStatus.completed,
        progress: 1.0,
        fileName: fileName,
        filePath: filePath,
      );

    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        stateNotifier.value = DownloadState(
          status: DownloadStatus.cancelled,
          progress: 0.0,
          fileName: fileName,
        );
      } else {
        stateNotifier.value = DownloadState(
          status: DownloadStatus.error,
          progress: 0.0,
          fileName: fileName,
          error: e.toString(),
        );
      }
    } finally {
      _cancelTokens.remove(url);
    }
  }

  void cancelDownload(String url) {
    _cancelTokens[url]?.cancel('Download cancelled by user');
  }

  ValueNotifier<DownloadState>? getDownloadState(String url) {
    return _downloadStates[url];
  }

  void removeDownloadState(String url) {
    _downloadStates[url]?.dispose();
    _downloadStates.remove(url);
  }
}

enum DownloadStatus {
  downloading,
  completed,
  error,
  cancelled,
}

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final String fileName;
  final String? filePath;
  final String? error;

  DownloadState({
    required this.status,
    required this.progress,
    required this.fileName,
    this.filePath,
    this.error,
  });
}

class VideoDownloadDialog extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;

  const VideoDownloadDialog({
    Key? key,
    required this.videoUrl,
    this.videoTitle,
  }) : super(key: key);

  @override
  State<VideoDownloadDialog> createState() => _VideoDownloadDialogState();
}

class _VideoDownloadDialogState extends State<VideoDownloadDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  ValueNotifier<DownloadState>? _downloadStateNotifier;
  final _downloadManager = VideoDownloadManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _generateFileName() {
    final title = widget.videoTitle ?? 'video';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}_$timestamp.mp4';
  }

  void _startDownload() {
    final fileName = _generateFileName();
    _downloadStateNotifier = _downloadManager.getDownloadState(widget.videoUrl);
    
    if (_downloadStateNotifier == null) {
      _downloadManager.downloadVideo(widget.videoUrl, fileName);
      _downloadStateNotifier = _downloadManager.getDownloadState(widget.videoUrl);
    }
    
    setState(() {});
  }

  void _cancelDownload() {
    _downloadManager.cancelDownload(widget.videoUrl);
  }

  void _closeDialog() {
    if (_downloadStateNotifier?.value.status == DownloadStatus.downloading) {
      _downloadManager.cancelDownload(widget.videoUrl);
    }
    _downloadManager.removeDownloadState(widget.videoUrl);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesignColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: DesignColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download Video',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.videoTitle ?? 'Video will be saved to Downloads',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Download State Content
              if (_downloadStateNotifier == null)
                _buildInitialState()
              else
                ValueListenableBuilder<DownloadState>(
                  valueListenable: _downloadStateNotifier!,
                  builder: (context, state, child) {
                    switch (state.status) {
                      case DownloadStatus.downloading:
                        return _buildDownloadingState(state);
                      case DownloadStatus.completed:
                        return _buildCompletedState(state);
                      case DownloadStatus.error:
                        return _buildErrorState(state);
                      case DownloadStatus.cancelled:
                        return _buildCancelledState();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Start Download',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _closeDialog,
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildDownloadingState(DownloadState state) {
    return Column(
      children: [
        // Progress Circle
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 6,
                backgroundColor: DesignColors.accent.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignColors.accent,
                ),
              ),
            ),
            Text(
              '${(state.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Downloading...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          state.fileName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 24),
        
        // Cancel Button
        Container(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _cancelDownload,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, size: 18),
                const SizedBox(width: 8),
                Text('Cancel Download'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(DownloadState state) {
    return Column(
      children: [
        // Success Animation
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Download Complete!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Video saved successfully',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Open file location or file
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('File saved to Downloads folder'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Open'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(DownloadState state) {
    return Column(
      children: [
        // Error Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Download Failed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          state.error ?? 'An error occurred during download',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _downloadStateNotifier = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Retry'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelledState() {
    return Column(
      children: [
        // Cancelled Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel_outlined,
            color: Theme.of(context).colorScheme.outline,
            size: 48,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Download Cancelled',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'The download was cancelled by user',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _downloadStateNotifier = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
