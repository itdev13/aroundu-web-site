import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
// import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../designs/colors.designs.dart';
import '../../designs/utils.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import 'controller.dashboard.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    controller.getUserId();
    controller.checkPermissionAccess();
    controller.initializeTabViews();
    controller.getUserCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // controller.updateTabIndex(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      // bottomNavigationBar: const CustomCurvedNavigationBar(),
      // bottomNavigationBar: CustomCrystalNavigationBar()
      //
      // For Animated Bottom Navigation Bar
      bottomNavigationBar: CustomAnimatedNavigationBar(),

      // floatingActionButton: SizedBox(
      //   height: 64.r,
      //   width: 64.r,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       HapticFeedback.mediumImpact();

      //       //TODO: Add lobby creation

      //       // Get.to(
      //       //   () => NewLobby(),
      //       //   transition: Transition.downToUp,
      //       //   duration: const Duration(milliseconds: 300),
      //       //   curve: Curves.easeOutQuint,
      //       // );
      //     },
      //     backgroundColor: DesignColors.accent,
      //     elevation: 2,
      //     shape: const CircleBorder(),
      //     materialTapTargetSize: MaterialTapTargetSize.padded,
      //     splashColor: DesignColors.accent.withOpacity(1),
      //     highlightElevation: 2,
      //     child: Icon(
      //       Icons.add_rounded,
      //       color: Colors.white,
      //       size: 34.sp,
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation:
      //     FloatingActionButtonLocation.centerDocked,
      body: Obx(() {
        if (controller.tabViews.isEmpty) {
          controller.initializeTabViews();
        }
        return controller.tabViews.isNotEmpty
            ? PageView.builder(
              itemCount: controller.tabViews.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Obx(
                  () => controller.tabViews[controller.currentTabIndex.value],
                );
              },
            )
            : const Center(
              child: CircularProgressIndicator(color: DesignColors.accent),
            );
      }),
    );
  }
}

// class CustomCrystalNavigationBar extends StatelessWidget {
//   final DashboardController controller = Get.put(DashboardController());

//   CustomCrystalNavigationBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h),
//       child: Obx(
//         () => CrystalNavigationBar(
//           marginR: EdgeInsets.only(top: 24.h),
//           paddingR: EdgeInsets.only(bottom: 6.h, top: 10.h),
//           margin: EdgeInsets.all(12.r),
//           itemPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
//           enableFloatingNavBar: true,
//           borderRadius: 24.r,
//           currentIndex: controller.currentTabIndex.value,
//           onTap: (index) {
//             if (index == 2) {
//               // Add a small animation effect when tapping the center button
//               HapticFeedback.mediumImpact();
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       NewLobby(),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(0.0, 1.0);
//                     const end = Offset.zero;
//                     const curve = Curves.easeOutQuint;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     return SlideTransition(
//                         position: animation.drive(tween), child: child);
//                   },
//                 ),
//               );
//             } else {
//               HapticFeedback.selectionClick();
//               controller.updateTabIndex(index);
//             }
//           },
//           unselectedItemColor: Colors.black45,
//           selectedItemColor: DesignColors.accent,
//           indicatorColor: DesignColors.accent,
//           backgroundColor: Colors.white,
//           outlineBorderColor: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               spreadRadius: 1,
//               blurRadius: 15,
//               offset: const Offset(0, 2),
//             ),
//           ],
//           items: [
//             _buildNavItem(FontAwesomeIcons.house, 0),
//             _buildNavItem(FontAwesomeIcons.magnifyingGlass, 1),
//             _buildNavItem(FontAwesomeIcons.solidSquarePlus, 2),
//             _buildNavItem(FontAwesomeIcons.solidMessage, 3),
//             _buildNavItem(FontAwesomeIcons.solidCircleUser, 4),
//           ],
//         ),
//       ),
//     );
//   }

//   CrystalNavigationBarItem _buildNavItem(IconData icon, int index) {
//     final bool isSelected = controller.currentTabIndex.value == index;
//     final bool isCreateButton = index == 2;

//     return CrystalNavigationBarItem(
//       icon: icon,
//       // Removed label parameter as it's not supported
//       selectedColor: isCreateButton ? Colors.white : DesignColors.accent,
//       unselectedColor: Colors.black45,
//       // Removed other unsupported parameters
//     );
//   }
// }

