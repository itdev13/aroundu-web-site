import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ResponsiveAppDownloadCard extends StatefulWidget {
  final String appStoreUrl;
  final String playStoreUrl;
  final VoidCallback? onClose;
  final String? description;

  const ResponsiveAppDownloadCard({
    super.key,
    required this.appStoreUrl,
    required this.playStoreUrl,
    this.onClose,
    this.description,
  });

  @override
  State<ResponsiveAppDownloadCard> createState() => _ResponsiveAppDownloadCardState();
}

class _ResponsiveAppDownloadCardState extends State<ResponsiveAppDownloadCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(duration: Duration(milliseconds: 800), vsync: this);

    _floatController = AnimationController(duration: Duration(seconds: 3), vsync: this);

    _pulseController = AnimationController(duration: Duration(seconds: 2), vsync: this);

    _slideAnimation = CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Start animations after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _floatController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        bool isDesktop = constraints.maxWidth >= 1024;

        return AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _slideAnimation.value) * 50),
              child: Opacity(
                opacity: _slideAnimation.value.clamp(0.0, 1.0), // Fix: Clamp the opacity value
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 32 : 48),
                    vertical: isMobile ? 12 : (isTablet ? 16 : 20),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC6546), Color(0xFFEC4B5D), Color(0xFFD63384)],
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 20 : (isTablet ? 24 : 28)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEC4B5D).withOpacity(0.4),
                        blurRadius: isMobile ? 20 : (isTablet ? 25 : 30),
                        offset: Offset(0, isMobile ? 8 : (isTablet ? 12 : 15)),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: isMobile ? 40 : (isTablet ? 50 : 60),
                        offset: Offset(0, isMobile ? 20 : (isTablet ? 25 : 30)),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background decorative elements
                      Positioned(
                        top: -60,
                        right: -60,
                        child: AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_floatAnimation.value * 10, _floatAnimation.value * 15),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(-_floatAnimation.value * 8, -_floatAnimation.value * 12),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Sparkle effects
                      Positioned(
                        top: 30,
                        left: 30,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value.clamp(0.5, 2.0), // Fix: Clamp scale values
                              child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.6), size: 16),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 40,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: (2 - _pulseAnimation.value).clamp(0.5, 2.0), // Fix: Clamp scale values
                              child: Icon(Icons.stars, color: Colors.white.withOpacity(0.4), size: 12),
                            );
                          },
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 20 : (isTablet ? 24 : 28)),
                        child: isMobile ? _buildMobileLayout(context) : _buildDesktopTabletLayout(context, isDesktop),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with close button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value.clamp(0.8, 1.2), // Fix: Clamp scale values
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 0)),
                      ],
                    ),
                    child: Icon(Icons.get_app_rounded, color: Colors.white, size: 28),
                  ),
                );
              },
            ),
            if (widget.onClose != null)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onClose!();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
        SizedBox(height: 20),

        // Title with sparkle effect
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.8), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Download the AroundU App",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          widget.description ?? "To access this feature, download the AroundU app and unlock exclusive content!",
          style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.5),
        ),
        SizedBox(height: 28),

        // Store buttons
        _buildFancyStoreButtons(context, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopTabletLayout(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        // Left side - Content
        Expanded(
          flex: isDesktop ? 2 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value.clamp(0.8, 1.2), // Fix: Clamp scale values
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 15, offset: Offset(0, 0)),
                            ],
                          ),
                          child: Icon(Icons.get_app_rounded, color: Colors.white, size: isDesktop ? 36 : 32),
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  if (widget.onClose != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onClose!();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 28),

              // Title with sparkle effect
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.8), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Download the AroundU App",
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
               widget.description ?? "To access this feature, download the AroundU app and unlock exclusive content with premium features!",
                style: TextStyle(fontSize: isDesktop ? 17 : 15, color: Colors.white.withOpacity(0.9), height: 1.5),
              ),
              SizedBox(height: 36),

              // Store buttons for tablet/desktop
              _buildFancyStoreButtons(context, isMobile: false),
            ],
          ),
        ),

        // Right side - Enhanced Phone mockup
        if (isDesktop || true) Expanded(flex: isDesktop ? 1 : 2, child: _buildEnhancedPhoneMockup(isDesktop)),
      ],
    );
  }

  Widget _buildFancyStoreButtons(BuildContext context, {required bool isMobile}) {
    return Column(
      children: [
        // Google Play Store
        GestureDetector(
          onTap: () => _launchStore(widget.playStoreUrl, 'play'),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18, horizontal: isMobile ? 20 : 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5)),
                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 0, offset: Offset(0, 0)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF01875F), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.android, color: Colors.white, size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GET IT ON",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        "Google Play",
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFEC4B5D), size: 18),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // App Store
        GestureDetector(
          onTap: () => _launchStore(widget.appStoreUrl, 'app'),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18, horizontal: isMobile ? 20 : 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5)),
                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 0, offset: Offset(0, 0)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF000000), Color(0xFF434343)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Icon(Icons.apple, color: Colors.white, size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DOWNLOAD ON THE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        "App Store",
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFEC4B5D), size: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedPhoneMockup(bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(left: 24),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value * 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background glow effect
                Container(
                  width: isDesktop ? 200 : 160,
                  height: isDesktop ? 400 : 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 30, offset: Offset(0, 0))],
                  ),
                ),
                // Main phone frame
                Container(
                  width: isDesktop ? 190 : 150,
                  height: isDesktop ? 380 : 300,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 25, offset: Offset(0, 12))],
                  ),
                ),
                // Screen with enhanced content
                Container(
                  width: isDesktop ? 170 : 130,
                  height: isDesktop ? 360 : 280,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Column(
                      children: [
                        // Enhanced status bar
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                "AroundU",
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        // Enhanced app content mockup
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                // Search bar mockup
                                Container(
                                  height: 36,
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Color(0xFFEC4B5D).withOpacity(0.3), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 12),
                                      Icon(Icons.search, color: Color(0xFFEC4B5D), size: 16),
                                      SizedBox(width: 8),
                                      Container(width: 60, height: 2, color: Colors.grey[300]),
                                    ],
                                  ),
                                ),
                                // Content cards
                                Expanded(
                                  child: Column(
                                    children: [
                                      // Card 1
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFEC4B5D).withOpacity(0.1),
                                                Color(0xFFEC6546).withOpacity(0.05),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Color(0xFFEC4B5D).withOpacity(0.2), width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 20,
                                                margin: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEC4B5D).withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Card 2
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!, width: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchStore(String url, String store) async {
    HapticFeedback.mediumImpact();

    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
      } else {
        Uri storeUri;
        if (store == 'play' && Platform.isAndroid) {
          storeUri = Uri.parse('market://details?id=${_extractPackageName(url)}');
          if (await canLaunchUrl(storeUri)) {
            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
            return;
          }
        } else if (store == 'app' && Platform.isIOS) {
          String appId = _extractAppId(url);
          storeUri = Uri.parse('itms-apps://itunes.apple.com/app/id$appId');
          if (await canLaunchUrl(storeUri)) {
            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
            return;
          }
        }

        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching store: $e');
    }
  }

  String _extractPackageName(String playStoreUrl) {
    final uri = Uri.parse(playStoreUrl);
    return uri.queryParameters['id'] ?? 'com.example.app';
  }

  String _extractAppId(String appStoreUrl) {
    final match = RegExp(r'/id(\d+)').firstMatch(appStoreUrl);
    return match?.group(1) ?? '123456789';
  }
}

