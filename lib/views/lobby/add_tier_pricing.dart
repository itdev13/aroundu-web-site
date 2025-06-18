import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Response;

class TierModel {
  int minSlots;
  int maxSlots;
  int price;

  TierModel(
      {required this.minSlots, required this.maxSlots, required this.price});

  Map<String, dynamic> toJson() {
    return {
      "minSlots": minSlots,
      "maxSlots": maxSlots,
      "price": price,
    };
  }
}

class AddTierPricingPage extends ConsumerStatefulWidget {
  final LobbyDetails lobbyDetail;
  final String lobbyId;

  const AddTierPricingPage(
      {super.key, required this.lobbyId, required this.lobbyDetail});

  @override
  ConsumerState<AddTierPricingPage> createState() => _AddTierPricingPageState();
}

class _AddTierPricingPageState extends ConsumerState<AddTierPricingPage> {
  List<PriceTier> priceTiers = []; // Previous tiers
  List<TextEditingController> priceControllersForExisting = [];

  List<TierModel> tierList = []; // Newly added tiers
  List<TextEditingController> maxControllers = [];
  List<TextEditingController> priceControllers = [];

  void _addTier() {
    int min = 0;

    if (tierList.isNotEmpty) {
      final lastIndex = tierList.length - 1;
      final parsedMax = int.tryParse(maxControllers[lastIndex].text);
      if (parsedMax == null) {
        _showError("Please enter a valid max slot.");
        return;
      }
      if (parsedMax < tierList[lastIndex].minSlots) {
        _showError("Max slot must be >= Min slot.");
        return;
      }

      tierList[lastIndex].maxSlots = parsedMax;
      min = parsedMax + 1;
    } else if (priceTiers.isNotEmpty) {
      min = priceTiers.last.maxSlots + 1;
    }

    int defaultMax = min + 9;
    tierList.add(TierModel(minSlots: min, maxSlots: defaultMax, price: 0));
    maxControllers.add(TextEditingController(text: defaultMax.toString()));
    priceControllers.add(TextEditingController(text: "0"));
    setState(() {});
  }

  // void _removeLastTier() {
  //   if (tierList.isNotEmpty) {
  //     tierList.removeLast();
  //     maxControllers.removeLast();
  //     priceControllers.removeLast();
  //     setState(() {});
  //   }
  // }
  void _removeTierAt(int index) {
    setState(() {
      tierList.removeAt(index);
      maxControllers.removeAt(index);
      priceControllers.removeAt(index);

      // Recalculate minSlots for next tiers
      for (int i = index; i < tierList.length; i++) {
        int newMin = 0;
        if (i == 0 && priceTiers.isNotEmpty) {
          newMin = priceTiers.last.maxSlots + 1;
        } else if (i > 0) {
          newMin = tierList[i - 1].maxSlots + 1;
        }
        tierList[i].minSlots = newMin;
      }
    });
  }

