import 'dart:io';

import 'package:aroundu/designs/colors.designs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageViewerPage extends StatefulWidget {
  final String imageUrl;
  final String? fileName;

  const ImageViewerPage({
    Key? key,
    required this.imageUrl,
    this.fileName,
  }) : super(key: key);

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  bool _hasError = false;
  // bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    // _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // void _hideControlsAfterDelay() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (mounted) {
  //       setState(() {
  //         _showControls = false;
  //       });
  //     }
  //   });
  // }

  // void _toggleControls() {
  //   setState(() {
  //     _showControls = !_showControls;
  //   });
  //   if (_showControls) {
  //     _hideControlsAfterDelay();
  //   }
  // }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _downloadImage() {
    // Implement your download logic here
    _showDownloadDialog();
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Download Image',
          style: TextStyle(
            color: DesignColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Would you like to download this image to your device?',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your actual download logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Download started...'),
                  backgroundColor: DesignColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Download',
              style: TextStyle(color: DesignColors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedOpacity(
          opacity:
              // _showControls ? 1.0 :
              1.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: DesignColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Text(
              widget.fileName ?? '',
              style: TextStyle(
                color: DesignColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            // actions: [
            //   Container(
            //     margin: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withOpacity(0.6),
            //       shape: BoxShape.circle,
            //     ),
            //     child: IconButton(
            //       icon: Icon(Icons.download_rounded, color: DesignColors.white),
            //       onPressed: _downloadImage,
            //     ),
            //   ),
            // ],
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: Stack(
            children: [
              // Main Image
              Center(
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  constrained: true,
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.imageUrl,
                    height: Get.height * 1,
                    width: Get.width *1,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        _isLoading = false;
                        return child;
                      }
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignColors.accent,
                              ),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: DesignColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      _hasError = true;
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
                                Icons.broken_image_rounded,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
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
                    },
                  ),
                ),
              ),

              // Bottom Controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom:
                    // _showControls ? 20.h :
                    20,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: DesignColors.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.refresh_rounded,
                        label: 'Reset',
                        onTap: _resetZoom,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[600],
                      ),
                      _buildControlButton(
                        icon: Icons.download_rounded,
                        label: 'Download',
                        onTap: _downloadImage,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey[600],
                      ),
                      _buildControlButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onTap: () async {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            final response = await http.get(Uri.parse(widget.imageUrl));

                            // Hide loading indicator
                            Navigator.of(context).pop();

                            if (response.statusCode == 200) {
                              final directory = await getTemporaryDirectory();
                              final fileName = 'shared_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final file = File('${directory.path}/$fileName');

                              await file.writeAsBytes(response.bodyBytes);
                              await Share.shareXFiles([XFile(file.path, name: 'shared_image.jpg')]);
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to download image')),
                              );
                            }
                          } catch (e) {
                            // Hide loading indicator if still showing
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error sharing image: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: DesignColors.white,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: DesignColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