// Fancy Custom Alert Dialog with App Store Buttons
class FancyAppDownloadDialog extends StatelessWidget {
  final String title;
  final String message;
  final String appStoreUrl;
  final String playStoreUrl;
  final String? cancelButtonText;
  final VoidCallback? onCancel;
  final VoidCallback? onClose;

  const FancyAppDownloadDialog({
    Key? key,
    this.title = "Download the AroundU App",
    this.message = "To access this feature, download the AroundU app and unlock exclusive content!",
    required this.appStoreUrl,
    required this.playStoreUrl,
    this.cancelButtonText,
    this.onCancel,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 480,
          maxHeight: MediaQuery.of(context).size.height * 95,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Color(0xFFEC4B5D).withOpacity(0.4), blurRadius: 20, offset: Offset(0, 10)),
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: Offset(0, 20)),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Icon(Icons.get_app_rounded, color: Colors.white, size: 28),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          onClose?.call();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Title with sparkle effect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.8), size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.8), size: 20),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Message
                  Text(
                    message,
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Phone mockup with floating effect
                  // Container(
                  //   height: 120,
                  //   child: Stack(
                  //     alignment: Alignment.center,
                  //     children: [
                  //       // Floating phone 1
                  //       Positioned(
                  //         left: 20,
                  //         top: 10,
                  //         child: Transform.rotate(
                  //           angle: 0.5,
                  //           child: _buildMiniPhone(60, 100),
                  //         ),
                  //       ),
                  //       // Floating phone 2
                  //       Positioned(
                  //         right: 20,
                  //         top: 20,
                  //         child: Transform.rotate(
                  //           angle: -0.5,
                  //           child: _buildMiniPhone(60, 100),
                  //         ),
                  //       ),
                  //       // Center main phone
                  //       _buildMiniPhone(80, 120),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 32),

                  // Store buttons with fancy styling
                  _buildFancyStoreButtons(context, isMobile),

                  // Cancel button (optional)
                  if (cancelButtonText != null) ...[
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        onCancel?.call();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          cancelButtonText!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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

  Widget _buildMiniPhone(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Column(
          children: [
            Container(
              height: height * 0.2,
              decoration: BoxDecoration(
                color: Color(0xFFEC4B5D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              ),
              child: Center(child: Container(width: width * 0.3, height: 2, color: Colors.white)),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      margin: EdgeInsets.only(bottom: 3),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyStoreButtons(BuildContext context, bool isMobile) {
    return Column(
      children: [
        // Google Play Store
        GestureDetector(
          onTap: () => _launchStore(playStoreUrl, 'play'),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4)),
                BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 0, offset: Offset(0, 0)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF01875F), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.android, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GET IT ON",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Google Play",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFEC4B5D), size: 16),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12),

        // App Store
        GestureDetector(
          onTap: () => _launchStore(appStoreUrl, 'app'),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4)),
                BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 0, offset: Offset(0, 0)),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF000000), Color(0xFF434343)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.apple, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "DOWNLOAD ON THE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "App Store",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4B5D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFEC4B5D), size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchStore(String url, String store) async {
    HapticFeedback.mediumImpact();

    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
      } else {
        Uri storeUri;
        if (store == 'play' && Platform.isAndroid) {
          storeUri = Uri.parse('market://details?id=${_extractPackageName(url)}');
          if (await canLaunchUrl(storeUri)) {
            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
            return;
          }
        } else if (store == 'app' && Platform.isIOS) {
          String appId = _extractAppId(url);
          storeUri = Uri.parse('itms-apps://itunes.apple.com/app/id$appId');
          if (await canLaunchUrl(storeUri)) {
            await launchUrl(storeUri, mode: LaunchMode.externalApplication);
            return;
          }
        }

        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching store: $e');
    }
  }

  String _extractPackageName(String playStoreUrl) {
    final uri = Uri.parse(playStoreUrl);
    return uri.queryParameters['id'] ?? 'com.example.app';
  }

  String _extractAppId(String appStoreUrl) {
    final match = RegExp(r'/id(\d+)').firstMatch(appStoreUrl);
    return match?.group(1) ?? '123456789';
  }

  // Helper method to show the dialog
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    required String appStoreUrl,
    required String playStoreUrl,
    String? cancelButtonText,
    VoidCallback? onCancel,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder:
          (context) => FancyAppDownloadDialog(
            title: title ?? "Download the AroundU App",
            message: message ?? "To access this feature, download the AroundU app and unlock exclusive content!",
            appStoreUrl: appStoreUrl,
            playStoreUrl: playStoreUrl,
            cancelButtonText: cancelButtonText,
            onCancel: onCancel,
            onClose: onClose,
          ),
    );
  }
}
