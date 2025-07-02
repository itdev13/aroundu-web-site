import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/models/offers_model.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/lobby/provider/forms_list_provider.dart';
import 'package:aroundu/views/lobby/provider/get_price_provider.dart';
import 'package:aroundu/views/offer/apply.offer.dart';
import 'package:aroundu/views/payment/gateway_service/Cashfree/cashfree.payment.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../designs/colors.designs.dart';
import '../../designs/icons.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import 'package:dotted_border/dotted_border.dart';

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(1);

  void increment() => state++;
  void decrement() {
    if (state > 0) {
      state--;
    }
  }

  void setValue(int value) {
    state = value;
  }
}

final expandStateProvider = StateNotifierProvider.autoDispose
    .family<ExpandNotifier, bool, String>((ref, key) {
      return ExpandNotifier();
    });

class ExpandNotifier extends StateNotifier<bool> {
  ExpandNotifier() : super(false);

  void toggle() => state = !state;
}

class CheckOutPublicLobbyView extends ConsumerStatefulWidget {
  const CheckOutPublicLobbyView({
    super.key,
    required this.lobby,
    this.formModel,
    this.requestText,
  });
  final Lobby lobby;
  final FormModel? formModel;
  final String? requestText;

  @override
  ConsumerState<CheckOutPublicLobbyView> createState() =>
      _CheckOutPublicLobbyViewState();
}

