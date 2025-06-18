
import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/views/offer/apply.offer.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../designs/colors.designs.dart';
import '../../../models/offers_model.dart';

class OfferCard extends ConsumerStatefulWidget {
  final String price;
  final bool isActive;
  final String discountType;
  final double discountValue;
  final String offerId;
  final VoidCallback onDelete;
  final List<String> eligibility;
  final bool isAdmin;
  final Offer offer;

  const OfferCard({
    super.key,
    required this.price,
    required this.isActive,
    required this.discountType,
    required this.discountValue,
    required this.offerId,
    required this.onDelete,
    required this.eligibility,
    required this.offer,
    this.isAdmin = false,
  });

  @override
  ConsumerState<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends ConsumerState<OfferCard> {
  // Function to Show Dialog
  void showDeleteOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteOfferDialog(
        offerId: widget.offerId,
        onDelete: widget.onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle null safety
    final String safePrice = widget.price.isNotEmpty ? widget.price : "0";
    final String safeDiscountType =
        widget.discountType.isNotEmpty ? widget.discountType : "FLAT";
    final double safeDiscountValue =
        widget.discountValue > 0 ? widget.discountValue : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        height: 174,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            // Left Section
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: ClipPath(
                clipper: TicketLeftClipper(),
                child: Container(
                  width: 80,
                  color: Color(0xFF87A5C6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DesignText(
                        text: "OFF",
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      RotatedBox(
                        quarterTurns: 3,
                        child: DesignText(
                          text: safeDiscountType == "PERCENTAGE"
                              ? "${safeDiscountValue.toInt()}%"
                              : "FLAT",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Right Section
            Positioned(
              left: 80,
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipPath(
                clipper: TicketRightClipper(),
                child: Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey.shade200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DesignText(
                            text: safeDiscountType == "PERCENTAGE"
                                ? "FLAT $safeDiscountValue%"
                                : "FLAT ₹$safeDiscountValue OFF",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          Spacer(),
                          Text(
                            widget.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: widget.isActive
                                  ? Colors.green
                                  : ColorsPalette.redColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 5),
                      // DesignText(
                      //   text: "Get flat ₹$safePrice OFF on all lobbies",
                      //   fontSize: 10,
                      //   color: Colors.black54,
                      //   fontWeight: FontWeight.w500,
                      // ),
                      SizedBox(height: 5),
                      DesignText(
                        text: "Applicable for",
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 8),
                      if (widget.eligibility != null &&
                          widget.eligibility.isNotEmpty)
                        Row(
                          children: widget.eligibility
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _tagWidget(e),
                                  ))
                              .toList(),
                        ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: (widget.isAdmin)
                            ? [
                                GestureDetector(
                                  onTap: () => showDeleteOfferDialog(context),
                                  child: DesignText(
                                    text: "Delete",
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                DesignText(
                                  text: "EDIT",
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ColorsPalette.redColor,
                                ),
                              ]
                            : [
                                DesignText(
                                  text: (widget.offer.isApplicable)
                                      ? (ref
                                                  .watch(selectedOfferProvider)
                                                  ?.offerId ==
                                              widget.offerId)
                                          ? "Remove"
                                          : "Apply"
                                      : "Not Applicable",
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (widget.offer.isApplicable)
                                      ? (ref
                                                  .watch(selectedOfferProvider)
                                                  ?.offerId ==
                                              widget.offerId)
                                          ? DesignColors.accent
                                          : const Color(0xFF3E79A1)
                                      : DesignColors.accent,
                                ),
                              ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagWidget(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DesignText(
        text: text,
        fontSize: 10,
        color: Colors.blue,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class DeleteOfferDialog extends StatelessWidget {
  final String offerId;
  final VoidCallback onDelete;

  const DeleteOfferDialog(
      {super.key, required this.offerId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        // Rounded corners
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(), // Pushes text to the center
                DesignText(
                  text: "Delete Offer",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                Spacer(), // Ensures text is centered
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 22, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Divider
            Divider(color: Colors.black26, thickness: 1),

            SizedBox(height: 15),

            // Confirmation Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Are you sure you want to delete this offer, this will remove offer from lobby page.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPalette.redColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded button
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // Handle delete logic
                  print("delete api called initiated");
                  final response = await Api.deleteOffers(offerId);
                  Navigator.pop(context);
                  if (response) {
                    print("Offer deleted successfully");
                    onDelete();

                    // Refresh the page
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => manageOfferScreen()),
                    // );
                  } else {
                    // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete offer')),
                    );
                  }
                },
                child: DesignText(
                  text: "Delete",
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ), // Set background color to white
    );
  }
}

// Left Clipper (Centered Cutout on the Left Border)
class TicketLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutoutRadius = 15;
    double cutoutCenterY = size.height / 2;

    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // Center cutout
    path.lineTo(0, cutoutCenterY + cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutCenterY - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Right Clipper (Centered Cutout on the Right Border)
class TicketRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cutoutRadius = 15;
    double cutoutCenterY = size.height / 2;

    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cutoutCenterY - cutoutRadius);

    // Cutout in the center of the right side
    path.arcToPoint(
      Offset(size.width, cutoutCenterY + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Border Around the Right Section
class TicketRightClipperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey; // Border color

    final path = TicketRightClipper().getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
