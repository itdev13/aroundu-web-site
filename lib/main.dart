import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/constants/firebase_options.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/utils.designs.dart';
import 'package:aroundu/utils/app_lifecycle_service.dart';
import 'package:aroundu/utils/route_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await DesignUtils.lockPortraitOrientation();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For web, we should enable all orientations
    DesignUtils.enableAllOrientations();

    return GetMaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      navigatorObservers: [RiverpodRouteObserver(ref)],
      debugShowCheckedModeBanner: false,
      title: 'AroundU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: DesignColors.accent),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: RouteService().configureRoutes(),
      // home: SplashView(),
    );
    // ScreenUtilInit(
    //   designSize: Size(
    //     // DesignUtils.kFigmaScreenWidth,

    //     // DesignUtils.kFigmaScreenHeight,
    //     //phone
    //     // 360,
    //     // 690,
    //     //tablet
    //     // 768,
    //     // 1024,
    //     //desktop
    //     1280,
    //     800,
    //   ),
    //   minTextAdapt: true,
    //   splitScreenMode: true,
    //   builder: (context, child) {
    //     return
    //   },
    // );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Use ScreenBuilder to handle all responsive logic with separate layouts
    return ScreenBuilder(
      phoneLayout: _buildPhoneLayout(context),
      tabletLayout: _buildTabletLayout(context),
      desktopLayout: _buildDesktopLayout(context),
    );
  }

  // Phone-specific layout
  Widget _buildPhoneLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'AroundU Web',
          style: TextStyle(
            fontSize: DesignUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Show drawer or menu for mobile
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context),
      body: Padding(
        padding: DesignUtils.getResponsivePadding(context),
        child: OrientationScreenBuilder(
          portraitLayout: _buildPhonePortraitLayout(context),
          landscapeLayout: _buildPhoneLandscapeLayout(context),
        ),
      ),
    );
  }

  // Tablet-specific layout
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'AroundU Web',
          style: TextStyle(
            fontSize: DesignUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildDesktopNavigation(context)],
      ),
      body: Padding(
        padding: DesignUtils.getResponsivePadding(context),
        child: OrientationScreenBuilder(
          portraitLayout: _buildTabletPortraitLayout(context),
          landscapeLayout: _buildTabletLandscapeLayout(context),
        ),
      ),
    );
  }

  // Desktop-specific layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'AroundU Web',
          style: TextStyle(
            fontSize: DesignUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildDesktopNavigation(context)],
      ),
      body: Padding(
        padding: DesignUtils.getResponsivePadding(context),
        child: _buildDesktopContent(context),
      ),
    );
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavItem(context, 'Home'),
        _buildNavItem(context, 'About'),
        _buildNavItem(context, 'Services'),
        _buildNavItem(context, 'Contact'),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            fontSize: DesignUtils.getResponsiveFontSize(context, 16),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Text(
              'AroundU Menu',
              style: TextStyle(
                fontSize: DesignUtils.getResponsiveFontSize(context, 24),
                color: Colors.white,
              ),
            ),
          ),
          _buildDrawerItem(context, 'Home', Icons.home),
          _buildDrawerItem(context, 'About', Icons.info),
          _buildDrawerItem(context, 'Services', Icons.design_services),
          _buildDrawerItem(context, 'Contact', Icons.contact_mail),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontSize: DesignUtils.getResponsiveFontSize(context, 16),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Handle navigation
      },
    );
  }

  // Phone portrait layout
  Widget _buildPhonePortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFeatureCard(
            context,
            'Feature 1',
            'This is a description of feature 1',
            Icons.star,
            Colors.blue,
          ),
          SizedBox(height: DesignUtils.getResponsiveSpacing(context, 16)),
          _buildFeatureCard(
            context,
            'Feature 2',
            'This is a description of feature 2',
            Icons.favorite,
            Colors.red,
          ),
          SizedBox(height: DesignUtils.getResponsiveSpacing(context, 16)),
          _buildFeatureCard(
            context,
            'Feature 3',
            'This is a description of feature 3',
            Icons.thumb_up,
            Colors.green,
          ),
        ],
      ),
    );
  }

  // Phone landscape layout
  Widget _buildPhoneLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildFeatureCard(
            context,
            'Feature 1',
            'This is a description of feature 1',
            Icons.star,
            Colors.blue,
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Feature 2',
                  'This is a description of feature 2',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Feature 3',
                  'This is a description of feature 3',
                  Icons.thumb_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tablet portrait layout
  Widget _buildTabletPortraitLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Feature 1',
                  'This is a description of feature 1',
                  Icons.star,
                  Colors.blue,
                ),
              ),
              SizedBox(width: DesignUtils.getResponsiveSpacing(context, 16)),
              Expanded(
                child: _buildFeatureCard(
                  context,
                  'Feature 2',
                  'This is a description of feature 2',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignUtils.getResponsiveSpacing(context, 16)),
        Expanded(
          child: _buildFeatureCard(
            context,
            'Feature 3',
            'This is a description of feature 3',
            Icons.thumb_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  // Tablet landscape layout
  Widget _buildTabletLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildFeatureCard(
            context,
            'Feature 1',
            'This is a description of feature 1',
            Icons.star,
            Colors.blue,
          ),
        ),
        SizedBox(width: DesignUtils.getResponsiveSpacing(context, 16)),
        Expanded(
          child: _buildFeatureCard(
            context,
            'Feature 2',
            'This is a description of feature 2',
            Icons.favorite,
            Colors.red,
          ),
        ),
        SizedBox(width: DesignUtils.getResponsiveSpacing(context, 16)),
        Expanded(
          child: _buildFeatureCard(
            context,
            'Feature 3',
            'This is a description of feature 3',
            Icons.thumb_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  // Desktop content layout
  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar
        Container(
          width: DesignUtils.toDeviceW(context, 20),
          color: Colors.grey[200],
          padding: EdgeInsets.all(
            DesignUtils.getResponsiveSpacing(context, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: DesignUtils.getResponsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DesignUtils.getResponsiveSpacing(context, 24)),
              _buildSidebarItem(context, 'Home', Icons.home),
              _buildSidebarItem(context, 'About', Icons.info),
              _buildSidebarItem(context, 'Services', Icons.design_services),
              _buildSidebarItem(context, 'Contact', Icons.contact_mail),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(
              DesignUtils.getResponsiveSpacing(context, 24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to AroundU Web',
                  style: TextStyle(
                    fontSize: DesignUtils.getResponsiveFontSize(context, 32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DesignUtils.getResponsiveSpacing(context, 16)),
                Text(
                  'This is a responsive web application that adapts to different screen sizes.',
                  style: TextStyle(
                    fontSize: DesignUtils.getResponsiveFontSize(context, 18),
                  ),
                ),
                SizedBox(height: DesignUtils.getResponsiveSpacing(context, 24)),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          'Feature 1',
                          'This is a description of feature 1',
                          Icons.star,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: DesignUtils.getResponsiveSpacing(context, 16),
                      ),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          'Feature 2',
                          'This is a description of feature 2',
                          Icons.favorite,
                          Colors.red,
                        ),
                      ),
                      SizedBox(
                        width: DesignUtils.getResponsiveSpacing(context, 16),
                      ),
                      Expanded(
                        child: _buildFeatureCard(
                          context,
                          'Feature 3',
                          'This is a description of feature 3',
                          Icons.thumb_up,
                          Colors.green,
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
    );
  }

  Widget _buildSidebarItem(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: DesignUtils.getResponsiveFontSize(context, 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(DesignUtils.getResponsiveSpacing(context, 16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DesignUtils.getResponsiveFontSize(context, 48),
              color: color,
            ),
            SizedBox(height: DesignUtils.getResponsiveSpacing(context, 16)),
            Text(
              title,
              style: TextStyle(
                fontSize: DesignUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: DesignUtils.getResponsiveSpacing(context, 8)),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