class _CheckOutPublicLobbyViewState
    extends ConsumerState<CheckOutPublicLobbyView> {
  final profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // || (widget.lobby.lobbyType=='PUBLIC' && widget.lobby.priceDetails?.price!= 0.0)

    Future.microtask(() {
      ref.read(formsListProvider.notifier).resetFormsList();
      if (widget.formModel != null) {
        if (ref.read(formsListProvider).isEmpty) {
          ref.read(formsListProvider.notifier).addForm(widget.formModel!);
        }
      }
    });

    if (widget.lobby.accessRequestData != null) {
      Future.microtask(() {
        ref
            .read(counterProvider.notifier)
            .setValue(widget.lobby.accessRequestData?.count ?? 1);

        ref
            .read(pricingProvider(widget.lobby.id).notifier)
            .updateGroupSize(widget.lobby.id, ref.read(counterProvider));
      });
    } else {
      Future.microtask(() {
        ref.read(counterProvider.notifier).setValue(1);

        // final existingForms = ref.read(formsListProvider);
        // final hasExistingForm =
        //     existingForms.any((f) => f.title == widget.formModel?.title);

        // if (!hasExistingForm &&
        //     widget.formModel != null &&
        //     widget.lobby.isFormMandatory == true) {
        //   ref.read(formsListProvider.notifier).addForm(widget.formModel!);
        // }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read(selectedOfferProvider.notifier).state = null;
      ref.read(formsListProvider.notifier).resetFormsList();
      ref.read(counterProvider.notifier).setValue(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // kLogger.trace("lobby typr : ${widget.lobby.lobbyType} \n formMandatory : ${widget.lobby.isFormMandatory}");
    final count = ref.watch(counterProvider);

    final selectedOffer = ref.watch(selectedOfferProvider);
    print("selectedOffer.offerName : ${selectedOffer?.offerName}");

    final pricingState = ref.watch(pricingProvider(widget.lobby.id));
    final pricingData = pricingState.pricingData;
    print("priceData : ${pricingData?.toJson()}");

    final formList = ref.watch(formsListProvider);
    print("formList : ${formList}");
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: DesignText(
          text: "Checkout",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
        leading: IconButton(
          onPressed: () {
            Fluttertoast.showToast(msg: "checkout is still pending");
            ref.read(selectedOfferProvider.notifier).state = null;
            ref.read(counterProvider.notifier).setValue(0);
            Get.back();
          },
          icon: DesignIcon.icon(icon: Icons.arrow_back_ios_new_rounded),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 0.09 * sh,
        // padding: EdgeInsets.symmetric(
        //   horizontal: 0.05 * sw,
        //   vertical: 0.01 * sh,
        // ),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DesignText(
                  text:
                      (widget.lobby.priceDetails?.price != 0.0)
                          ? "Total Payout "
                          : 'Let’s GO !',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF444444),
                ),
                DesignText(
                  text:
                      "₹ ${calculateTotalPrice(pricingData: pricingData, selectedOffer: selectedOffer)}",

                  // text: (calculateTotalPrice(pricingData: pricingData, selectedOffer: selectedOffer) != '0.0') ? "₹ ${calculateTotalPrice(pricingData: pricingData, selectedOffer: selectedOffer)}" : "Free",

                  // text: (pricingData?.isTieredPriced != null &&
                  //         pricingData?.isTieredPriced == true)
                  //     ? "₹ ${pricingData?.total ?? (count * ((pricingData?.currentPricePerSlot ?? widget.lobby.priceDetails?.price ?? 0.0) - (selectedOffer?.discountedPrice ?? 0.0)))}"
                  //     : (widget.lobby.priceDetails?.price != 0.0)
                  //         ? (selectedOffer?.discountedPrice != null)
                  //             ? "₹ ${(count * (widget.lobby.priceDetails?.price ?? 0.0)) - (count * ((widget.lobby.priceDetails?.price ?? 0.0) - (selectedOffer?.discountedPrice ?? 0.0)))}"
                  //             : "₹ ${count * (widget.lobby.priceDetails?.price ?? 0.0)}"
                  //         : "Free",
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            SizedBox(
              width: 0.45 * sw,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: DesignButton(
                      onPress: () {
                        HapticFeedback.mediumImpact();
                        final price =
                            count * (widget.lobby.priceDetails?.price ?? 0.0);
                        final formList = ref.read(formsListProvider);
                        final isFormValidated =
                            ref
                                .watch(formsListProvider.notifier)
                                .validateAllForms();
                        print("isFormValidated : $isFormValidated");
                        // kLogger.trace(
                        //   "isFormListData : ${(ref.read(formsListProvider.notifier).getAllFormsData()[1]['questions'].length)}",
                        // );
                        if (count > 0 && isFormValidated) {
                          if (pricingData != null &&
                              pricingData.currentProvider == 'cashfree') {
                            Get.off(
                              () => CashFreePaymentView(
                                userId:
                                    profileController
                                        .profileData
                                        .value
                                        ?.userId ??
                                    "",
                                lobby: widget.lobby,
                                formModel:
                                    formList.isNotEmpty
                                        ? formList.first
                                        : widget.formModel,
                                formList: formList,
                                requestText: widget.requestText,
                              ),
                            );
                          } else {
                            CustomSnackBar.show(
                              context: context,
                              message:
                                  "Can't proceed right now for payment \n Please try later after some time",
                              type: SnackBarType.warning,
                            );
                            // Get.off(
                            //   () => HyperCheckOutPaymentView(
                            //     // amount: 100,
                            //     userId:
                            //         profileController
                            //             .profileData
                            //             .value
                            //             ?.userId ??
                            //         "",
                            //     lobby: widget.lobby,
                            //     formModel:
                            //         formList.isNotEmpty
                            //             ? formList.first
                            //             : widget.formModel,
                            //     formList: formList,
                            //     requestText: widget.requestText,
                            //   ),
                            // );
                          }
                        } else {
                          if (count == 0) {
                            Fluttertoast.showToast(
                              msg: "can't proceed with 0 slots",
                            );
                          } else if (!isFormValidated) {
                            Fluttertoast.showToast(
                              msg: "Please fill all the required form fields",
                            );
                          }
                        }
                      },
                      bgColor:
                          (count > 0 &&
                                  ref
                                      .watch(formsListProvider.notifier)
                                      .validateAllForms())
                              ? DesignColors.accent
                              : const Color(0xFF989898),
                      title: "Checkout",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 393,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: Color(
                        0x143E79A1,
                      ), // #3E79A114: 0x14 is the alpha value
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            (widget.lobby.mediaUrls.isNotEmpty)
                                ? widget.lobby.mediaUrls.first
                                : "",
                            height: 142,
                            width: 175,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 142,
                                width: 175,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 142,
                                width: 175,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: DesignColors.accent,
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Space.w(width: 12),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DesignText(
                                  text: widget.lobby.title,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                  maxLines: 2,
                                ),
                                // SizedBox(height: 4),
                                // DesignText(
                                //   text: widget.lobby.description,
                                //   fontSize: 12,
                                //   fontWeight: FontWeight.w400,
                                //   color: const Color(0xFF6E6E6E),
                                //   maxLines: 2,
                                // ),
                                if (widget
                                        .lobby
                                        .filter
                                        .otherFilterInfo
                                        .dateRange !=
                                    null) ...[
                                  Space.h(height: 8),
                                  Row(
                                    children: [
                                      DesignIcon.custom(
                                        icon: DesignIcons.calendar,
                                        color: DesignColors.accent,
                                        size: 10,
                                      ),
                                      Space.w(width: 4),
                                      Expanded(
                                        child: DesignText(
                                          text:
                                              widget
                                                  .lobby
                                                  .filter
                                                  .otherFilterInfo
                                                  .dateRange
                                                  ?.formattedDateCompactView ??
                                              "",
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF444444),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (widget
                                        .lobby
                                        .filter
                                        .otherFilterInfo
                                        .dateInfo !=
                                    null) ...[
                                  Space.h(height: 8),
                                  Row(
                                    children: [
                                      DesignIcon.custom(
                                        icon: DesignIcons.calendar,
                                        color: DesignColors.accent,
                                        size: 10,
                                      ),
                                      Space.w(width: 4),
                                      Expanded(
                                        child: DesignText(
                                          text:
                                              widget
                                                  .lobby
                                                  .filter
                                                  .otherFilterInfo
                                                  .dateInfo
                                                  ?.formattedDate ??
                                              "",
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF444444),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (widget
                                        .lobby
                                        .filter
                                        .otherFilterInfo
                                        .locationInfo !=
                                    null) ...[
                                  Space.h(height: 8),
                                  Row(
                                    children: [
                                      DesignIcon.custom(
                                        icon: DesignIcons.location,
                                        color: DesignColors.accent,
                                        size: 10,
                                      ),
                                      Space.w(width: 4),
                                      Expanded(
                                        child: DesignText(
                                          text:
                                              widget
                                                  .lobby
                                                  .filter
                                                  .otherFilterInfo
                                                  .locationInfo!
                                                  .googleSearchResponses
                                                  .first
                                                  .structuredFormatting
                                                  ?.mainText ??
                                              "",
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF444444),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Space.h(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x143E79A1),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  (widget.lobby.priceDetails?.price != 0.0)
                                      ? 'Refund & Cancellation : '
                                      : 'Cancellation : ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: const Color(0xFF444444),
                              ),
                            ),
                            TextSpan(
                              text:
                                  (widget.lobby.priceDetails?.price != 0.0)
                                      ? 'Available up to 2 days before the lobby.'
                                      : 'Cancel at any time with no hassle',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Poppins',
                                color: const Color(0xFF444444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Space.h(height: 24),
              if (pricingData != null && pricingData.code == 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFBBBCBD),
                      width: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DesignText(
                        text: 'Pricing Details',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF323232),
                      ),
                      Space.h(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DesignText(
                            text: 'Total Amount',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF444444),
                          ),
                          DesignText(
                            text: '₹ ${pricingData.total}',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                      if (widget.lobby.priceTierList != null &&
                          widget.lobby.priceTierList!.isNotEmpty) ...[
                        Space.h(height: 16),
                        DesignText(
                          text: 'Price Tiers',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF444444),
                        ),
                        Space.h(height: 8),
                        ...widget.lobby.priceTierList!.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final tier = entry.value;
                          final isCurrentTier =
                              pricingData.currentPosition != null &&
                              pricingData.currentPosition == index;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DesignText(
                                  text:
                                      "${tier.minSlots} - ${tier.maxSlots} slots",
                                  fontSize: 12,
                                  fontWeight:
                                      isCurrentTier
                                          ? FontWeight.w800
                                          : FontWeight.w400,
                                  color:
                                      isCurrentTier
                                          ? Colors.green
                                          : const Color(0xFF444444),
                                ),
                                DesignText(
                                  text: "₹ ${tier.price}",
                                  fontSize: 12,
                                  fontWeight:
                                      isCurrentTier
                                          ? FontWeight.w800
                                          : FontWeight.w400,
                                  color:
                                      isCurrentTier
                                          ? Colors.green
                                          : const Color(0xFF323232),
                                ),
                              ],
                            ),
                          );
                        }),
                        Space.h(height: 12),
                      ],
                      if (pricingData.isTieredPriced != null &&
                          pricingData.isTieredPriced == true) ...[
                        DesignText(
                          text: 'Pricing Details',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF323232),
                        ),
                        Space.h(height: 4),
                        DesignText(
                          text: pricingData.priceBreakdown ?? "",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF323232),
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                        //  Space(height: 12),
                      ],
                    ],
                  ),
                ),
                Space.h(height: 24),
              ],
              if (widget.lobby.lobbyType != 'PRIVATE') ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0x143E79A1),
                  child: Container(
                    width: 1 * sw,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            ref.read(counterProvider.notifier).decrement();
                            ref.read(selectedOfferProvider.notifier).state =
                                null;
                            if (formList.isNotEmpty) {
                              formList.removeLast();
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: DesignColors.accent,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            await ref
                                .read(pricingProvider(widget.lobby.id).notifier)
                                .updateGroupSize(widget.lobby.id, count - 1);

                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: DesignColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 0.6 * sw,
                          child: TextField(
                            enabled: (widget.lobby.isFormMandatory == false),
                            controller: TextEditingController(
                              text: count.toString(),
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF444444),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onSubmitted: (value) async {
                              final newCount = int.tryParse(value) ?? 0;
                              ref
                                  .read(counterProvider.notifier)
                                  .setValue(newCount);

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: DesignColors.accent,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              await ref
                                  .read(
                                    pricingProvider(widget.lobby.id).notifier,
                                  )
                                  .updateGroupSize(widget.lobby.id, newCount);

                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ),
                        // DesignText(
                        //   text: count.toString(),
                        //   fontSize: 14,
                        //   fontWeight: FontWeight.w600,
                        //   color: const Color(0xFF444444),
                        // ),
                        InkWell(
                          onTap: () async {
                            ref.read(counterProvider.notifier).increment();
                            ref.read(selectedOfferProvider.notifier).state =
                                null;
                            if (widget.formModel != null) {
                              if (ref.read(formsListProvider).isEmpty) {
                                ref
                                    .read(formsListProvider.notifier)
                                    .addForm(widget.formModel!);
                              } else {
                                final clearedForm = widget.formModel!.copyWith(
                                  questions:
                                      widget.formModel!.questions
                                          .map((q) => q.copyWith(answer: ''))
                                          .toList(),
                                );

                                ref
                                    .read(formsListProvider.notifier)
                                    .addForm(clearedForm);
                              }
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: DesignColors.accent,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            await ref
                                .read(pricingProvider(widget.lobby.id).notifier)
                                .updateGroupSize(widget.lobby.id, count + 1);

                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: DesignColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Space.h(height: 24),
              ],
              Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFBBBCBD),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text:
                          (widget.lobby.priceDetails?.price != 0.0)
                              ? "Price details"
                              : "Order Summary",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF444444),
                    ),
                    Space.h(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DesignText(
                                  text: "Lobby Charges",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                ),
                                DesignText(
                                  text:
                                      "₹ ${calculateTotalPrice(pricingData: pricingData, selectedOffer: selectedOffer)}",
                                  // text: (pricingData?.isTieredPriced != null &&
                                  //         pricingData?.isTieredPriced == true)
                                  //     ? "₹ ${(pricingData?.currentPricePerSlot ?? widget.lobby.priceDetails.price)}"
                                  //     : (widget.lobby.priceDetails?.price !=
                                  //             0.0)
                                  //         ? "₹ ${(widget.lobby.priceDetails?.price)}"
                                  //         : "Free",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF323232),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DesignText(
                                  text: "Slots booked",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF323232),
                                ),
                                DesignText(
                                  text: count.toString(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF323232),
                                ),
                              ],
                            ),
                          ),
                          if (widget.lobby.priceDetails?.price != 0.0) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DesignText(
                                    text: "Discount",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF323232),
                                  ),
                                  DesignText(
                                    text:
                                        "- ₹ ${calculateDiscount(pricingData: pricingData, selectedOffer: selectedOffer)}",
                                    // text:
                                    //     "- ₹ ${(selectedOffer != null) ? "${count * ((widget.lobby.priceDetails?.price ?? 0.0) - (selectedOffer.discountedPrice))}" : "0.0"}",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        (selectedOffer != null)
                                            ? DesignColors.accent
                                            : const Color(0xFF323232),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DesignText(
                                    text: "Tax",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF323232),
                                  ),
                                  DesignText(
                                    text: "₹ 0.0",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF323232),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Color(0xFFBBBCBD),
                              thickness: 0.4,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DesignText(
                                    text: "Total",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF323232),
                                  ),
                                  DesignText(
                                    text:
                                        "₹ ${calculateTotalPrice(pricingData: pricingData, selectedOffer: selectedOffer)}",
                                    // text: (pricingData?.isTieredPriced !=
                                    //             null &&
                                    //         pricingData?.isTieredPriced == true)
                                    //     ? (selectedOffer?.discountedPrice !=
                                    //             null)
                                    //         ? "₹ ${pricingData?.total ?? (count * (pricingData?.currentPricePerSlot ?? widget.lobby.priceDetails?.price ?? 0.0)) - (pricingData?.total ?? (count * (pricingData?.currentPricePerSlot ?? widget.lobby.priceDetails?.price ?? 0.0)) - (count * (selectedOffer?.discountedPrice ?? 0.0)))}"
                                    //         : "₹ ${pricingData?.total ?? (count * (pricingData?.currentPricePerSlot ?? widget.lobby.priceDetails?.price ?? 0.0))}"
                                    //     : (widget.lobby.priceDetails?.price !=
                                    //             0.0)
                                    //         ? (selectedOffer?.discountedPrice !=
                                    //                 null)
                                    //             ? "₹ ${(count * (widget.lobby.priceDetails?.price ?? 0.0)) - (count * ((widget.lobby.priceDetails?.price ?? 0.0) - (selectedOffer?.discountedPrice ?? 0.0)))}"
                                    //             : "₹ ${count * (widget.lobby.priceDetails?.price ?? 0.0)}"
                                    //         : "₹ 0.0",
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF323232),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.lobby.priceDetails?.price != 0.0) ...[
                Space.h(height: 24),
                GestureDetector(
                  onTap:
                      () => Get.toNamed(
                        AppRoutes.applyOffers.replaceAll(
                          ':lobbyId',
                          widget.lobby.id,
                        ),
                      ),
                  child: Card(
                    elevation: 4,
                    shadowColor: const Color(0x143E79A1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        gradient: LinearGradient(
                          // transform: const TranslationGradientTransform(
                          //     offset: Offset(10, 0)),
                          transform: const CustomGradientTransform(scale: 4),
                          begin: const Alignment(-1, -0.02),
                          end: const Alignment(1, 0.02),
                          // 91.16deg is approximately the same as going from left to right
                          colors: [
                            Colors.white.withOpacity(0.8),
                            const Color(0x14EC4A5D),
                          ],
                          stops: const [
                            0.0986,
                            0.949,
                          ], // Corresponding to 1.86% and 94.9%
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          DesignIcon.icon(
                            icon: Icons.local_offer_outlined,
                            color: const Color(0xFFEC4B5D),
                          ),
                          Space.w(width: 14),
                          DesignText(
                            text: "Apply Offers",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF323232),
                          ),
                          const Spacer(),
                          if (selectedOffer != null) ...[
                            DesignText(
                              text:
                                  "${selectedOffer.discountValue} ${(selectedOffer.discountType == 'PERCENTAGE') ? "%" : "INR"}",
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF323232),
                            ),
                            Space.w(width: 16),
                          ],
                          DesignIcon.icon(
                            icon: Icons.arrow_forward_ios_rounded,
                            color: const Color(0xFFEC4B5D),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (formList.isNotEmpty) ...[
                Space.h(height: 24),
                // if (widget.formModel != null)
                //   formCard(
                //     tileText: "Your form response",
                //     formIndex: 0,
                //   ),
                if (count > 0)
                  ...List.generate(count, (index) {
                    if (index == 0) {
                      return formCard(
                        tileText: "Your form response",
                        formIndex: 0,
                      );
                    }
                    return formCard(
                      tileText: "Form for slot ${index + 1}",
                      formIndex: index,
                    );
                  }),
              ],
              Space.h(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white,
                elevation: 8,
                shadowColor: const Color(0x143E79A1),
                child: Container(
                  width: 1 * sw,
                  // height: 180,
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DesignText(
                        text: "User Details ",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF323232),
                      ),
                      Space.h(height: 18),
                      DesignText(
                        text: profileController.profileData.value?.name ?? "",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF323232),
                      ),
                      Space.h(height: 4),
                      DesignText(
                        text: profileController.profileData.value?.email ?? "",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF323232),
                      ),
                      Space.h(height: 4),
                      DesignText(
                        text:
                            profileController.profileData.value?.userName ?? "",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF323232),
                      ),
                    ],
                  ),
                ),
              ),
              // if (widget.lobby.priceDetails?.price != 0.0) ...[
              //   Space(height: 24),
              //   Card(
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(24)),
              //     color: Colors.white,
              //     elevation: 8,
              //     shadowColor: const Color(0x143E79A1),
              //     child: Container(
              //       width: 1.sw,
              //       // height: 180,
              //       padding:
              //           EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              //       child: DottedBorder(
              //         color: const Color(0xFFBBBCBD),
              //         strokeWidth: 0.6,
              //         radius: Radius.circular(12),
              //         dashPattern: const [6, 3],
              //         borderType: BorderType.RRect,
              //         child: Container(
              //           padding: EdgeInsets.all(10),
              //           child: Row(
              //             children: [
              //               const Icon(
              //                 Icons.add_circle_outline_rounded,
              //                 color: Color(0xFF3E79A1),
              //               ),
              //               Space(width: 18),
              //               DesignText(
              //                 text: "Add new card",
              //                 fontSize: 12,
              //                 fontWeight: FontWeight.w500,
              //                 color: const Color(0xFF3E79A1),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
              Space.h(height: 24),
              const EventGuidelinesGrid(),
              Space.h(height: 48),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    DesignIcon.icon(
                      icon: Icons.info_outline_rounded,
                      color: const Color(0xFF3E79A1),
                    ),
                    Space.w(width: 8),
                    Expanded(
                      child: DesignText(
                        text:
                            'By Proceeding,  I express my consent to complete this transaction and accept lobby joining guideline.',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF444444),
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formCard({required String tileText, required int formIndex}) {
    final isExpanded = ref.watch(expandStateProvider(tileText));

    return GestureDetector(
      onTap: () {
        ref.read(expandStateProvider(tileText).notifier).toggle();
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(
          bottom:
              (formIndex == ref.watch(formsListProvider).length - 1) ? 0 : 16,
        ),
        shadowColor: const Color(0x143E79A1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isExpanded ? Colors.white : const Color(0xFFF9F9F9),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  DesignIcon.icon(
                    icon: Icons.description_outlined,
                    color: const Color(0xFFEC4B5D),
                  ),
                  Space.w(width: 14),
                  DesignText(
                    text: tileText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF323232),
                  ),
                  const Spacer(),
                  DesignIcon.icon(
                    icon:
                        isExpanded
                            ? Icons.expand_less
                            : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFEC4B5D),
                    size: 16,
                  ),
                ],
              ),
              if (isExpanded) ...[
                Space.h(height: 16),
                _buildFormQuestions(formIndex: formIndex),
                Space.h(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormQuestions({required int formIndex}) {
    final formNotifier = ref.read(formsListProvider.notifier);
    final formListData = ref.watch(formsListProvider);
    final formData = formListData[formIndex];
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form title
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: DesignText(
        //     text: formState.title,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),

        // Form questions
        Padding(
          // constraints: BoxConstraints(maxHeight: 0.6.sh),
          padding: EdgeInsets.only(bottom: 0.1 * sh),
          child:
              formData.questions.isEmpty
                  ? FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 2500)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC4B5D),
                          ),
                        );
                      } else {
                        return Center(
                          child: DesignText(
                            text: "No questions found",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                          ),
                        );
                      }
                    },
                  )
                  : Column(
                    children: List.generate(formData.questions.length, (index) {
                      final question = formData.questions[index];

                      // Text question
                      if (question.questionType == 'text') {
                        final controller = formNotifier
                            .getControllerForQuestion(formIndex, question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    // maxLines: 5,
                                    fontSize: 12,
                                    onChanged:
                                        (val) => formNotifier.updateAnswer(
                                          formIndex,
                                          question.id,
                                          val!,
                                        ),
                                    borderRadius: 16,
                                  ),
                                  // const SizedBox(height: 8),
                                  // TextFormField(
                                  //   controller: controller,
                                  //   decoration: const InputDecoration(
                                  //     labelText: "Answer",
                                  //     border: OutlineInputBorder(),
                                  //   ),
                                  //   onChanged: (val) => formNotifier.updateAnswer(
                                  //       question.id, val,),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Multiple choice question
                      else if (question.questionType == 'multiple-choice') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  ...question.options.map((option) {
                                    return CheckboxListTile(
                                      title: DesignText(
                                        text: option,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF444444),
                                      ),
                                      value: question.answer == option,
                                      onChanged: (val) {
                                        if (val != null && val) {
                                          formNotifier.updateAnswer(
                                            formIndex,
                                            question.id,
                                            option,
                                          );
                                        }
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 0,
                                          ),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      dense: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Default fallback for unsupported question types
                      return Container();
                    }),
                  ),
        ),
      ],
    );
  }

  String calculateTotalPrice({
    required PricingResponse? pricingData,
    Offer? selectedOffer,
  }) {
    double total = pricingData?.total ?? 0.0;
    if (selectedOffer != null) {
      if (selectedOffer.discountType == 'PERCENTAGE') {
        // double percentage = selectedOffer.discountValue;
        double discount = double.parse(
          calculateDiscount(
            pricingData: pricingData,
            selectedOffer: selectedOffer,
          ),
        );
        total = total - discount;
      } else if (selectedOffer.discountType == 'FLAT') {
        total = total - selectedOffer.discountValue;
      }
    }

    return total.toString();
  }

  String calculateDiscount({
    required PricingResponse? pricingData,
    Offer? selectedOffer,
  }) {
    double discount = 0.0;
    double total = pricingData?.total ?? 0.0;
    if (selectedOffer != null) {
      if (selectedOffer.discountType == 'PERCENTAGE') {
        double percentage = selectedOffer.discountValue;
        discount = (total * percentage) / 100;
      } else if (selectedOffer.discountType == 'FLAT') {
        discount = selectedOffer.discountValue;
      }
    }

    return discount.toString();
  }
}