//========================

// class CustomCrystalNavigationBar extends StatelessWidget {
//   final DashboardController controller = Get.put(DashboardController());

//   CustomCrystalNavigationBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.r),
//           topRight: Radius.circular(20.r),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             spreadRadius: 0.5,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       padding:
//           EdgeInsets.only(top: 12.h, bottom: 12.h, left: 12.w, right: 12.w),
//       child: Obx(
//         () => SalomonBottomBar(
//           currentIndex: controller.currentTabIndex.value,
//           onTap: (index) {
//             if (index == 2) {
//               HapticFeedback.mediumImpact();
//               Navigator.of(context).push(
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       NewLobby(),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(0.0, 1.0);
//                     const end = Offset.zero;
//                     const curve = Curves.easeOutQuint;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     return SlideTransition(
//                         position: animation.drive(tween), child: child);
//                   },
//                 ),
//               );
//             } else {
//               HapticFeedback.selectionClick();
//               controller.updateTabIndex(index);
//             }
//           },
//           items: [
//             _buildNavItem(
//               icon: Icons.home_rounded,
//               title: "Home",
//               index: 0,
//             ),
//             _buildNavItem(
//               icon: Icons.search_rounded,
//               title: "Search",
//               index: 1,
//             ),
//             _buildCreateButton(),
//             _buildNavItem(
//               icon: Icons.chat_bubble_rounded,
//               title: "Chat",
//               index: 3,
//             ),
//             _buildNavItem(
//               icon: Icons.person_rounded,
//               title: "Profile",
//               index: 4,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   SalomonBottomBarItem _buildNavItem({
//     required IconData icon,
//     required String title,
//     required int index,
//   }) {
//     final bool isSelected = controller.currentTabIndex.value == index;

//     return SalomonBottomBarItem(
//       icon: Icon(
//         icon,
//         size: isSelected ? 24.sp : 22.sp,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 14.sp,
//         ),
//       ),
//       selectedColor: DesignColors.accent,
//       unselectedColor: Colors.black45,
//     );
//   }

//   SalomonBottomBarItem _buildCreateButton() {
//     return SalomonBottomBarItem(
//       icon: Container(
//         height: 48.h,
//         width: 48.h,
//         decoration: BoxDecoration(
//           color: DesignColors.accent,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: DesignColors.accent.withOpacity(0.3),
//               blurRadius: 8,
//               spreadRadius: 2,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(
//           Icons.add_rounded,
//           color: Colors.white,
//           size: 28.sp,
//         ),
//       ),
//       title: Text(
//         "Create",
//         style: TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 14.sp,
//         ),
//       ),
//       selectedColor: DesignColors.accent,
//       unselectedColor: DesignColors.accent,
//     );
//   }
// }

class CustomAnimatedNavigationBar extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  final List<IconData> iconList = [
    Icons.home_rounded,
    Icons.search_rounded,
    // Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  CustomAnimatedNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Calculate the adjusted index for the navigation bar
      final adjustedIndex =controller.currentTabIndex.value;

      return AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 12),
              Icon(
                iconList[index],
                size: 26,
                color: isActive ? DesignColors.accent : Colors.black45,
              ),
              Container(height: 4),
              isActive
                  ? Container(
                    width: 12,
                    // height: ,
                    decoration: BoxDecoration(
                      color: DesignColors.accent,
                      borderRadius: BorderRadius.circular(16),
                      // shape: BoxShape.circle,
                    ),
                  )
                  : SizedBox(height: 8),
            ],
          );
        },
        activeIndex: adjustedIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 16,
        rightCornerRadius: 16,
        backgroundColor: Colors.white,
        elevation: 8,
        splashRadius: 16,
        height: 56,
        hideAnimationCurve: Curves.easeOutQuint,
        shadow: BoxShadow(
          offset: const Offset(0, -3),
          blurRadius: 16,
          spreadRadius: 0.5,
          color: Colors.black.withOpacity(0.1),
        ),
        onTap: (index) {
          HapticFeedback.selectionClick();

          // Adjust index to account for the center button
          final adjustedIndex =  index;
          controller.updateTabIndex(adjustedIndex);
        },
      );
    });
  }
}
