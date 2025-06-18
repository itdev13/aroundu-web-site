import 'package:aroundu/views/lobby/widgets/offer_card.dart';
import 'package:aroundu/views/profile/services/apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../designs/widgets/text.widget.designs.dart';
import '../../models/offers_model.dart';

final selectedOfferProvider = StateProvider<Offer?>((ref) => null);

class ApplyOffers extends ConsumerStatefulWidget {
  const ApplyOffers({super.key, required this.lobbyId});
  final String lobbyId;

  @override
  ConsumerState<ApplyOffers> createState() => _ApplyOffersState();
}

class _ApplyOffersState extends ConsumerState<ApplyOffers> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.invalidate(selectedOfferProvider);
  //   });
  // }

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
        future: Api.getOffers(entityId: widget.lobbyId, isApplicable: true, ref: ref),
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
                            onTap: offer.isApplicable
                                ? () {
                                    if (ref
                                            .watch(selectedOfferProvider)
                                            ?.offerId ==
                                        offer.offerId) {
                                      ref
                                          .read(selectedOfferProvider.notifier)
                                          .state = null;
                                      Fluttertoast.showToast(
                                          msg: "Removed Successfully");
                                    } else {
                                      ref
                                          .read(selectedOfferProvider.notifier)
                                          .state = offer;
                                      Fluttertoast.showToast(
                                          msg: "Applied Successfully");
                                    }
                                    Get.back();
                                  }
                                : () => Fluttertoast.showToast(
                                    msg: "this offer is not applicable"),
                            child: OfferCard(
                              offer: offer,
                              price: offer.discountedPrice.toString(),
                              isActive: offer.isApplicable,
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
    );
  }
}
