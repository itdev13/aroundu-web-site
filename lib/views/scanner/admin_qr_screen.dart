import 'package:aroundu/designs/icons.designs.dart';
import 'package:aroundu/designs/images.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/views/scanner/model/qr_scanner_model.dart';
import 'package:aroundu/views/scanner/services/qr_scanner_provider.dart';
import 'package:aroundu/views/scanner/widget/dash_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../../../designs/fonts.designs.dart';

class AdminQrScreen extends ConsumerStatefulWidget {
  final String url;
  final String lobbyId;
  const AdminQrScreen({super.key, required this.url, required this.lobbyId});

  @override
  ConsumerState<AdminQrScreen> createState() => _AdminQrScreenState();
}

class _AdminQrScreenState extends ConsumerState<AdminQrScreen> {
  final color = 0xffEC4B5D;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrScannerProvider.notifier).fetchQrScannedData(url: widget.url, lobbyId: widget.lobbyId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final qrScannerState = ref.watch(qrScannerProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Container(
            decoration: BoxDecoration(
              color: Color(color),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              leading: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 15,
              ),
              title: qrScannerState.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Text('No data found');
                  }
                  final qrData = data
                      .first; // Assuming the first QR data contains user information
                  String userName = qrData.userSummary!.userName ??
                      'Unknown User'; // Replace 'userName' with the actual field from your data
                  return Text(
                    userName,
                    style: const TextStyle(color: Colors.white),
                  );
                },
                loading: () => const Text('Loading...',
                    style: TextStyle(color: Colors.white)),
                error: (error, stack) =>
                    const Text('Error', style: TextStyle(color: Colors.white)),
              ),
              bottom: PreferredSize(
                preferredSize: Size(double.infinity, 50),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: qrScannerState.when(
                    data: (data) {
                      if (data.isEmpty) {
                        return const Text('No data found');
                      }
                      final qrData = data
                          .first; // Assuming the first QR data contains user information
                      String id = qrData.qrId ??
                          'Unknown User'; // Replace 'userName' with the actual field from your data
                      return Text(
                        "ReferenceId: $id",
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                    loading: () => const Text('Loading...',
                        style: TextStyle(color: Colors.white)),
                    error: (error, stack) => const Text('Error',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              centerTitle: true,
              elevation: 2,
            ),
          )),
      body: qrScannerState.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No  data found.'));
          }
          final qrData = data.first;
          print("QR Data: $qrData"); // Assuming only one QR detail is required
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      DesignImages.splashBg.path,
                      // Replace with your image URL
                    ),

                    fit: BoxFit.cover,
                    // Ensures the image covers the entire screen
                  ),
                ),
                child: (qrData.status != 'SUCCESS')? Center(child: qrUserDetails(qrData),)
                // ? Padding(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Center(
                    //       child: DesignText(
                    //         text: qrData.message ?? "Something went wrong",
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.white,
                    //         maxLines: 10,
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ),
                    //   )
                    : (qrData.lobbyDetail != null)
                        ? _buildCardBasedOnType(
                            qrData) // Call a method to handle different types
                        : const Center(child: Text('Lobby Detail is missing')),

                // _buildCard(qrData),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Text(
              'Error loading data. Please try again.',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBasedOnType(QrScannerModel qrData) {
    print("_buildCardBasedOnType : ${qrData.status}");
    switch (qrData.lobbyDetail!.lobbyType) {
       case 'PRIVATE':
        return _buildPublicUnpaidCard(qrData); 
      // case 'PRIVATE':
      //   return _buildPrivatePaidCard(qrData); // Call method for private card
      // case 'PRIVATE UNPAID':
      //   return _buildPrivateUnpaidCard(qrData); // Call method for public card
      // case 'PUBLIC PAID':
      //   return _buildPublicPaidCard(qrData); // Call method for premium card
      // case 'PUBLIC UNPAID':
      //   return _buildPublicUnpaidCard(qrData);
      case 'PUBLIC':
        return _buildPublicUnpaidCard(qrData); // Call method for VIP card
      default:
        return const Center(child: Text('Unknown lobby type'));
    }
  }

  Widget _buildPrivatePaidCard(QrScannerModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 6),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Stack(children: [
            CircleAvatar(
              radius: 51,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage(data!.approvedBy!.profilePictureUrl! ?? ""),
              ),
            ),
            Positioned(
                right: 0,
                bottom: 5,
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueAccent),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    )))
          ]),
        ),

        // User Details Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('User Details',
                    style: DesignFonts.poppins
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(
                  height: 10,
                ),
                const DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.calendar_today, 'Joined on', '16 Dec, 2024'),
                    _buildDetailItem(Icons.star, 'First Time Attende', '4.5 ⭐'),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(Icons.group, 'Joined AroundU On ',
                        data.lobbyDetail!.totalMembers.toString()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          data!.approvedBy!.profilePictureUrl! ?? ""),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request accepted by",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                        SizedBox(height: 4.0),
                        Text(data.approvedBy!.userName ?? "",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                // _buildDetailItem(Icons.person, 'Request accepted by',
                //     'Aspen George'),
                const SizedBox(
                  height: 30,
                ),

                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.payment, 'Payment mode', 'Google Pay'),
                    _buildDetailItem(
                        Icons.attach_money, 'Paid amount', '₹4500'),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildDetailItem(Icons.calendar_today, 'Date of Payment',
                    '17 Dec, 2024 | 04:00 PM'),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Footer Section
        Container(
          // color: Colors.redAccent,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: const BoxDecoration(
              color: Color(0xffEC4B5D),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: const Text(
            'User Marked Attended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivateUnpaidCard(QrScannerModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 6),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Stack(children: [
            CircleAvatar(
              radius: 51,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage(data!.approvedBy!.profilePictureUrl! ?? ""),
              ),
            ),
            Positioned(
                right: 0,
                bottom: 5,
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueAccent),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    )))
          ]),
        ),

        // User Details Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('User Details',
                    style: DesignFonts.poppins
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(
                  height: 10,
                ),
                const DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.calendar_today, 'Joined on', '16 Dec, 2024'),
                    _buildDetailItem(Icons.star, 'First Time Attende', '4.5 ⭐'),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(Icons.group, 'Joined AroundU On ',
                        data.lobbyDetail!.totalMembers.toString()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          data!.approvedBy!.profilePictureUrl! ?? ""),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request accepted by",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(height: 4.0),
                        Text(data.approvedBy!.userName ?? "",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                // _buildDetailItem(Icons.person, 'Request accepted by',
                //     'Aspen George'),
                const SizedBox(
                  height: 30,
                ),

                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.payment, 'Payment mode', 'Google Pay'),
                    _buildDetailItem(
                        Icons.attach_money, 'Paid amount', '₹4500'),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildDetailItem(Icons.calendar_today, 'Date of Payment',
                    '17 Dec, 2024 | 04:00 PM'),
              ],
            ),
          ),
        ),

        // Footer Section
        Container(
          color: Colors.redAccent,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'User Marked Attended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicPaidCard(QrScannerModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 6),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Stack(children: [
            CircleAvatar(
              radius: 51,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage(data!.approvedBy!.profilePictureUrl! ?? ""),
              ),
            ),
            Positioned(
                right: 0,
                bottom: 5,
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blueAccent),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
                    )))
          ]),
        ),

        // User Details Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('User Details',
                    style: DesignFonts.poppins
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(
                  height: 10,
                ),
                DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.calendar_today, 'Joined on', '16 Dec, 2024'),
                    _buildDetailItem(Icons.star, 'First Time Attende', '4.5 ⭐'),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(Icons.group, 'Joined AroundU On ',
                        data.lobbyDetail!.totalMembers.toString()),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          data!.approvedBy!.profilePictureUrl! ?? ""),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request accepted by",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                        SizedBox(height: 4.0),
                        Text(data.approvedBy!.userName ?? "",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                // _buildDetailItem(Icons.person, 'Request accepted by',
                //     'Aspen George'),
                SizedBox(
                  height: 30,
                ),

                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.payment, 'Payment mode', 'Google Pay'),
                    _buildDetailItem(
                        Icons.attach_money, 'Paid amount', '₹4500'),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildDetailItem(Icons.calendar_today, 'Date of Payment',
                    '17 Dec, 2024 | 04:00 PM'),
              ],
            ),
          ),
        ),

        // Footer Section
        Container(
          color: Colors.redAccent,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'User Marked Attended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicUnpaidCard(QrScannerModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 6),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Stack(children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(
                    data.userSummary?.profilePictureUrl ?? "profilePictureUrl"),
              ),
            ),
            // Positioned(
            //     right: 0,
            //     bottom: 5,
            //     child: Container(
            //         padding: EdgeInsets.all(5),
            //         decoration: BoxDecoration(
            //             shape: BoxShape.circle, color: Colors.blueAccent),
            //         child: Icon(
            //           Icons.check,
            //           color: Colors.white,
            //           size: 15,
            //         ))),
          ]),
        ),

        // User Details Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('User Details',
                    style: DesignFonts.poppins
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(
                  height: 10,
                ),
                DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.calendar_today,
                        'Joined on',
                        // (data.scannedAt != null)
                        //     ? _formatDateTime(data.scannedAt!)
                        //     : "unknown"),
                        data.lobbyDetail?.joinedOn ?? "unknown",
                    ),
                    _buildDetailItem(Icons.star, 'First Time Attende', '${data.userSummary?.rating ?? 0.0} ⭐'),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                        Icons.group,
                        // 'Joined AroundU On ',
                        'Total Members',
                        data.lobbyDetail?.totalMembers.toString() ??
                            "totalMembers"),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          data.approvedBy?.profilePictureUrl ??
                              "profilePictureUrl"),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Request accepted by",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                        SizedBox(height: 4.0),
                        Text(data.approvedBy?.userName ?? "",
                            style: DesignFonts.poppins.copyWith(
                                fontWeight: FontWeight.w400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                // _buildDetailItem(Icons.person, 'Request accepted by',
                //     'Aspen George'),
                SizedBox(
                  height: 30,
                ),

              if(data.paymentDetails != null) ...[
                Text(
                  'Payment Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                DashDivider(
                  dashHeight: 1,
                  color: Colors.grey,
                ),

                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     _buildDetailItem(Icons.calendar_today, 'Date of Payment',
                          data.paymentDetails?.paymentDate?? "unknown"),
                    
                    _buildDetailItem(
                        Icons.attach_money, 'Paid amount', '₹ ${data.paymentDetails?.paidAmount?? 0.0}'),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildDetailItem(Icons.payment, 'transactionId', data.paymentDetails?.transactionId?? "unknown"),
              ],

                
              ],
            ),
          ),
        ),

        // Footer Section
        Container(
          color: Colors.redAccent,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'User Marked Attended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.redAccent),
        SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: DesignFonts.poppins
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 12)),
            SizedBox(height: 4.0),
            Text(value,
                style: DesignFonts.poppins
                    .copyWith(fontWeight: FontWeight.w400, fontSize: 12)),
          ],
        ),
      ],
    );
  }

