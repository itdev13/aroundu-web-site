
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String? fileName;

  const PDFViewerPage({
    Key? key,
    required this.pdfUrl,
    this.fileName,
  }) : super(key: key);

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> with TickerProviderStateMixin {
  late PDFViewController _pdfController;
  late AnimationController _fadeController;
  late AnimationController _toolbarController;

  bool _isLoading = true;
  bool _hasError = false;
  bool _showToolbar = true;
  String? _localPath;
  int _currentPage = 0;
  int _totalPages = 0;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toolbarController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeController.forward();
    _toolbarController.forward();
    _downloadAndOpenPDF();
    // _hideToolbarAfterDelay();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _toolbarController.dispose();
    super.dispose();
  }

  void _hideToolbarAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showToolbar) {
        setState(() {
          _showToolbar = false;
        });
      }
    });
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
    if (_showToolbar) {
      _hideToolbarAfterDelay();
    }
  }

  Future<void> _downloadAndOpenPDF() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _downloadProgress = 0.0;
      });

      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final fileName = widget.fileName ?? 'document.pdf';
      final file = File('${dir.path}/$fileName');

      await dio.download(
        widget.pdfUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onPDFViewCreated(PDFViewController controller) {
    _pdfController = controller;
  }

  void _onPageChanged(int? page, int? total) {
    setState(() {
      _currentPage = page ?? 0;
      _totalPages = total ?? 0;
    });
  }

  void _goToPreviousPage() async {
    if (_currentPage > 0) {
      await _pdfController.setPage(_currentPage - 1);
    }
  }

  void _goToNextPage() async {
    if (_currentPage < _totalPages - 1) {
      await _pdfController.setPage(_currentPage + 1);
    }
  }

  void _downloadPDF() {
    _showDownloadDialog();
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Download PDF',
          style: TextStyle(
            color: DesignColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Would you like to download this PDF to your device?',
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
            onPressed: () async {
              Navigator.pop(context);

              final snackBar = SnackBar(
                content: const Text('Download started...'),
                backgroundColor: DesignColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );

              // ScaffoldMessenger.of(context).showSnackBar(snackBar);

              try {
                // Ask for storage permission (especially for Android)
                if (Platform.isAndroid) {
                  var status = await Permission.storage.request();
                  if (!status.isGranted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: const Text('Storage permission denied'),
                    //     backgroundColor: Colors.red,
                    //   ),
                    // );
                    return;
                  }
                }

                // File download URL and filename
                String fileUrl = widget.pdfUrl; // Replace with your file URL
                String fileName = 'file.pdf';

                // Get device directory (Downloads or temporary)
                Directory directory;
                if (Platform.isAndroid) {
                  directory = Directory('/storage/emulated/0/Download'); // Android downloads folder
                } else {
                  directory = await getApplicationDocumentsDirectory(); // iOS
                }

                String savePath = '${directory.path}/$fileName';

                // Start downloading the file using Dio
                Dio dio = Dio();
                await dio.download(fileUrl, savePath);

                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Downloaded to $savePath'),
                //     backgroundColor: DesignColors.accent,
                //   ),
                // );
              } catch (e, s) {
                kLogger.error("Download failed: ", error: e, stackTrace: s);
                Fluttertoast.showToast(msg: "Download failed");
                
              }
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

  void _showPageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedPage = _currentPage + 1;
        return AlertDialog(
          backgroundColor: DesignColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Go to Page',
            style: TextStyle(
              color: DesignColors.accent,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter page number (1-$_totalPages):',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: selectedPage.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DesignColors.accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DesignColors.accent, width: 2),
                  ),
                ),
                onChanged: (value) {
                  selectedPage = int.tryParse(value) ?? selectedPage;
                },
              ),
            ],
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
                if (selectedPage >= 1 && selectedPage <= _totalPages) {
                  _pdfController.setPage(selectedPage - 1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Go',
                style: TextStyle(color: DesignColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedOpacity(
          opacity: _showToolbar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: DesignColors.white.withOpacity(0.95),
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: DesignColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName ?? 'PDF Viewer',
                  style: TextStyle(
                    color: DesignColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_totalPages > 0)
                  Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.download_rounded, color: DesignColors.accent),
                  onPressed: _downloadPDF,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: GestureDetector(
            onTap: _toggleToolbar,
            child: Stack(
              children: [
                // PDF Content
                Container(
                  margin: EdgeInsets.only(top: 24),
                  child: _buildPDFContent(),
                ),

                // Bottom Navigation
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: _showToolbar ? 20 : -100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: DesignColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: DesignColors.accent.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: DesignColors.accent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.chevron_left_rounded,
                          label: 'Previous',
                          onTap: _goToPreviousPage,
                          enabled: _currentPage > 0,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        _buildControlButton(
                          icon: Icons.format_list_numbered_rounded,
                          label: 'Go to',
                          onTap: _showPageSelector,
                          enabled: _totalPages > 0,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        _buildControlButton(
                          icon: Icons.chevron_right_rounded,
                          label: 'Next',
                          onTap: _goToNextPage,
                          enabled: _currentPage < _totalPages - 1,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                        ),
                        _buildControlButton(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          onTap: () async {
                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: DesignColors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(DesignColors.accent),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Preparing PDF for sharing...',
                                          style: TextStyle(
                                            color: DesignColors.accent,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              final dir = await getTemporaryDirectory();
                              final fileName = widget.fileName ?? 'document.pdf';
                              final file = File('${dir.path}/$fileName');
                              
                              // Download file if it doesn't exist
                              if (!await file.exists()) {
                                final dio = Dio();
                                await dio.download(widget.pdfUrl, file.path);
                              }

                              // Close loading dialog
                              Navigator.pop(context);
                              
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text: 'Check out this PDF'
                              );
                            } catch (e) {
                              // Close loading dialog if error occurs
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              Fluttertoast.showToast(
                                msg: "Failed to share PDF",
                                backgroundColor: Colors.red
                              );
                            }
                          },
                          enabled: true,
                        ),
                      ],
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

  Widget _buildPDFContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DesignColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DesignColors.accent.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(DesignColors.accent),
                value: _downloadProgress > 0 ? _downloadProgress : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              _downloadProgress > 0 ? 'Downloading PDF... ${(_downloadProgress * 100).toInt()}%' : 'Loading PDF...',
              style: TextStyle(
                color: DesignColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_downloadProgress > 0) ...[
              SizedBox(height: 10),
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _downloadProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DesignColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
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
                color: DesignColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                size: 60,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Failed to load PDF',
              style: TextStyle(
                color: DesignColors.accent,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downloadAndOpenPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: DesignColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_localPath != null) {
      return Container(
        decoration: BoxDecoration(
          color: DesignColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: DesignColors.accent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: PDFView(
            filePath: _localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
              });
            },
            onViewCreated: _onPDFViewCreated,
            onPageChanged: _onPageChanged,
            onError: (error) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            },
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: DesignColors.accent,
                size: 20,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: DesignColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