  Widget _buildExistingTierRow(int index) {
    final tier = priceTiers[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          _buildBox("Min Slot", tier.minSlots.toString(), editable: false),
          SizedBox(width: 8),
          _buildBox("Max Slot", tier.maxSlots.toString(), editable: false),
          SizedBox(width: 8),
          _buildBox("Price", tier.price.toString(),
              controller: priceControllersForExisting[index], editable: true),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => _deleteTier(index: index, isExisting: true),
          ),
        ],
      ),
    );
  }

  Widget _buildNewTierRow(int index) {
    final tier = tierList[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          _buildBox("Min Slot", tier.minSlots.toString(), editable: false),
          SizedBox(width: 8),
          _buildBox("Max Slot", maxControllers[index].text,
              controller: maxControllers[index], editable: true),
          SizedBox(width: 8),
          _buildBox("Price", priceControllers[index].text,
              controller: priceControllers[index], editable: true),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => _deleteTier(index: index, isExisting: false),
          ),
        ],
      ),
    );
  }

  void _deleteTier({required int index, required bool isExisting}) {
    setState(() {
      if (isExisting) {
        priceTiers.removeAt(index);
        priceControllersForExisting.removeAt(index);
      } else {
        tierList.removeAt(index);
        maxControllers.removeAt(index);
        priceControllers.removeAt(index);
      }

      // Recalculate minSlots for tiers after the deleted one
      List<TierModel> allTiers = [
        ...priceTiers.map((e) => TierModel(
            minSlots: e.minSlots,
            maxSlots: e.maxSlots,
            price: e.price.toInt())),
        ...tierList
      ];

      for (int i = 1; i < allTiers.length; i++) {
        allTiers[i].minSlots = allTiers[i - 1].maxSlots + 1;

        if (i >= priceTiers.length) {
          // update controller text for new tiers
          int tierIndex = i - priceTiers.length;
          tierList[tierIndex].minSlots = allTiers[i].minSlots;
        }
      }
    });
  }

  Future<Response?> addTierApi({
    // required String lobbyId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final postRequestUrl =
          'https://api.aroundu.in/match/lobby/tiered-pricing';

      final response = await ApiService().put(
        postRequestUrl,
        body: payload,
        // (json) => json, // simple passthrough parser
      );

      if (response.data['status'] == 'SUCCESS') {
        print("Tier Updated successfully: ${response.data['message']}");
      } else {
        print("Failed to update Tier: ${response.data['message']}");
      }

      return response;
    } catch (e) {
      print("API Error while updating Tier: $e");
      rethrow;
    }
  }

  void _saveTiers() async {
    List<TierModel> finalTiers = [];

    // Update price of previous tiers
    for (int i = 0; i < priceTiers.length; i++) {
      final price = int.tryParse(priceControllersForExisting[i].text);
      if (price == null) {
        _showError("Enter valid price for tier ${i + 1}");
        return;
      }
      finalTiers.add(TierModel(
        minSlots: priceTiers[i].minSlots,
        maxSlots: priceTiers[i].maxSlots,
        price: price,
      ));
    }

    // Validate and add new tiers
    for (int i = 0; i < tierList.length; i++) {
      final parsedMax = int.tryParse(maxControllers[i].text);
      final parsedPrice = int.tryParse(priceControllers[i].text);

      if (parsedMax == null || parsedPrice == null) {
        _showError(
            "Enter valid max slot and price for tier ${i + 1 + priceTiers.length}.");
        return;
      }

      if (parsedMax < tierList[i].minSlots) {
        _showError(
            "In tier ${i + 1 + priceTiers.length}, max slot must be >= min slot.");
        return;
      }

      tierList[i].maxSlots = parsedMax;
      tierList[i].price = parsedPrice;

      finalTiers.add(tierList[i]);
    }

    final data = {
      "lobbyId": widget.lobbyId,
      "priceTierList": finalTiers.map((e) => e.toJson()).toList(),
    };

    await addTierApi(payload: data);
    CustomSnackBar.show(context: context, message: "Tiers saved successfully", type: SnackBarType.success);
    

    Get.back();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: DesignText(
      text: msg,
      fontSize: 14,
    )));
  }

  // Widget _buildExistingTierRow(int index) {
  //   final tier = priceTiers[index];
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  //     child: Row(
  //       children: [
  //         _buildBox("Min Slot", tier.minSlots.toString(), editable: false),
  //         SizedBox(width: 8),
  //         _buildBox("Max Slot", tier.maxSlots.toString(), editable: false),
  //         SizedBox(width: 8),
  //         _buildBox("Price", tier.price.toString(),
  //             controller: priceControllersForExisting[index], editable: true),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNewTierRow(int index) {
  //   final tier = tierList[index];

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  //     child: Row(
  //       children: [
  //         _buildBox("Min Slot", tier.minSlots.toString(), editable: false),
  //         SizedBox(width: 8),
  //         _buildBox("Max Slot", maxControllers[index].text,
  //             controller: maxControllers[index], editable: true),
  //         SizedBox(width: 8),
  //         _buildBox("Price", priceControllers[index].text,
  //             controller: priceControllers[index], editable: true),
  //         IconButton(
  //           icon: Icon(Icons.close, color: Colors.red),
  //           onPressed: () => _removeTierAt(index),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNewTierRow(int index) {
  //   final tier = tierList[index];
  //   final isLast = index == tierList.length - 1;

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  //     child: Row(
  //       children: [
  //         _buildBox("Min Slot", tier.minSlots.toString(), editable: false),
  //         SizedBox(width: 8),
  //         _buildBox("Max Slot", maxControllers[index].text,
  //             controller: maxControllers[index], editable: isLast),
  //         SizedBox(width: 8),
  //         _buildBox("Price", priceControllers[index].text,
  //             controller: priceControllers[index], editable: isLast),
  //         if (isLast)
  //           IconButton(
  //             icon: Icon(Icons.close, color: Colors.red),
  //             onPressed: _removeLastTier,
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBox(String title, String value,
      {TextEditingController? controller, bool editable = true}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignText(text: title, fontSize: 12, fontWeight: FontWeight.w500),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: editable
                ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(border: InputBorder.none),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: DesignText(
                      text: value,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Load previous tiers
    final previous = widget.lobbyDetail.lobby.priceTierList;
    if (previous != null && previous.isNotEmpty) {
      priceTiers = List.from(previous);
      priceControllersForExisting = List.generate(
        priceTiers.length,
        (i) =>
            TextEditingController(text: priceTiers[i].price.toInt().toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: DesignText(
          text: "Add Tier Pricing",
          fontSize: 18,
        ),
        actions: [
          TextButton(
            onPressed: _addTier,
            child: DesignText(
              text: "Add Tier",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: (priceTiers.isEmpty && tierList.isEmpty)
                ? Center(
                    child: DesignText(
                    text: "No tiers added yet",
                    fontSize: 14,
                  ))
                : ListView(
                    children: [
                      ...List.generate(
                          priceTiers.length, _buildExistingTierRow),
                      ...List.generate(tierList.length, _buildNewTierRow),
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _saveTiers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEC4B5D),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(32), // Changed radius to 12
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: DesignText(
                text: "Save ",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
