import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/scanner/model/qr_scanner_model.dart';
import 'package:aroundu/views/scanner/services/qr_scanner_provider.dart';
import 'package:aroundu/views/scanner/widget/dash_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../designs/fonts.designs.dart';
import '../../../designs/icons.designs.dart';
import '../../../designs/images.designs.dart';
import '../../../designs/widgets/icon.widget.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart' show Space;
import '../../../designs/widgets/text.widget.designs.dart';
import '../../../models/lobby.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  final String lobbyId;
  final Lobby lobby;

  const ScanQrScreen({super.key, required this.lobbyId, required this.lobby});
  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  Timer? _timer;
  // final ChatsController _chatsController = Get.find<ChatsController>();
  final profileController = Get.put(ProfileController());

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // _chatsController.lobbyJoined.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrScannerProvider.notifier).fetchQrScannerData(widget.lobbyId);
      // _chatsController.lobbyJoined.value = false;
      // _startPolling();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // void _startPolling() {
  //   _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
  //     await ref
  //         .read(qrScannerProvider.notifier)
  //         .fetchQrScannerData(widget.lobbyId);
  //     final qrScannerState = ref.read(qrScannerProvider);
  //     qrScannerState.whenData((data) {
  //       if (data.isNotEmpty && data.first.isScanned == true) {
  //         _timer?.cancel();
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => QRSuccessScreen(
  //               userName: data.first.userSummary?.name ?? "User",
  //             ),
  //           ),
  //         );
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final color = 0xffEC4B5D;
    final qrScannerState = ref.watch(qrScannerProvider);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(color),
            // borderRadius: BorderRadius.vertical(
            //   bottom: Radius.circular(20),
            // ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Your QR Code',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            elevation: 2,
          ),
        ),
      ),
      body: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(DesignImages.splashBg.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
            // _chatsController.lobbyJoined.value
            //     ? qrSuccessCard(profileController.profileData.value?.name ??
            //         profileController.profileData.value?.userName ??
            //         "")
            //     :
            qrScannerState.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('No QR data found.'));
                }
                if (data.first.isScanned == true) {
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   _chatsController.lobbyJoined.value = true;
                  // });
                  return Center(
                    child: qrSuccessCard(
                      data.first.userSummary?.name ??
                          data.first.userSummary?.userName ??
                          "",
                    ),
                  );
                }
                final qrData = data.first;
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Space(height: 16),
                        buildQrDetails(qrData),
                        Space.h(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: DesignText(
                            text:
                                "Arrive, scan your QR, and check in. Don't miss out on AURA—make sure to mark your entry!",
                            fontSize: 16,
                            maxLines: 5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                print("$error \n $stack");
                return Center(
                  child: Text(
                    'Error loading data: $error',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              },
            ),

            // Add a button to manually toggle the state (for testing)
            // Positioned(
            //   bottom: 20,
            //   right: 20,
            //   child: FloatingActionButton(
            //     onPressed: () {
            //       _chatsController.lobbyJoined.value = !_chatsController.lobbyJoined.value;
            //     },
            //     child: Icon(_chatsController.lobbyJoined.value ? Icons.close : Icons.check),
            //   ),
            // ),
          ],
        ),
      
    );
  }

  Widget buildQrDetails(QrScannerModel data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    if (data.qrImageBase64 == null) {
      return const Center(child: Text('QR image data is missing'));
    }

    Uint8List? bytes;
    try {
      bytes = base64Decode(data.qrImageBase64);
    } catch (e) {
      return Center(child: Text('Invalid QR image data: $e'));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        height: sh(0.8),
        width: sw(0.9),
        constraints: BoxConstraints(),
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child:
                      data.lobbyDetail?.mediaUrls != null
                          ? Image.network(
                            data.lobbyDetail!.mediaUrls!.isNotEmpty
                                ? data.lobbyDetail?.mediaUrls?.first ?? ""
                                : "",
                            width: 150,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 120,
                                color: Colors.grey,
                                child: const Icon(Icons.error),
                              );
                            },
                          )
                          : Container(
                            width: 150,
                            height: 120,
                            color: Colors.grey,
                            child: const Icon(Icons.groups_rounded),
                          ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.lobbyDetail?.lobbyType ?? 'Unknown',
                        style: DesignFonts.poppins.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 8,
                          color: const Color(0xFF3E79A1),
                        ),
                      ),
                      Text(
                        data.lobbyDetail?.title ?? 'Untitled Lobby',
                        style: DesignFonts.poppins.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Host Name',
                        style: DesignFonts.poppins.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: const Color(0xFF444444),
                        ),
                      ),
                      Text(
                        data.lobbyDetail?.createdBy?.name ?? 'Unknown Host',
                        style: DesignFonts.poppins.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: const Color(0xFF323232),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: IconButton(
                      onPressed: () async {
                        final image = await screenshotController
                            .captureFromWidget(
                              buildQrDetails(data),
                              pixelRatio: 2,
                              context: context,
                            );
                        Share.shareXFiles([
                          XFile.fromData(image, mimeType: 'image/png'),
                        ], text: "Check in to ${widget.lobby.title}");
                      },
                      icon: DesignIcon.icon(
                        icon: FontAwesomeIcons.shareFromSquare,
                        color: DesignColors.accent,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: sw(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF444444),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          data.lobbyDetail?.joinedDate ?? '',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: sw(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF444444),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          data.lobbyDetail?.joinedTime ?? '',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: sw(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slots',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF444444),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '${data.slots ?? 1}',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: sw(0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Venue',
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF444444),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          widget
                                  .lobby
                                  .filter
                                  .otherFilterInfo
                                  .locationInfo
                                  ?.googleSearchResponses
                                  .first
                                  .description ??
                              "Unknown",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: DesignFonts.poppins.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF323232),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            const DashDivider(color: Colors.grey, dashHeight: 1),
            SizedBox(height: 16),
            Expanded(
              child: bytes != null
                  ? Image.memory(
                    bytes,
                     height: sh(0.35),
                    width: sw(0.9),
                    fit: BoxFit.fitHeight,
                    // height: screenHeight * 0.3,
                    // width: screenWidth * 0.6,
                  )
                  : const Icon(Icons.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget qrUserDetails() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        // height: 0.7.sh,
        width: sw(1),
        // margin: EdgeInsets.only(top: 20),
        // padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Space.h(height: 18),
            DesignText(
              text: "User Details",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
            Space.h(height: 18),
            const DashDivider(color: Color(0xFF6E6E6E), dashHeight: 0.8),
            Space.h(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _userDetail(
                        icon: DesignIcons.contactCalendar,
                        title: "Joined on",
                        subTitle: "16 Dec, 2024",
                      ),
                      _userDetail(
                        icon: DesignIcons.slot,
                        title: "Slot booked ",
                        subTitle: "2",
                      ),
                    ],
                  ),
                  Space.h(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _userDetail(
                        icon: DesignIcons.importantDevices,
                        title: "Lobbies attended ",
                        subTitle: "34",
                      ),
                      _userDetail(
                        icon: DesignIcons.tickUser,
                        title: "User Rating",
                        subTitle: "4.5",
                      ),
                    ],
                  ),
                  Space.h(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(backgroundColor: Colors.grey, radius: 18),
                      Space.w(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DesignText(
                            text: "Request accepted  by ",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF444444),
                          ),
                          Space.h(height: 6),
                          DesignText(
                            text: "Aspen George",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF444444),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Space.h(height: 24),
            DesignText(
              text: "Payment Details",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444444),
            ),
            Space.h(height: 18),
            const DashDivider(color: Color(0xFF6E6E6E), dashHeight: 0.8),
            Space.h(height: 34),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _userDetail(
                        icon: DesignIcons.localAtm,
                        title: "Joined on",
                        subTitle: "Google pay",
                      ),
                      _userDetail(
                        icon: DesignIcons.payment,
                        title: "Joined on",
                        subTitle: "₹4500",
                      ),
                    ],
                  ),
                  Space.h(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _userDetail(
                        icon: DesignIcons.calendar,
                        title: "Date of Payment",
                        subTitle: "17 Dec, 2024 | 04:00 PM",
                        iconSize: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Space.h(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _userDetail({
    required DesignIcons icon,
    required String title,
    required String subTitle,
    double iconSize = 20,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DesignIcon.custom(icon: icon, size: iconSize, color: Color(0xFF444444)),
        Space.w(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DesignText(
              text: title,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF444444),
            ),
            Space.h(height: 6),
            DesignText(
              text: subTitle,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF444444),
            ),
          ],
        ),
      ],
    );
  }

  Widget qrSuccessCard(String name) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Container(
          width: sw(0.75),
          // height: 0.35.sh,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Card content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Star icon
                      Image.asset(
                        'assets/images/star.png',
                        height: 80,
                        width: 80,
                      ),
                      Space.h(height: 24),
                      // Celebration text
                      DesignText(
                        text: "Hurrah $name!",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF444444),
                      ),
                      Space.h(height: 16),
                      DesignText(
                        text:
                            "You have been marked as an attendant by the admin.",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF444444),
                        maxLines: 10,
                        textAlign: TextAlign.center,
                      ),
                      Space.h(height: 24),
                      // QR code note
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DesignText(
                          text:
                              "This QR code can only be used once and cannot be used to enter the lobby.",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                          maxLines: 10,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Confetti animation - positioned to fill the container
                Positioned.fill(
                  child: Lottie.asset(
                    'assets/animations/confetti.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//=============================================

// class ScanQrScreen extends ConsumerStatefulWidget {
//   final String lobbyId;
//
//   const ScanQrScreen({super.key, required this.lobbyId});
//   @override
//   ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
// }
//
// class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(qrScannerProvider.notifier).fetchQrScannerData(widget.lobbyId);
//       //_startPolling();
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   void _startPolling() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
//       await ref
//           .read(qrScannerProvider.notifier)
//           .fetchQrScannerData(widget.lobbyId);
//       final qrScannerState = ref.read(qrScannerProvider);
//       // qrScannerState.whenData((data) {
//       //   if (data.isNotEmpty && data.first.isScanned == true) { // Assuming `status` is the flag
//       //     _timer?.cancel();
//       //     Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => const QRSuccessScreen(userName: "Shyam"))); // Replace '/nextScreen' with your route
//       //   }
//       // });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = 0xffEC4B5D;
//     final qrScannerState = ref.watch(qrScannerProvider);
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//
//       // backgroundColor: Colors.redAccent,
//       appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(kToolbarHeight),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Color(color),
//               borderRadius: const BorderRadius.vertical(
//                 bottom: Radius.circular(20),
//               ),
//             ),
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               leading: const Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.white,
//                 size: 15,
//               ),
//               title: const Text(
//                 'Scan QR Code',
//                 style: TextStyle(color: Colors.white),
//               ),
//               bottom: const PreferredSize(
//                 preferredSize: Size(double.infinity, 30),
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 10.0),
//                   child: Text(
//                     'Show, Scan and Attend the lobbies',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               centerTitle: true,
//               elevation: 2,
//             ),
//           )),
//       body: qrScannerState.when(
//         data: (data) {
//           if (data.isEmpty) {
//             return const Center(child: Text('No QR data found.'));
//           }
//           final qrData = data.first; // Assuming only one QR detail is required
//           return Stack(
//             children: [
//               // Background image
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(DesignImages.splashBg.path),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               // Centered card
//               Center(
//                 child: buildQrDetails(qrData),
//               ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(
//           child: Text(
//             'Error loading data. Please try again.',
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildQrDetails(QrScannerModel data) {
//     final String? qrImageBase64 = data.qrImageBase64;
//     Uint8List bytes = base64Decode(qrImageBase64!);
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         margin: const EdgeInsets.only(top: 20),
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white
//               .withOpacity(0.9), // Slight transparency for overlay effect
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               spreadRadius: 5,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                   child: Image.network(
//                     data.lobbyDetail?.createdBy?.profilePictureUrl ??
//                         "", // Replace with your image
//                     width: 150,
//                     height: 120,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 SizedBox(width: 16.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         data.lobbyDetail!.lobbyType!,
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 8,
//                             color: Color(0xFF3E79A1)),
//                       ),
//                       Text(data.lobbyDetail!.title!,
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w600, fontSize: 18)),
//                       SizedBox(height: 4.0),
//                       Text('Host Name',
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: const Color(0xFF444444))),
//                       Text(data.lobbyDetail!.createdBy!.name!,
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: const Color(0xFF323232))),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 25),
//             Padding(
//               padding: EdgeInsets.only(right: 50.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Date',
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12,
//                               color: Color(0xFF444444))),
//                       SizedBox(height: 4.0),
//                       Text(data.lobbyDetail!.joinedDate! ?? "",
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: Color(0xFF323232))),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(
//                             right: MediaQuery.of(context).size.width / 6),
//                         child: Text('Time',
//                             style: DesignFonts.poppins.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12,
//                                 color: Color(0xFF444444))),
//                       ),
//                       SizedBox(height: 4.0),
//                       Text(data.lobbyDetail!.joinedTime!,
//                           style: DesignFonts.poppins.copyWith(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 12,
//                               color: Color(0xFF323232))),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Admit',
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Color(0xFF444444))),
//                     SizedBox(height: 4.0),
//                     Text('01 Slots',
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w400,
//                             fontSize: 12,
//                             color: Color(0xFF323232))),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Venue',
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Color(0xFF444444))),
//                     SizedBox(height: 4.0),
//                     Text(
//                       '4579 Columbia Avenue,\nTillamancaster 22184',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: DesignFonts.poppins.copyWith(
//                           fontWeight: FontWeight.w400,
//                           fontSize: 12,
//                           color: Color(0xFF323232)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 25),
//             const DashDivider(
//               color: Colors.grey,
//               dashHeight: 1,
//             ),
//             const SizedBox(height: 25),
//             Column(
//               children: [
//                 Image.memory(
//                   bytes,
//                   width: MediaQuery.of(context).size.width * 0.6,
//                 ),
//                 SizedBox(height: 16.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Reference ID: ',
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w500, fontSize: 16)),
//                     Text(data.qrId!,
//                         style: DesignFonts.poppins.copyWith(
//                             fontWeight: FontWeight.w300, fontSize: 16)),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
