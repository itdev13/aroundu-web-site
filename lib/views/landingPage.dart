import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/views/splash.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth/auth.view.dart';

class AppLandingPage extends StatefulWidget {
  const AppLandingPage({super.key});

  @override
  State<AppLandingPage> createState() => _AppLandingPageState();
}

class _AppLandingPageState extends State<AppLandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Get.toNamed(AppRoutes.auth.replaceAll(':destination', 'new'));
  }

  void _navigateToSignUp() {
    Get.toNamed(AppRoutes.auth.replaceAll(':destination', 'new'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 1200;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC6546), Color(0xFFEC4B5D)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 60.0 : 24.0,
                    vertical: 20.0,
                  ),
                  child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildHeader(isMobile: true),
        const SizedBox(height: 40),
        Transform.scale(
          scale: 0.8, // Adjust scale factor to match desired size
          child: _buildMockupSection(),
        ),
        const SizedBox(height: 40),
        _buildAppDownloadSection(isMobile: true),
        const SizedBox(height: 40),
        // Copyright text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Text(
            "© 2025 AroundU. All rights reserved.\nProperty of NextGen Tech © 2025",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // _buildLoginCard(),
        // const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/aroundu.png',
                      width: 24,
                      height: 24,
                      // color: const Color(0xFFEC4B5D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DesignText(
                    text: 'AroundU',
                    fontSize:
                        Theme.of(context).textTheme.headlineSmall?.fontSize ??
                        24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.splash);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFFEC4B5D),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 10,
                  shadowColor: Colors.white.withValues(alpha: 1),
                ),
                child: const DesignText(
                  text: 'Get Started',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.accent,
                ),
              ),
            ],
          ),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile: false),
                    const SizedBox(height: 60),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: 
                      _buildAppDownloadSection(isMobile: false),
                    ),
      
                    // const SizedBox(height: 60),
                    // _buildAppDownloadSection(isMobile: false),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(flex: 4, child: _buildMockupSection()),
            ],
          ),
          
          // Copyright text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.only(top: 40),
            child: const Text(
              "© 2025 AroundU. All rights reserved.\nProperty of NextGen Tech © 2025",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
       SizedBox(height: 64),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/aroundu.png',
                        width: 24,
                        height: 24,
                        // color: const Color(0xFFEC4B5D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DesignText(
                      text: 'AroundU',
                      fontSize:(Get.width > 380) ?
                          Theme.of(context).textTheme.headlineSmall?.fontSize ??
                          24.0 : 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.splash);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFEC4B5D),
                    padding: EdgeInsets.symmetric(horizontal: (Get.width > 380) ? 32 : 24, vertical: (Get.width > 380) ? 16:14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: Colors.white.withValues(alpha: 1),
                  ),
                  child: DesignText(
                    text: 'Get Started',
                    fontSize: (Get.width > 380) ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.accent,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 30),
          const DesignText(
            text: 'Connect with\nLike-minded People',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            maxLines: null,
            overflow: TextOverflow.visible,
            // height: 1.2,
          ),
          const SizedBox(height: 16),
          DesignText(
            text:
                'Build your community of people who share your interests and passions${isMobile ? " " : "\n"}Discover events, make friends, and create lasting connections.',
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            maxLines: null,
            overflow: TextOverflow.visible,
            // height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildMockupSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background decoration
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Phone mockups
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPhoneMockup(
                      'assets/appshots/lobby.png', // Replace with your image path
                      offset: const Offset(-10, 0),
                      rotation: -0.1,
                    ),
                    const SizedBox(width: 8),
                    _buildPhoneMockup(
                      'assets/appshots/house.png', // Replace with your image path
                      offset: const Offset(10, -20),
                      rotation: 0.1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneMockup(
    String imagePath, {
    Offset offset = Offset.zero,
    double rotation = 0,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 180,
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Container(
                  //   height: 30,
                  //   color: Colors.black,
                  //   child: Center(
                  //     child: Container(
                  //       width: 60,
                  //       height: 4,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(2),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Expanded(child: Image.asset(imagePath, fit: BoxFit.cover)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome to AroundU!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with like-minded people around you',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4B5D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _navigateToSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEC4B5D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFEC4B5D), width: 1.5),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDownloadSection({required bool isMobile}) {
    // App store URLs - replace with actual URLs
    final String appStoreUrl = 'https://apps.apple.com/in/app/aroundu/id6744299663';
    final String playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.polar.aroundu';

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          // constraints: BoxConstraints(maxWidth: 450),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEC6546), Color(0xFFEC4B5D), Color(0xFFD63384)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFEC4B5D).withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative elements
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 100,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.2),
                  size: 20,
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with sparkle effect
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.get_app_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Download the AroundU app",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isMobile ? 22 : 28,
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
                      "Build your community of like-minded people. Follow your favorite communities, clubs, and brands. Available only on the app!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 28),

                    // Store buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildStoreButton(
                            title: "Google Play",
                            subtitle: "GET IT ON",
                            icon: Icons.android,
                            gradientColors: [
                              Color(0xFF01875F),
                              Color(0xFF4CAF50),
                            ],
                            onTap: () => _launchStoreUrl(playStoreUrl),
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStoreButton(
                            title: "App Store",
                            subtitle: "GET IT ON",
                            icon: Icons.apple,
                            gradientColors: [
                              Color(0xFF000000),
                              Color(0xFF434343),
                            ],
                            onTap: () => _launchStoreUrl(appStoreUrl),
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
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

  Future<void> _launchStoreUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
