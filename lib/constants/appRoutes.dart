
import 'package:aroundu/views/dashboard/dashboard.view.dart';
import 'package:aroundu/views/notifications/notifications.view.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';
import 'package:aroundu/views/splash.view.dart';
import 'package:get/get.dart';

class AppRoutes {
  // Route name constants
  static const String splash = '/';
  static const String dashboard = '/dashboard';

  //notifications
  static const String notifications = '/notifications';
  static const String notificationsGeneral = '/notifications/general';
  static const String notificationsRequests = '/notifications/requests';
  static const String notificationsInvitations = '/notifications/invitations';

  //profile
  static const String myProfile = '/myProfile';
  static const String otherProfile = '/otherProfile/:userId';

  //house
  static const String house = '/house/:houseId';

  //lobby
  static const String lobby = '/lobby/:lobbyId';

  // Define all routes as GetPage objects
  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: dashboard,
      page: () => DashboardView(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: notifications,
      page: () => NotificationsView(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: myProfile,
      page: () => ProfileDetailsFollowedScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    // GetPage(
    //   name: otherProfile,
    //   page: () {
    //     // Get the userId parameter from the URL
    //     final userId = Get.parameters['userId'];
    //     // You would typically pass this to a profile view that shows other users
    //     // For now, we'll just use the ProfileView as a placeholder
    //     return ProfileView();
    //   },
    //   transition: Transition.rightToLeftWithFade,
    // ),
    // Add more routes as needed
  ];
}