Widget qrUserDetails(QrScannerModel data) {
  double screenWidth = Get.width;
    double screenHeight = Get.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           SizedBox(height: sh(0.05)),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(
                  data.userSummary?.profilePictureUrl ?? "profilePictureUrl"),
            ),
          ),
          SizedBox(height: 16),
          Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
               
                Space.h(height: 18),
                DesignText(
                  text: "User Details",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF444444),
                ),
                Space.h(height: 18),
                const DashDivider(
                  color: Color(0xFF6E6E6E),
                  dashHeight: 0.8,
                ),
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
                              subTitle: data.lobbyDetail?.joinedOn?? "unknown",),
                              if(data.slots != null)
                          _userDetail(
                              icon: DesignIcons.slot,
                              title: "Slot booked ",
                              subTitle: "${data.slots}",),
                        ],
                      ),
                      Space.h(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // (data.scannedAt != null)
                        //     ? _formatDateTime(data.scannedAt!)
                        //     : "unknown"),
                          _userDetail(
                              icon: DesignIcons.importantDevices,
                              title: "Scanned At",
                              subTitle: (data.scannedAt != null)
                            ? _formatDateTime(data.scannedAt!)
                            : "unknown"),
                          _userDetail(
                              icon: DesignIcons.tickUser,
                              title: "User Rating",
                              subTitle: "${data.userSummary?.rating?? 0.0} ⭐"),
                        ],
                      ),
                      Space.h(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 18,
                            backgroundImage: NetworkImage(
                                data.approvedBy?.profilePictureUrl ??
                                    "profilePictureUrl"),
                          ),
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
                                text: data.approvedBy?.userName?? data.approvedBy?.name ??"unknown",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF444444),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Space.h(height: 24),
                // DesignText(
                //   text: "Payment Details",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w600,
                //   color: Color(0xFF444444),
                // ),
                // Space(height: 18),
                const DashDivider(
                  color: Color(0xFF6E6E6E),
                  dashHeight: 0.8,
                ),
                Space.h(height: 34),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: DesignText(
                    text: data.message ?? "Something went wrong",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E79A1),
                    maxLines: null,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
                Space.h(height: 40),
              ],
            ),
          ),
        ],
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
        DesignIcon.custom(
          icon: icon,
          size: iconSize,
          color: Color(0xFF444444),
        ),
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


  String _formatDateTime(DateTime dateTime) {
    try {
      final date =
          "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
      final time =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      return "$date | $time";
    } catch (e) {
      return "unknown date"; // Return fallback if formatting fails
    }
  }
}
