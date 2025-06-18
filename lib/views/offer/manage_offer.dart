import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/offers_model.dart';
import 'package:aroundu/views/lobby/widgets/offer_card.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'create.offer.dart';

class ManageOfferScreen extends StatefulWidget {
  final String lobbyId;
  const ManageOfferScreen({super.key, required this.lobbyId});

  @override
  State<ManageOfferScreen> createState() => _ManageOfferScreenState();
}

class _ManageOfferScreenState extends State<ManageOfferScreen> {
  final TextEditingController discountValueController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedDiscountType;
  String? selectedEligibility;
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: DesignText(
          text: "Manage Offer",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          // TextButton(
          //   onPressed: () {},
          //   child: DesignText(
          //     text: "Cancel",
          //     fontSize: 12,
          //     fontWeight: FontWeight.w500,
          //     color: Colors.blue,
          //   ),
          // )
        ],
      ),
      body: FutureBuilder<List<Offer>>(
        future: Api.getOffers(entityId: widget.lobbyId, isApplicable: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            var offers = snapshot.data!;
            return Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DesignText(
                        text: "Apply discount offer for your lobby",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 39),
                      ...offers.map((offer) => GestureDetector(
                            onTap: () => Get.to(() => EditOfferScreen(
                                  lobbyId: widget.lobbyId,
                                  editPage: "edit",
                                )),
                            child: OfferCard(
                              offer: offer,
                              isAdmin: true,
                              price: offer.discountedPrice.toString(),
                              isActive: (offer.startDate != null &&
                                      offer.endDate != null)
                                  ? DateTime.now().isAfter(
                                          DateTime.parse(offer.startDate!)) &&
                                      DateTime.now().isBefore(
                                          DateTime.parse(offer.endDate!)
                                              .add(Duration(days: 1)))
                                  : false,
                              discountType: offer.discountType,
                              discountValue: offer.discountValue,
                              offerId: offer.offerId,
                              onDelete: () {
                                setState(() {});
                              },
                              eligibility: offer.eligibilityCriteria,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => EditOfferScreen(lobbyId: widget.lobbyId));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEC4B5D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // Changed radius to 12
            ),
            minimumSize: Size(double.infinity, 48),
          ),
          child: DesignText(
            text: "Add New Offer",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
