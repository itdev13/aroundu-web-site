import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/dashboard/home.view.dart';
import 'package:aroundu/views/dashboard/house.view.dart';
import 'package:aroundu/views/dashboard/service.dashboard.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardController extends GetxController {
  final currentTabIndex = 0.obs;
  final isLocationGranted = false.obs;

  final service = DashboardService();

  final userId = ''.obs;
  final userPanVerified = false.obs;
  final userAccountVerified = false.obs;
  final userName = ''.obs;
  final userProfilePicture =
      'https://art.pixilart.com/sr21eba8fe8daaws3.png'.obs;

  final userCity = ''.obs;

  final RxList<Widget> tabViews = <Widget>[].obs;

  final RxMap<String, dynamic> userLocation =
      <String, dynamic>{}.obs; // lat lng

  @override
  void onInit() {
    super.onInit();
    getUserId();
    getUserCurrentLocation();
    initializeTabViews();
    updateTabIndex(0);
  }

  Future<void> initializeTabViews() async {
    print("TabView initialized");
    tabViews.value = [
      const HouseView(),
      const HomeView(),
      // NewLobby(),
      // ChatsView(userId: userId.value), // Safe to access userId now
      // Explore(),
      // ProfileDetailsScreen(),
      // const ProfileDetailsFollowedScreen(isFromNavBar:true),
      ProfileDetailsFollowedScreen(isFromNavBar: true),
    ];
  }

  void updateTabIndex(int index) {
    if (index > (tabViews.length - 1)) {
      return;
    }

    currentTabIndex.value = index;
  }

  Future<void> getUserCurrentLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    userLocation.value = {'lat': position.latitude, 'lng': position.longitude};

    final res = await service.updateUserLocation(
      lat: position.latitude,
      lon: position.longitude,
    );

    kLogger.trace("Updating users location details");
    kLogger.debug(res);
  }

  // TODO: Add permissions in IOS info.pList
  Future<void> requestPermissions() async {
    // await Future.delayed(const Duration(seconds: 2));
    await Permission.location.request();
    // await Permission.notification.request();
    await Permission.storage.request();
    isLocationGranted.value = await Permission.location.isGranted;
    if (isLocationGranted.value == true) {
      getUserCurrentLocation();
    } else {
      onLocationAccessDenied();
    }
  }

  Future<void> checkPermissionAccess() async {
    isLocationGranted.value = await Permission.location.isGranted;
  }

  void onLocationAccessDenied() {
    isLocationGranted.value = true;
  }

  Future<void> getUserId() async {
    try {
      final profile = await service.getUserIdData();
      userId.value = profile.userId;
      userPanVerified.value = profile.panVerified;
      userAccountVerified.value = profile.accountVerified;
      userName.value = profile.name;
      userProfilePicture.value = profile.profilePictureUrl;
      userCity.value = profile.addresses?.city ?? "Unknown";
      await initializeTabViews(); // Fetch profile data
    } catch (e) {
      // Handle error if necessary
      print("Errors fetching user data: $e");
    }
  }
}