class GuidelineCard extends StatelessWidget {
  final String title;
  final String description;
  final DesignIcons icon;

  const GuidelineCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF989898), width: 0.2),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
            color: Color(0x0A3E79A1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DesignIcon.custom(
                icon: icon,
                size: 32,
                color: const Color(0xFF323232),
              ),
              SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: DesignText(
                  text: title,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E79A1),
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 4),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: DesignText(
                    text: description,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF444444),
                    maxLines: 5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EventGuidelinesGrid extends StatelessWidget {
  const EventGuidelinesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final guidelines = [
      {
        'title': 'Respect the Space & People',
        'description':
            'Be mindful of the venue, hosts, and fellow attendees. Harassment or disruptive behavior won\'t be tolerated.',
        'icon': DesignIcons.respect,
      },
      {
        'title': 'No Last-Minute Dropouts',
        'description':
            'If you can\'t make it, cancel in advance. No-shows may affect your ability to join future events.',
        'icon': DesignIcons.doorOut,
      },
      {
        'title': 'Punctuality Matters',
        'description':
            'Arrive on time to avoid missing key moments and to ensure a smooth experience for everyone.',
        'icon': DesignIcons.thumbClock,
      },
      {
        'title': 'Follow Event Guidelines',
        'description':
            'Dress code, smoking/alcohol policies, and other house rules must be respected.',
        'icon': DesignIcons.law,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 350 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio:
                1.2, // Adjust this value to control card height relative to width
          ),
          itemCount: guidelines.length,
          itemBuilder: (context, index) {
            final guideline = guidelines[index];
            return GuidelineCard(
              title: guideline['title'].toString(),
              description: guideline['description'].toString(),
              icon: guideline['icon'] as DesignIcons,
            );
          },
        );
      },
    );
  }
}

class TranslationGradientTransform extends GradientTransform {
  final Offset offset;

  const TranslationGradientTransform({required this.offset});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // This applies a translation transformation to the gradient.
    return Matrix4.translationValues(offset.dx, offset.dy, 0);
  }
}

class CustomGradientTransform extends GradientTransform {
  final double scale;

  const CustomGradientTransform({this.scale = 1.0});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // Applies a scaling transformation.
    return Matrix4.diagonal3Values(scale, scale, 1.0);
  }
}
