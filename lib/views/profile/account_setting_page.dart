import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/auth/auth.view.dart';
import 'package:aroundu/views/dashboard/house.view.dart';
import 'package:aroundu/views/house/provider/houses_providers.dart';
import 'package:aroundu/views/house/provider/houses_providers_util.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers_util.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';
import 'package:aroundu/views/profile/widgets/custom_setting_without_image.dart';
// import 'package:aroundu/views/house/user_view_profile/saved_payments_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

class AccountAndSettingsPage extends ConsumerStatefulWidget {
  const AccountAndSettingsPage({super.key});

  @override
  ConsumerState<AccountAndSettingsPage> createState() =>
      _AccountAndSettingsPageState();
}

class _AccountAndSettingsPageState
    extends ConsumerState<AccountAndSettingsPage> {
  @override
  void initState() {
    super.initState();
    _fetchSettingsPermission();
  }

  Future<void> _fetchSettingsPermission() async {
    try {
      final response = await Api.getSettingPermission();
      final settings = response.data;
      if (settings != null) {
        setState(() {
          _isToggled = settings['receiveNotifications'] ?? false;
          _isToggled2 = settings['showLobbiesAttended'] ?? false;
          _isToggled3 = settings['showFollowedHouses'] ?? false;
          _isToggled4 = settings['showMoments'] ?? false;
        });
      } else {
        print('Settings data is null');
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  bool _isToggled = false;
  bool _isToggled2 = false;
  bool _isToggled3 = false;
  bool _isToggled4 = false;
  bool _isToggled5 = false;
  // bool _isToggled6 = false;

  // void _handleToggle(bool value) {
  //   setState(() {
  //     _isToggled = value;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const DesignText(
            text: 'Account & Settings',
            fontSize: 18,
            fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 1.0,
        shadowColor: Colors.grey[300],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Column(
              children: [
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => AddFinalDetails(
                //           isAccountSetup: true,
                //         ),
                //       ),
                //     );
                //   },
                //   child: CustomSettingsCardWithoutImage(
                //     // imagePath: "",
                //     text: "Saved Payment details ",
                //   ),
                // ),
                // CustomSettingsCardWithoutImage(
                //   text: "Device permissions ",
                // ),
                // CustomToggleCard(
                //   description:
                //       'Got notified of what’s new in the saved lobbies and followed house announcements. ',
                //   isToggled: _isToggled,
                //   onToggle: (value) async {
                //     setState(() {
                //       _isToggled = value;
                //     });
                //     await Api.updateSettingPermission(
                //         receiveNotifications: _isToggled,
                //         showLobbiesAttended: _isToggled2,
                //         showFollowedHouses: _isToggled3,
                //         showMoments: _isToggled4);
                //   },
                //   title: 'Notification permissions ',
                // ),
                // CustomToggleCard(
                //   description:
                //       'Everyone can see the lobbies that you have saved ',
                //   isToggled: _isToggled2,
                //   onToggle: (value) async {
                //     setState(() {
                //       _isToggled2 = value;
                //     });
                //     await Api.updateSettingPermission(
                //         receiveNotifications: _isToggled,
                //         showLobbiesAttended: _isToggled2,
                //         showFollowedHouses: _isToggled3,
                //         showMoments: _isToggled4);
                //   },
                //   title: 'Show lobbies attended ',
                // ),
                // CustomToggleCard(
                //   description: 'Everyone can see the houses that you followed ',
                //   isToggled: _isToggled3,
                //   onToggle: (value) async {
                //     setState(() {
                //       _isToggled3 = value;
                //     });
                //     await Api.updateSettingPermission(
                //         receiveNotifications: _isToggled,
                //         showLobbiesAttended: _isToggled2,
                //         showFollowedHouses: _isToggled3,
                //         showMoments: _isToggled4);
                //   },
                //   title: 'Show Followed houses ',
                // ),
                // CustomToggleCard(
                //   description: 'Everyone can see moments shared by you ',
                //   isToggled: _isToggled4,
                //   onToggle: (value) async {
                //     setState(() {
                //       _isToggled4 = value;
                //     });
                //     await Api.updateSettingPermission(
                //         receiveNotifications: _isToggled,
                //         showLobbiesAttended: _isToggled2,
                //         showFollowedHouses: _isToggled3,
                //         showMoments: _isToggled4);
                //   },
                //   title: 'Show Shared moments ',
                // ),
                // CustomToggleCard(
                //   description:
                //       'Your friends, lobbies attended, and join date are visible to everyone.',
                //   isToggled: _isToggled5,
                //   onToggle: (value) async {
                //     setState(() {
                //       _isToggled5 = value;
                //     });
                //     await Api.updateSettingPermission(
                //         _isToggled, _isToggled2, _isToggled3, _isToggled4);
                //   },
                //   title: 'Show additional personal details ',
                // ),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => HelpCenterPage(),
                //       ),
                //     );
                //   },
                //   child: CustomSettingsCardWithoutImage(
                //     text: "Help Centre",
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsConditionsPage(),
                      ),
                    );
                  },
                  child: CustomSettingsCardWithoutImage(
                    // imagePath: "",
                    text: "Terms & Conditions ",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyPage(),
                      ),
                    );
                  },
                  child: CustomSettingsCardWithoutImage(
                    text: "Privacy Policies ",
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    ref.invalidate(LobbyProviderUtil.getProvider(
                        ref.watch(checkOutLobbiesProvider)));
                    ref.invalidate(
                        HouseProviderUtil.getProvider(HouseType.followed));
                    ref.invalidate(
                        HouseProviderUtil.getProvider(HouseType.created));
                    final authService = AuthService();
                    await Api.deleteAccount();
                    Get.offAll(() => const AuthView());
                    await authService.clearAuthData();
                    await GetStorage().remove("fcmToken");
                    await GetStorage().remove("userUID");
                    await GetStorage().write('isLoggedOut', true);
                    await Get.deleteAll();
                    Get.offAll(() => const AuthView());
                  },
                  child: CustomSettingsCardWithoutImage(
                    // imagePath: "",
                    text: "Delete Account",
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Show confirmation dialog before signing out
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const DesignText(
                            text: 'Sign Out',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          content: const DesignText(
                            text: 'Are you sure you want to sign out?',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const DesignText(
                                text: 'Cancel',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close the dialog
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.transparent,
                                        content: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                                color: DesignColors.accent),
                                          ],
                                        ),
                                      );
                                    });
                                ref.invalidate(LobbyProviderUtil.getProvider(
                                    ref.watch(checkOutLobbiesProvider)));
                                ref.invalidate(HouseProviderUtil.getProvider(
                                    HouseType.followed));
                                ref.invalidate(HouseProviderUtil.getProvider(
                                    HouseType.created));
                                // Perform sign out
                                final authService = AuthService();

                                

                                // Clear auth data and storage
                                await authService.clearAuthData();
                                await GetStorage().remove("fcmToken");
                                await GetStorage().remove("userUID");
                                await GetStorage().write('isLoggedOut', true);

                                // Delete all controllers and navigate to auth view
                                await Get.deleteAll();
                                Get.offAll(() => const AuthView());
                              },
                              child: const DesignText(
                                text: 'Sign Out',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CustomSettingsCardWithoutImage(
                    text: "Sign Out",
                  ),
                ),
              ],
              // ],
            ),
          ),
        ),
      ),
    );
  }
}
