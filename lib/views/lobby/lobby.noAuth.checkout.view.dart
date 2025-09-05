import 'dart:io' show Platform;
import 'dart:html' as html;
import 'dart:math';
import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/utils.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/models/offers_model.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/appDownloadCard.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/checkout.view.lobby.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/lobby_content_section.dart';
import 'package:aroundu/views/lobby/provider/coupon_provider.dart';
import 'package:aroundu/views/lobby/provider/forms_list_provider.dart';
import 'package:aroundu/views/lobby/provider/get_price_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_register_provider.dart';
import 'package:aroundu/views/lobby/provider/lock_pricing_provider.dart';
import 'package:aroundu/views/lobby/provider/selected_tickets_provider.dart';
import 'package:aroundu/views/lobby/widgets/infoCard.dart';
import 'package:aroundu/views/lobby/widgets/rich_text_display.dart';
import 'package:aroundu/views/offer/apply.offer.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/api_service/api.service.dart';

class LobbyNoAuthCheckoutView extends ConsumerStatefulWidget {
  const LobbyNoAuthCheckoutView({super.key, required this.lobbyId});
  final String lobbyId;

  @override
  ConsumerState<LobbyNoAuthCheckoutView> createState() => _LobbyNoAuthCheckoutViewState();
}

// Counter provider for managing number of slots
final quickCheckoutCounterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// Provider to track expanded state of location sections
final isLocationsExpandedProvider = StateProvider.family<bool, String>((ref, lobbyId) => false);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(1);

  void increment() => state++;
  void decrement() {
    if (state > 1) {
      state--;
    }
  }

  void setValue(int value) {
    state = value;
  }
}

class _LobbyNoAuthCheckoutViewState extends ConsumerState<LobbyNoAuthCheckoutView> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  late FormModel? formModel;

  @override
  void initState() {
    super.initState();

    // Initialize counter with 1
    ref.read(quickCheckoutCounterProvider.notifier).setValue(1);

    // Add listeners to text controllers
    _nameController.addListener(_updateFormFromControllers);
    _emailController.addListener(_updateFormFromControllers);
    _mobileController.addListener(_updateFormFromControllers);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      kLogger.error('Flutter Error: ${details.exception}');
      kLogger.error('Stack trace: ${details.stack}');
    };

    Future.microtask(() async {
      ref.read(selectedOfferProvider.notifier).state = null;
      await ref
          .read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier)
          .fetchLobbyQuickCheckoutDetails(widget.lobbyId);
      await ref.read(formStateProvider(widget.lobbyId).notifier).loadFormData([]);
      await ref
          .read(pricingProvider(widget.lobbyId).notifier)
          .fetchPricing(widget.lobbyId, groupSize: 1, selectedTickets: [], isPublic: true);
      final formState = ref.watch(formStateProvider(widget.lobbyId));
      ref.read(formsListProvider.notifier).resetFormsList();
      formModel = formState;

      if (formState != null) {
        if (ref.read(formsListProvider).isEmpty) {
          ref.read(formsListProvider.notifier).addForm(formState!);
        }
      }
      ref.read(selectedTicketsProvider.notifier).clearAll();
    });
    _couponController.addListener(() {
      final text = _couponController.text;
      ref.read(couponProvider.notifier).updateCouponCode(text);

      // If text is empty, clear the selected offer
      if (text.isEmpty) {
        ref.read(selectedOfferProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateFormFromControllers);
    _emailController.removeListener(_updateFormFromControllers);
    _mobileController.removeListener(_updateFormFromControllers);
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // Method to update form when controller values change
  void _updateFormFromControllers() {
    final formNotifier = ref.read(formsListProvider.notifier);
    final formListData = ref.read(formsListProvider);

    if (formListData.isNotEmpty) {
      FormModel formData = formListData[0];
      formData = formData.copyWith(
        questions:
            formData.questions.map((e) {
              if (e.dataKey == 'name' || e.questionText.toLowerCase().trim().contains("name")) {
                return e.copyWith(answer: _nameController.text);
              } else if (e.dataKey == 'email' || e.questionText.toLowerCase().trim().contains("email")) {
                return e.copyWith(answer: _emailController.text);
              } else if (e.dataKey == 'mobile' ||
                  e.questionText.toLowerCase().trim().contains("contact") ||
                  e.questionText.toLowerCase().trim().contains("phone") ||
                  e.questionText.toLowerCase().trim().contains("mobile")) {
                return e.copyWith(answer: _mobileController.text);
              } else {
                return e;
              }
            }).toList(),
      );
      formNotifier.updateForm(0, formData);
    }
  }

  // Method to handle checkout process
  void _handleCheckout(Lobby lobbyData, double totalPrice) async {
    final formList = ref.read(formsListProvider);
    final isFormValidated = ref.watch(formsListProvider.notifier).validateAllForms();
    final selectedTickets = ref.watch(selectedTicketsProvider);
    final currentLobbyTickets = selectedTickets[widget.lobbyId] ?? [];
    // Get the number of slots from the counter provider
    final slotCount = ref.read(quickCheckoutCounterProvider);

    // Call the lobby registration provider
    final registrationNotifier = ref.read(lobbyRegistrationProvider(widget.lobbyId).notifier);

    await ref
        .read(pricingProvider(lobbyData.id).notifier)
        .fetchPricing(lobbyData.id, groupSize: slotCount, selectedTickets: currentLobbyTickets, isPublic: true);

    final getPricingData = ref.read(pricingProvider(lobbyData.id));
    kLogger.trace("getPricingData : ${getPricingData.pricingData?.toJson()}");
    if (getPricingData.pricingData == null) {
      CustomSnackBar.show(
        context: context,
        message: getPricingData.pricingData?.message ?? 'Something went wrong!',
        type: SnackBarType.error,
      );
      return;
    } else if (getPricingData.pricingData?.status != 'SUCCESS' || getPricingData.pricingData?.total != totalPrice) {
      CustomSnackBar.show(
        context: context,
        message:
            getPricingData.pricingData?.message ??
            'Something went wrong!, Please refresh the page and try again later.',
        type: SnackBarType.error,
      );
      return;
    }
    // Check if the form fields are valid
    if (!_formKey.currentState!.validate()) return;

    // Check if name is empty
    if (_nameController.text.isEmpty) {
      CustomSnackBar.show(context: context, message: 'Please enter your name', type: SnackBarType.warning);
      return;
    }

    // Check if email is empty
    if (_emailController.text.isEmpty) {
      CustomSnackBar.show(context: context, message: 'Please enter your email', type: SnackBarType.warning);
      return;
    }

    // Check if email is valid
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      CustomSnackBar.show(context: context, message: 'Please enter a valid email address', type: SnackBarType.warning);
      return;
    }

    // Check if mobile number is empty
    if (_mobileController.text.isEmpty) {
      CustomSnackBar.show(context: context, message: 'Please enter your mobile number', type: SnackBarType.warning);
      return;
    }

    // Check if mobile number is valid (10 digits)
    if (_mobileController.text.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(_mobileController.text)) {
      CustomSnackBar.show(
        context: context,
        message: 'Please enter a valid 10-digit mobile number',
        type: SnackBarType.warning,
      );
      return;
    }

    if (isFormValidated != null) {
      String message = isFormValidated;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            content: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                    child: Icon(Icons.warning_rounded, color: Colors.red, size: 32),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Required Fields Missing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    message, // Display the validation message
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (lobbyData.isAdvancedPricing && currentLobbyTickets.isEmpty) {
      CustomSnackBar.show(context: context, message: 'Please select at least one ticket', type: SnackBarType.error);
      return;
    }
    String userId =
        '${Random().nextInt(16777215).toRadixString(16)}${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
    // Lock the pricing after updating group size
    await ref
        .read(lockPricingProvider(lobbyData.id).notifier)
        .lockPricing(lobbyData.id, slotCount, currentLobbyTickets, userId: userId, isPublic: true);

    // Check if lock pricing failed and show toast with error message
    final lockPricingData = ref.read(lockPricingDataProvider(lobbyData.id));
    kLogger.trace("lockPricingData : ${lockPricingData?.toJson()}");
    if (lockPricingData != null && lockPricingData.status != 'SUCCESS') {
      Get.back();
      CustomSnackBar.show(
        context: context,
        message: lockPricingData.message ?? 'Something went wrong!',
        type: SnackBarType.error,
      );

      return;
    } else if ((totalPrice != getPricingData.pricingData?.total) ||
        (totalPrice != lockPricingData?.total) ||
        (getPricingData.pricingData?.total != lockPricingData?.total)) {
      Get.back();
      CustomSnackBar.show(
        context: context,
        message: 'Please check out again as the price has been updated for your slots.',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    registrationNotifier
        .registerGuest(
          lobbyId: widget.lobbyId,
          name: _nameController.text,
          mobile: _mobileController.text,
          email: _emailController.text,
          slots: slotCount,
          userId: userId,

          form: (formList.isNotEmpty ? formList.first : formModel)?.toJson() ?? {},
          formList: (formList.isNotEmpty ? formList.sublist(1) : formList).map((form) => form.toJson()).toList() ?? [],
          selectedTickets: currentLobbyTickets.isNotEmpty ? currentLobbyTickets.map((e) => e.toJson()).toList() : null,
          offerId: ref.read(selectedOfferProvider)?.offerId,
        )
        .then((response) async {
          setState(() {
            _isProcessing = false;
          });

          if (response != null && response.paymentUrl != null) {
            // Show success message
            CustomSnackBar.show(
              context: context,
              message: 'Registration successful! Redirecting to payment...',
              type: SnackBarType.success,
            );

            // Redirect to payment URL
            await _redirectToPaymentUrl(response.paymentUrl!);
          } else {
            // Show error message
            CustomSnackBar.show(
              context: context,
              message: 'Failed to register. Please try again.',
              type: SnackBarType.error,
            );
          }
        })
        .catchError((error) {
          setState(() {
            _isProcessing = false;
          });

          // Show error message
          CustomSnackBar.show(context: context, message: 'Error: ${error.toString()}', type: SnackBarType.error);
        });
  }

  // Method to redirect to payment URL
  Future<void> _redirectToPaymentUrl(String url) async {
    if (url == "FREE_EVENT_JOINED") {
      await Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/success_badge.json',
                      repeat: false,
                      fit: BoxFit.fitHeight,
                      height: 0.2 * Get.height,
                      width: 0.9 * Get.width,
                    ),
                    Space.h(height: 8),
                    DesignText(
                      text: "  Congratulations 🎉",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF323232),
                    ),
                    Space.h(height: 8),
                    DesignText(
                      text: "you have successfully joined the lobby",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                    Space.h(height: 8),
                    DesignText(
                      text:
                          "A detailed confirmation email will be sent to your registered email address, including important event information, venue details, and your unique booking reference. Please check your inbox (and spam folder) within the next few minutes.",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: DesignColors.secondary,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Lottie.asset(
                'assets/animations/confetti.json',
                repeat: false,
                fit: BoxFit.fill,
                // height: 0.8.sw,
              ),
            ],
          ),
        ),
        barrierDismissible: true,
      );
      Fluttertoast.showToast(msg: "successfully joined the lobby");
      FancyAppDownloadDialog.show(
        context,
        title: "Unlock Premium Features",
        message:
            "To chat with fellow attendees, see who’s coming, and discover exciting new updates — download the app.",
        appStoreUrl: "https://apps.apple.com/in/app/aroundu/id6744299663",
        playStoreUrl: "https://play.google.com/store/apps/details?id=com.polar.aroundu",
        cancelButtonText: "Not Now",
        onCancel: () {
          Get.toNamed(AppRoutes.lobby.replaceAll(":lobbyId", widget.lobbyId));
        },
      );
      return;
    }

    // Use the url_launcher package to open the URL
    // For web, we can use window.open
    if (kIsWeb) {
      html.window.open(url, 'checkout');
    } else {
      // For mobile, we would use url_launcher
      // But for now, just show a message
      CustomSnackBar.show(context: context, message: 'Payment URL: $url', type: SnackBarType.info);
    }
  }

  // Build the desktop layout with side-by-side content
  Widget _buildDesktopLayout(BuildContext context, Lobby lobbyData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side with lobby details
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildLobbyDetailsCard(context, lobbyData),
                      _buildAdditionalLobbyDetails(context, lobbyData),
                    ],
                  ),
                ),
              ),

              // Checkout form section - takes 50% of the width
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildCheckoutForm(context, lobbyData),
                    ResponsiveAppDownloadCard(
                      appStoreUrl: "https://apps.apple.com/in/app/aroundu/id6744299663",
                      playStoreUrl: "https://play.google.com/store/apps/details?id=com.polar.aroundu",
                      description:
                          "AroundU is more than just this event. Check out other events, join the group chat, or start your own lobby!",
                      // onClose: () {
                      //   FancyAppDownloadDialog.show(
                      //     context,
                      //     title: "Unlock Premium Features",
                      //     message:
                      //         "Get the full AroundU experience with exclusive features, enhanced performance, and more!",
                      //     appStoreUrl: "https://apps.apple.com/in/app/aroundu/id6744299663",
                      //     playStoreUrl: "https://play.google.com/store/apps/details?id=com.polar.aroundu",
                      //     // cancelButtonText: "Maybe Later",
                      //     onCancel: () {
                      //       print("User chose to skip download");
                      //     },
                      //   );
                      // },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the mobile layout with stacked content
  Widget _buildMobileLayout(BuildContext context, Lobby lobbyData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lobby details card
          _buildLobbyDetailsCard(context, lobbyData),

          // Checkout form
          _buildCheckoutForm(context, lobbyData),
          ResponsiveAppDownloadCard(
            appStoreUrl: "https://apps.apple.com/in/app/aroundu/id6744299663",
            playStoreUrl: "https://play.google.com/store/apps/details?id=com.polar.aroundu",
            description:
                "AroundU is more than just this event. Check out other events, join the group chat, or start your own lobby!",
            // onClose: () {
            //   FancyAppDownloadDialog.show(
            //     context,
            //     title: "Unlock Premium Features",
            //     message:
            //         "Get the full AroundU experience with exclusive features, enhanced performance, and more!",
            //     appStoreUrl: "https://apps.apple.com/in/app/aroundu/id6744299663",
            //     playStoreUrl: "https://play.google.com/store/apps/details?id=com.polar.aroundu",
            //     // cancelButtonText: "Maybe Later",
            //     onCancel: () {
            //       print("User chose to skip download");
            //     },
            //   );
            // },
          ),
          // Additional lobby details for mobile view
          _buildAdditionalLobbyDetails(context, lobbyData),
        ],
      ),
    );
  }

  // Build additional lobby details section for mobile view
  Widget _buildAdditionalLobbyDetails(BuildContext context, Lobby lobbyData) {
    return Container(
      padding: EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Card(
          elevation: 0,
          color: DesignColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignText(
                  text: 'Additional Details',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
                SizedBox(height: 16),

                // Date and time info if available
                if (lobbyData.filter?.otherFilterInfo?.dateInfo != null) ...[
                  _buildInfoItem(
                    lobbyData.filter!.otherFilterInfo!.dateInfo!.iconUrl ?? "",
                    lobbyData.filter!.otherFilterInfo!.dateInfo!.title,
                    lobbyData.filter!.otherFilterInfo!.dateInfo!.formattedDate ?? "",
                  ),
                  SizedBox(height: 12),
                ],

                // Date range info if available
                if (lobbyData.filter?.otherFilterInfo?.dateRange != null) ...[
                  _buildInfoItem(
                    lobbyData.filter!.otherFilterInfo!.dateRange!.iconUrl ?? "",
                    lobbyData.filter!.otherFilterInfo!.dateRange!.title,
                    lobbyData.filter!.otherFilterInfo!.dateRange!.formattedDateCompactView ?? "",
                  ),
                  SizedBox(height: 12),
                ],

                // Location info if available
                if (lobbyData.filter?.otherFilterInfo?.pickUp != null) ...[
                  _buildInfoItem(
                    lobbyData.filter!.otherFilterInfo!.pickUp!.iconUrl ?? "",
                    lobbyData.filter!.otherFilterInfo!.pickUp!.title ?? "",
                    lobbyData.filter!.otherFilterInfo!.pickUp!.locationResponse?.areaName ?? "",
                  ),
                  SizedBox(height: 12),
                ],

                // Destination info if available
                if (lobbyData.filter?.otherFilterInfo?.destination != null) ...[
                  _buildInfoItem(
                    lobbyData.filter!.otherFilterInfo!.destination!.iconUrl ?? "",
                    lobbyData.filter!.otherFilterInfo!.destination!.title ?? "",
                    lobbyData.filter!.otherFilterInfo!.destination!.locationResponse?.areaName ?? "",
                  ),
                  SizedBox(height: 12),
                ],

                // Location info with map link if available
                if (lobbyData.filter?.otherFilterInfo?.locationInfo != null) ...[
                  Divider(height: 24, color: Colors.grey.shade200),
                  DesignText(text: 'Location', fontSize: 16, fontWeight: FontWeight.w600, color: DesignColors.primary),
                  SizedBox(height: 8),
                  _buildLocationInfoItem(context, lobbyData),
                  SizedBox(height: 16),
                ],

                // Multiple locations if available
                if (lobbyData.filter?.otherFilterInfo?.multipleLocations != null) ...[
                  Divider(height: 24, color: Colors.grey.shade200),
                  DesignText(
                    text: lobbyData.filter!.otherFilterInfo!.multipleLocations?.title ?? 'Multiple Locations',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                  SizedBox(height: 8),
                  _buildLocationSection(lobbyData),
                  SizedBox(height: 16),
                ],

                // Scrollable info cards
                Divider(height: 24, color: Colors.grey.shade200),
                DesignText(
                  text: 'Lobby Information',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.primary,
                ),
                SizedBox(height: 12),
                _buildScrollableInfoCards(lobbyData),
                SizedBox(height: 16),

                // Host information
                Divider(height: 24, color: Colors.grey.shade200),
                DesignText(text: 'Host', fontSize: 16, fontWeight: FontWeight.w600, color: DesignColors.primary),
                SizedBox(height: 12),
                _buildHostInfo(lobbyData),
                SizedBox(height: 16),

                // Filter information if available
                if (lobbyData.filter?.filterInfoList != null && lobbyData.filter!.filterInfoList!.isNotEmpty) ...[
                  Divider(height: 24, color: Colors.grey.shade200),
                  DesignText(
                    text: 'Preferences',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                  SizedBox(height: 12),
                  _buildFilterInfoList(context, lobbyData),
                  SizedBox(height: 16),
                ],
                // Space.h(height: 34),
                Divider(height: 24, color: Colors.grey.shade200),
                Row(
                  children: [
                    if (lobbyData.content != null)
                      DesignText(
                        text: lobbyData.content?.title ?? "Guidelines",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                  ],
                ),
                if (lobbyData.content != null) ...[
                  Space.h(height: 16),
                  NewLobbyContentSection(content: lobbyData.content!, height: 356),
                ],
                Space.h(height: 16),

                // Lobby status
                Divider(height: 24, color: Colors.grey.shade200),
                _buildStatusItem(lobbyData.lobbyStatus ?? "ACTIVE"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build info item with icon, title and subtitle
  Widget _buildInfoItem(String iconUrl, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 1))],
          ),
          child: Image.network(
            iconUrl,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.info_outline, size: 24, color: DesignColors.primary);
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DesignText(text: title, fontSize: 16, fontWeight: FontWeight.w500, color: DesignColors.primary),
              SizedBox(height: 4),
              DesignText(text: subtitle, fontSize: 14, color: DesignColors.secondary),
            ],
          ),
        ),
      ],
    );
  }

  // Build status item
  Widget _buildStatusItem(String status) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case "UPCOMING":
        statusColor = Color(0xFF52D17C);
        statusText = "Upcoming";
        statusIcon = Icons.run_circle_outlined;
        break;
      case "PAST":
        statusColor = Color(0xFFF97853);
        statusText = "Past";
        statusIcon = Icons.event_busy;
        break;
      case "CLOSED":
        statusColor = Color(0xFF3E79A1);
        statusText = "Closed";
        statusIcon = Icons.lock_outline;
        break;
      case "FULL":
        statusColor = Color(0xFFF97853);
        statusText = "Full";
        statusIcon = Icons.people;
        break;
      default: // ACTIVE
        statusColor = Color(0xFF52D17C);
        statusText = "Active";
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: statusColor),
          SizedBox(width: 8),
          DesignText(text: statusText, fontSize: 14, fontWeight: FontWeight.w600, color: statusColor),
        ],
      ),
    );
  }

  // Helper method to build location info with map link
  Widget _buildLocationInfoItem(BuildContext context, Lobby lobbyData) {
    final locationInfo = lobbyData.filter?.otherFilterInfo?.locationInfo;

    return GestureDetector(
      onTap: () async {
        print("object");
        double lat = 0.0;
        double lng = 0.0;

        if (locationInfo != null && locationInfo!.locationResponses.isNotEmpty) {
          if ((locationInfo!.hideLocation) && (lobbyData.userStatus != "MEMBER")) {
            lat = locationInfo?.locationResponses.first.approxLocation?.lat ?? 0.0;
            lng = locationInfo?.locationResponses.first.approxLocation?.lon ?? 0.0;
          } else {
            lat = locationInfo?.locationResponses.first.exactLocation?.lat ?? 0.0;
            lng = locationInfo?.locationResponses.first.exactLocation?.lon ?? 0.0;
          }
        }

        // Only proceed if we have valid coordinates
        if (lat != 0.0 || lng != 0.0) {
          Uri? mapsUri;
          bool launched = false;
          kLogger.trace("lat : $lat \n lng : $lng");

          if (kIsWeb) {
            // For web platform, open Google Maps in new tab
            mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
            html.window.open(mapsUri.toString(), '_blank');
            launched = true;
          } else if (Platform.isAndroid) {
            // Try Android's native maps app first
            mapsUri = Uri.parse('http://maps.google.com/maps?z=12&t=m&q=$lat,$lng');
            if (await canLaunchUrl(mapsUri)) {
              await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
              launched = true;
            }
          } else if (Platform.isIOS) {
            // Try Google Maps on iOS first
            mapsUri = Uri.parse('comgooglemaps://?center=$lat,$lng&zoom=12&q=$lat,$lng');
            if (await canLaunchUrl(mapsUri)) {
              await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
              launched = true;
            } else {
              // Fall back to Apple Maps
              mapsUri = Uri.parse('https://maps.apple.com/?q=${Uri.encodeFull("Location")}&sll=$lat,$lng&z=12');
              if (await canLaunchUrl(mapsUri)) {
                await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                launched = true;
              }
            }
          }

          // If none of the above worked, fall back to web browser
          if (!launched) {
            mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
            try {
              await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
            } catch (e) {
              kLogger.error('Error launching URL: $e');
            }
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Approximate location
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: const Color(0xFF3E79A1)),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DesignText(
                        text: 'Location',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E79A1),
                      ),
                      SizedBox(height: 4),
                      DesignText(
                        text: (locationInfo?.googleSearchResponses.first.description ?? 'Unknown location'),
                        fontSize: 14,
                        maxLines: null,
                        overflow: TextOverflow.visible,

                        color: const Color(0xFF3E79A1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to launch maps
  void _launchMaps(double latitude, double longitude) async {
    final url =
        kIsWeb
            ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
            : Platform.isIOS
            ? 'https://maps.apple.com/?q=$latitude,$longitude'
            : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      print('Could not launch maps: $e');
    }
  }

  // Helper method to build location section with multiple locations
  Widget _buildLocationSection(Lobby lobbyData) {
    final multipleLocations = lobbyData.filter?.otherFilterInfo?.multipleLocations;
    if (multipleLocations == null ||
        multipleLocations.locationResponses == null ||
        multipleLocations.locationResponses!.isEmpty) {
      return SizedBox.shrink();
    }

    // Remove duplicates
    final uniqueLocations = <String>{};
    final filteredLocations =
        multipleLocations.locationResponses!.where((location) {
          final isUnique = !uniqueLocations.contains(location);
          if (isUnique) uniqueLocations.add(location.fuzzyAddress);
          return isUnique;
        }).toList();

    // Determine how many locations to show based on expanded state
    final isExpanded = ref.watch(isLocationsExpandedProvider(lobbyData.id));
    final locationsToShow = isExpanded ? filteredLocations : filteredLocations.take(2).toList();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...locationsToShow.map(
            (location) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: DesignColors.primary),
                  SizedBox(width: 8),
                  Expanded(child: DesignText(text: location.fuzzyAddress, fontSize: 14, color: DesignColors.primary)),
                ],
              ),
            ),
          ),

          // Show more/less button if there are more than 2 locations
          if (filteredLocations.length > 2) ...[
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                ref.read(isLocationsExpandedProvider(lobbyData.id).notifier).state = !isExpanded;
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: DesignColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DesignText(
                      text: isExpanded ? 'Show Less' : 'Show More',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.primary,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: DesignColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to build scrollable info cards
  Widget _buildScrollableInfoCards(Lobby lobbyData) {
    final List<InfoCard> infoCards = [];

    // Add refund policy if available
    if (lobbyData.priceDetails.isRefundAllowed != null) {
      infoCards.add(
        InfoCard(
          icon: Icons.policy_outlined,
          title: 'Refund Policy',
          subtitle: (lobbyData.priceDetails.isRefundAllowed) ? "Refund is available" : "Refund is not available",
        ),
      );
    }

    // Add lobby size if available
    if (lobbyData.totalMembers != null) {
      infoCards.add(
        InfoCard(icon: Icons.people_outline, title: 'Lobby Size', subtitle: '${lobbyData.totalMembers} people'),
      );
    }

    // Add age limit if available
    if (lobbyData.filter.otherFilterInfo.range != null) {
      infoCards.add(
        InfoCard(
          icon: Icons.person_outline,
          title: 'Age Limit',
          subtitle:
              "${lobbyData.filter.otherFilterInfo.range?.min ?? 0} to ${lobbyData.filter.otherFilterInfo.range?.max ?? 0} ",
        ),
      );
    }

    // Add additional info cards as needed

    return infoCards.isEmpty
        ? DesignText(text: 'No additional information available', fontSize: 14, color: DesignColors.primary)
        : ScrollableInfoCards(cards: infoCards);
  }

  // Helper method to build host information
  Widget _buildHostInfo(Lobby lobbyData) {
    final hostName = lobbyData.houseDetail?.name ?? lobbyData.adminSummary?.name ?? 'Host';
    final hostImage = lobbyData.houseDetail?.profilePhoto ?? lobbyData.adminSummary?.profilePictureUrl ?? '';

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // Host profile picture
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: DesignColors.primary.withOpacity(0.1)),
            child:
                hostImage.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        hostImage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: DesignColors.primary);
                        },
                      ),
                    )
                    : Icon(Icons.person, color: DesignColors.primary),
          ),
          SizedBox(width: 12),
          // Host name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignText(text: hostName, fontSize: 16, fontWeight: FontWeight.w600, color: DesignColors.primary),
                DesignText(text: 'Host', fontSize: 14, color: DesignColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build filter info list
  Widget _buildFilterInfoList(BuildContext context, Lobby lobbyData) {
    final filterInfoList = lobbyData.filter?.filterInfoList;
    if (filterInfoList == null || filterInfoList.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ...filterInfoList.asMap().entries.map((entry) {
            final index = entry.key;
            final filterInfo = entry.value;

            return Column(
              children: [
                if (index > 0) Divider(height: 16, thickness: 1, color: Colors.grey.shade200),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child:
                            filterInfo.iconUrl != null && filterInfo.iconUrl!.isNotEmpty
                                ? DesignText(text: filterInfo.iconUrl ?? "", fontSize: 24)
                                : Icon(Icons.info_outline, color: DesignColors.primary, size: 16),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DesignText(
                            text: filterInfo.title ?? 'Information',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignColors.primary,
                          ),
                          SizedBox(height: 4),
                          DesignText(
                            text: filterInfo.options.join(', ') ?? '',
                            fontSize: 14,
                            color: DesignColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // Build the lobby details card
  Widget _buildLobbyDetailsCard(BuildContext context, Lobby lobbyData) {
    final deviceType = DesignUtils.getDeviceType(context);
    final isDesktop = deviceType == DeviceScreenType.desktop;
    final padding = isDesktop ? EdgeInsets.all(24) : EdgeInsets.all(16);

    return Container(
      padding: padding,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Card(
          elevation: 2,
          color: DesignColors.white,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lobby title
                DesignText(
                  text: lobbyData.title ?? 'Untitled Lobby',
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: DesignColors.primary,
                ),
                SizedBox(height: 16),

                // Lobby image if available
                if (lobbyData.mediaUrls != null && lobbyData.mediaUrls!.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double imageHeight = (constraints.maxWidth * 900) / 1430;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          lobbyData.mediaUrls!.first,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500])),
                            );
                          },
                        ),
                      );
                    },
                  ),
                SizedBox(height: 24),

                // Lobby description
                DesignText(text: 'Description', fontSize: 18, fontWeight: FontWeight.bold, color: DesignColors.primary),
                RichTextDisplay(
                  controller: TextEditingController(text: lobbyData.description),
                  hintText: '',
                  lobbyId: lobbyData.id,
                ),

                // Lobby details in a grid
                // _buildLobbyDetailsGrid(lobbyData, isDesktop),

                // // Price details if available
                // if (lobbyData.priceDetails != null)
                //   Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       SizedBox(height: 16),
                //       Divider(),
                //       SizedBox(height: 16),
                //       DesignText(
                //         text: 'Price Details',
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //         color: DesignColors.primary,
                //       ),
                //       SizedBox(height: 8),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           DesignText(text: 'Price per slot:', fontSize: 16, color: DesignColors.secondary),
                //           DesignText(
                //             text: '₹${lobbyData.priceDetails?.price ?? 0}',
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //             color: DesignColors.primary,
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a grid of lobby details
  Widget _buildLobbyDetailsGrid(Lobby lobbyData, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 3 : 2,
      childAspectRatio: isDesktop ? 2.4 : 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        // Total members
        _buildDetailItem('Total Members', '${lobbyData.totalMembers ?? 0}', Icons.group),
        // Current members
        _buildDetailItem('Current Members', '${lobbyData.currentMembers ?? 0}', Icons.person),
        // Members required
        _buildDetailItem('Members Required', '${lobbyData.membersRequired ?? 0}', Icons.person_add),
        // Lobby type
        _buildDetailItem('Lobby Type', lobbyData.lobbyType ?? 'Unknown', Icons.category),
      ],
    );
  }

  // Build a single detail item for the grid
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: DesignColors.accent, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DesignText(text: label, fontSize: 12, color: DesignColors.secondary),
                DesignText(text: value, fontSize: 14, fontWeight: FontWeight.bold, color: DesignColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validateCoupon(String lobbyId) {
    kLogger.trace("validating coupon");
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      // Clear any existing coupon
      ref.read(couponProvider.notifier).clearCoupon();
      ref.read(selectedOfferProvider.notifier).state = null;
      return;
    }

    ref.read(couponProvider.notifier).validateCoupon(lobbyId, "LOBBY");
  }

  // Build the checkout form
  Widget _buildCheckoutForm(BuildContext context, Lobby lobbyData) {
    final deviceType = DesignUtils.getDeviceType(context);
    final isDesktop = deviceType == DeviceScreenType.desktop;
    final padding = isDesktop ? EdgeInsets.all(24) : EdgeInsets.all(16);
    final int slotCount = ref.watch(quickCheckoutCounterProvider);
    // final double slotPrice = lobbyData.priceDetails?.price ?? 0.0;

    final formList = ref.read(formsListProvider);
    final formListNotifier = ref.read(formsListProvider.notifier);

    final selectedTickets = ref.watch(selectedTicketsProvider);
    final currentLobbyTickets = selectedTickets[widget.lobbyId] ?? [];

    final pricingState = ref.watch(pricingProvider(widget.lobbyId));

    final slotPrice = pricingState.pricingData?.currentPricePerSlot ?? lobbyData.priceDetails?.price ?? 0.0;

    // Check if lobby is active or upcoming
    final bool isLobbyAvailable = lobbyData.lobbyStatus == "ACTIVE" || lobbyData.lobbyStatus == "UPCOMING";
    final selectedOffer = ref.watch(selectedOfferProvider);
    final double totalPrice =
        (!lobbyData.isAdvancedPricing)
            ? calculateTotalPrice(pricingData: pricingState.pricingData, selectedOffer: selectedOffer)
            // ? slotPrice * slotCount
            : (currentLobbyTickets.isNotEmpty)
            ? currentLobbyTickets.fold<double>(0, (sum, ticket) {
              // Find matching ticket option by ID
              final ticketOption = lobbyData.ticketOptions.firstWhere((option) => option.id == ticket.ticketId);

              // Calculate price for this ticket
              final price = ticketOption?.price ?? 0;
              final slots = ticket.slots ?? 1;

              // Add to running total
              return sum + (slots * price).toInt();
            })
            : 0.0;

    // Watch coupon state

    final couponState = ref.watch(couponProvider);

    // Synchronize coupon state with selectedOfferProvider
    // If coupon validation was successful, update the selected offer
    if (couponState.validatedOffer != null && selectedOffer?.offerId != couponState.validatedOffer?.offerId) {
      // Use microtask to avoid build phase state updates
      Future.microtask(() {
        ref.read(selectedOfferProvider.notifier).state = couponState.validatedOffer;
      });
    }

    return Container(
      padding: padding,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Card(
          elevation: 0,
          color: DesignColors.white,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child:
                isLobbyAvailable
                    ? Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                DesignText(
                                  text: 'Checkout',

                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: DesignColors.primary,
                                ),
                                if (lobbyData.priceDetails.originalPrice <= 0)
                                  Container(
                                    margin: EdgeInsets.only(top: 8),
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF52D17C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Color(0xFF52D17C).withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.money_off, size: 18, color: Color(0xFF52D17C)),
                                        SizedBox(width: 8),
                                        DesignText(
                                          text: "Free",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF52D17C),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Personal Information Section
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                                border: Border.all(color: DesignColors.primary.withOpacity(0.1), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Title
                                  Row(
                                    children: [
                                      Icon(Icons.person_pin_circle_outlined, color: DesignColors.primary, size: 24),
                                      SizedBox(width: 12),
                                      DesignText(
                                        text: 'Personal Information',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: DesignColors.primary,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),

                                  // Name Field
                                  StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DesignText(text: 'Full Name', fontSize: 14, color: DesignColors.secondary),
                                          SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: DesignColors.primary.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: DesignTextField(
                                              controller: _nameController,
                                              hintText: 'Enter your full name',
                                              borderRadius: 16,
                                              prefixIcon: Icon(Icons.person_outline, color: DesignColors.primary),
                                              onChanged: (value) {},
                                              onEditingComplete: () {
                                                if (_nameController.text.isEmpty) {
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter your name',
                                                    type: SnackBarType.warning,
                                                  );
                                                }
                                                return;
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Email Field
                                  StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DesignText(
                                            text: 'Email Address',
                                            fontSize: 14,
                                            color: DesignColors.secondary,
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: DesignColors.primary.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: DesignTextField(
                                              controller: _emailController,
                                              hintText: 'Enter your email address',
                                              inputType: TextInputType.emailAddress,
                                              borderRadius: 16,
                                              prefixIcon: Icon(Icons.email_outlined, color: DesignColors.primary),
                                              onEditingComplete: () {
                                                if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                ).hasMatch(_emailController.text)) {
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter a valid email address',
                                                    type: SnackBarType.warning,
                                                  );
                                                  return;
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Mobile Field
                                  StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DesignText(
                                            text: 'Mobile Number',
                                            fontSize: 14,
                                            color: DesignColors.secondary,
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: DesignColors.primary.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: DesignTextField(
                                              controller: _mobileController,
                                              hintText: 'Enter your 10-digit mobile number',
                                              inputType: TextInputType.number,
                                              borderRadius: 16,
                                              prefixIcon: Icon(Icons.phone_outlined, color: DesignColors.primary),
                                              onEditingComplete: () {
                                                String value = _mobileController.text;
                                                if (value == null || value.isEmpty) {
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter your mobile number',
                                                    type: SnackBarType.warning,
                                                  );
                                                  return;
                                                }

                                                if (!RegExp(r'^\d+$').hasMatch(value)) {
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter numbers only',
                                                    type: SnackBarType.warning,
                                                  );

                                                  _mobileController.text = value.substring(0, value.length - 1);
                                                  _mobileController.selection = TextSelection.fromPosition(
                                                    TextPosition(offset: _mobileController.text.length),
                                                  );
                                                  return;
                                                }

                                                if (_mobileController.text.length > 10) {
                                                  _mobileController.text = value.substring(0, value.length - 1);
                                                  _mobileController.selection = TextSelection.fromPosition(
                                                    TextPosition(offset: _mobileController.text.length),
                                                  );
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter a valid 10-digit mobile number',
                                                    type: SnackBarType.warning,
                                                  );
                                                  return;
                                                }

                                                if (value != null && value.isNotEmpty) {
                                                  if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                                    _mobileController.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                                                    _mobileController.selection = TextSelection.fromPosition(
                                                      TextPosition(offset: _mobileController.text.length),
                                                    );
                                                  }
                                                }
                                              },
                                              onChanged: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return;
                                                }

                                                if (!RegExp(r'^\d+$').hasMatch(value)) {
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter numbers only',
                                                    type: SnackBarType.warning,
                                                  );

                                                  _mobileController.text = value.substring(0, value.length - 1);
                                                  _mobileController.selection = TextSelection.fromPosition(
                                                    TextPosition(offset: _mobileController.text.length),
                                                  );

                                                  return;
                                                }

                                                if (_mobileController.text.length > 10) {
                                                  _mobileController.text = value.substring(0, value.length - 1);
                                                  _mobileController.selection = TextSelection.fromPosition(
                                                    TextPosition(offset: _mobileController.text.length),
                                                  );
                                                  CustomSnackBar.show(
                                                    context: context,
                                                    message: 'Please enter a valid 10-digit mobile number',
                                                    type: SnackBarType.warning,
                                                  );
                                                  return;
                                                }

                                                if (value != null && value.isNotEmpty) {
                                                  if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                                                    _mobileController.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                                                    _mobileController.selection = TextSelection.fromPosition(
                                                      TextPosition(offset: _mobileController.text.length),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),

                            // Slot counter
                            if (!lobbyData.isAdvancedPricing && lobbyData.priceDetails.originalPrice > 0)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: DesignColors.border.withOpacity(0.5), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DesignText(
                                      text: 'Number of Slots',

                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: DesignColors.primary,
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Decrement button
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              bool isHovered = false;
                                              return InkWell(
                                                onTap: () async {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor: Colors.transparent,
                                                        content: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            CircularProgressIndicator(color: DesignColors.accent),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  await ref
                                                      .read(pricingProvider(lobbyData.id).notifier)
                                                      .updateGroupSize(lobbyData.id, slotCount - 1);
                                                  ref.read(quickCheckoutCounterProvider.notifier).decrement();
                                                  ref.read(selectedOfferProvider.notifier).state = null;
                                                  if (formList.isNotEmpty) {
                                                    formList.removeLast();
                                                  }
                                                  Navigator.of(context, rootNavigator: true).pop();
                                                },
                                                onHover: (hover) {
                                                  setState(() {
                                                    isHovered = hover;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 150),
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isHovered
                                                            ? DesignColors.primary.withOpacity(0.05)
                                                            : Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: DesignColors.border),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.remove, color: DesignColors.primary),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Slot count display
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AnimatedContainer(
                                            duration: Duration(milliseconds: 200),
                                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: DesignColors.primary.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: Duration(milliseconds: 200),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: DesignColors.primary,
                                              ),
                                              child: DesignText(
                                                text: '$slotCount',
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: DesignColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Increment button
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              bool isHovered = false;
                                              return InkWell(
                                                onTap: () async {
                                                  if (pricingState.pricingData?.remainingSlots != null &&
                                                      slotCount + 1 > pricingState.pricingData!.remainingSlots!) {
                                                    CustomSnackBar.show(
                                                      context: context,
                                                      message: 'No more slots available',
                                                      type: SnackBarType.warning,
                                                    );
                                                    return;
                                                  }
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        backgroundColor: Colors.transparent,
                                                        content: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            CircularProgressIndicator(color: DesignColors.accent),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  final PricingResponse? cachedPricingData = pricingState.pricingData;
                                                  await ref
                                                      .read(pricingProvider(lobbyData.id).notifier)
                                                      .updateGroupSize(lobbyData.id, slotCount + 1);
                                                  kLogger.info(
                                                    "${ref.read(pricingProvider(lobbyData.id)).pricingData?.toJson()}",
                                                  );
                                                  if (ref.read(pricingProvider(lobbyData.id)).pricingData == null ||
                                                      ref
                                                              .read(pricingProvider(lobbyData.id))
                                                              .pricingData
                                                              ?.status
                                                              ?.toLowerCase() !=
                                                          'success') {
                                                    CustomSnackBar.show(
                                                      context: context,
                                                      message:
                                                          ref
                                                              .read(pricingProvider(lobbyData.id))
                                                              .pricingData
                                                              ?.message ??
                                                          'Failed to increase slots',
                                                      type: SnackBarType.error,
                                                    );
                                                    if (cachedPricingData != null) {
                                                      ref
                                                          .read(pricingProvider(lobbyData.id).notifier)
                                                          .updatePricingDataInState(cachedPricingData!);
                                                    }

                                                    Navigator.of(context, rootNavigator: true).pop();
                                                    return;
                                                  }
                                                  ref.read(quickCheckoutCounterProvider.notifier).increment();
                                                  ref.read(selectedOfferProvider.notifier).state = null;
                                                  if (formModel != null) {
                                                    if (ref.read(formsListProvider).isEmpty) {
                                                      ref.read(formsListProvider.notifier).addForm(formModel!);
                                                    } else {
                                                      final clearedForm = formModel!.copyWith(
                                                        questions:
                                                            formModel!.questions
                                                                .map((q) => q.copyWith(answer: ''))
                                                                .toList(),
                                                      );

                                                      ref.read(formsListProvider.notifier).addForm(clearedForm);
                                                    }
                                                  }
                                                  Navigator.of(context, rootNavigator: true).pop();
                                                },
                                                onHover: (hover) {
                                                  setState(() {
                                                    isHovered = hover;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: Duration(milliseconds: 150),
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isHovered
                                                            ? DesignColors.primary.withOpacity(0.05)
                                                            : Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: DesignColors.border),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.05),
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.add, size: 20, color: DesignColors.primary),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            else if (lobbyData.isAdvancedPricing)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: lobbyData.ticketOptions.length,
                                itemBuilder: (context, index) {
                                  final ticketOption = lobbyData.ticketOptions[index];
                                  final isSelected = currentLobbyTickets.any((t) => t.ticketId == ticketOption.id);
                                  final selectedTicket = currentLobbyTickets.firstWhere(
                                    (t) => t.ticketId == ticketOption.id,
                                    orElse: () => SelectedTicket(ticketId: '', name: '', slots: 0),
                                  );

                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: (index == lobbyData.ticketOptions.length - 1) ? 0 : 12,
                                    ),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? DesignColors.accent : Color(0xFFe7e8ea),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        DesignText(
                                          text: ticketOption.name,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: DesignColors.primary,
                                        ),
                                        Space.h(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            DesignText(
                                              text: '₹${ticketOption.price.toStringAsFixed(2)}',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: DesignColors.primary,
                                            ),
                                            if (!lobbyData.allowMultiplePricingOptions && !isSelected)
                                              DesignButton(
                                                onPress: () async {
                                                  ref
                                                      .read(selectedTicketsProvider.notifier)
                                                      .addTicket(
                                                        lobbyId: widget.lobbyId,
                                                        isMultiplePricing: lobbyData.allowMultiplePricingOptions,
                                                        ticketOption: ticketOption,
                                                        slots: 1,
                                                      );

                                                  await ref
                                                      .read(formStateProvider(widget.lobbyId).notifier)
                                                      .loadFormData(
                                                        currentLobbyTickets.map((e) => e.ticketId).toList(),
                                                      );
                                                },
                                                title: "ADD",
                                                titleSize: 12,
                                                titleColor: DesignColors.white,
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              )
                                            else
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                constraints: BoxConstraints(
                                                  maxWidth: lobbyData.allowMultiplePricingOptions ? 96 : 80,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: DesignColors.accent,
                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (lobbyData.allowMultiplePricingOptions ||
                                                        (isSelected && selectedTicket.slots > 0))
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () async {
                                                            if (selectedTicket.slots > 0) {
                                                              final newSlots = selectedTicket.slots - 1;
                                                              if (newSlots == 0) {
                                                                ref
                                                                    .read(selectedTicketsProvider.notifier)
                                                                    .removeTicket(
                                                                      lobbyId: widget.lobbyId,
                                                                      ticketId: ticketOption.id,
                                                                    );
                                                                await ref
                                                                    .read(formStateProvider(widget.lobbyId).notifier)
                                                                    .loadFormData(
                                                                      currentLobbyTickets
                                                                          .map((e) => e.ticketId)
                                                                          .toList(),
                                                                    );
                                                              } else {
                                                                ref
                                                                    .read(selectedTicketsProvider.notifier)
                                                                    .addTicket(
                                                                      lobbyId: widget.lobbyId,
                                                                      isMultiplePricing:
                                                                          lobbyData.allowMultiplePricingOptions,
                                                                      ticketOption: ticketOption,
                                                                      slots: newSlots,
                                                                    );
                                                                await ref
                                                                    .read(formStateProvider(widget.lobbyId).notifier)
                                                                    .loadFormData(
                                                                      currentLobbyTickets
                                                                          .map((e) => e.ticketId)
                                                                          .toList(),
                                                                    );
                                                              }
                                                            }
                                                          },
                                                          child: Icon(Icons.remove, size: 16, color: Colors.white),
                                                        ),
                                                      ),
                                                    if (lobbyData.allowMultiplePricingOptions ||
                                                        (isSelected && selectedTicket.slots > 0))
                                                      Space.w(width: 12),
                                                    Expanded(
                                                      child: DesignText(
                                                        text:
                                                            !lobbyData.allowMultiplePricingOptions &&
                                                                    selectedTicket.slots == 0
                                                                ? "ADD"
                                                                : selectedTicket.slots.toString(),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    // if ( (selectedTicket.slots > 0))
                                                    Space.w(width: 12),
                                                    if ((selectedTicket.slots < ticketOption.maxQuantity))
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () async {
                                                            final currentSlots = selectedTicket.slots;
                                                            final maxSlots = ticketOption.maxQuantity;
                                                            final newSlots = currentSlots + 1;

                                                            if (newSlots <= maxSlots) {
                                                              ref
                                                                  .read(selectedTicketsProvider.notifier)
                                                                  .addTicket(
                                                                    lobbyId: widget.lobbyId,
                                                                    isMultiplePricing:
                                                                        lobbyData.allowMultiplePricingOptions,
                                                                    ticketOption: ticketOption,
                                                                    slots: newSlots,
                                                                  );
                                                              await ref
                                                                  .read(formStateProvider(widget.lobbyId).notifier)
                                                                  .loadFormData(
                                                                    currentLobbyTickets.map((e) => e.ticketId).toList(),
                                                                  );
                                                            }
                                                          },
                                                          child: Icon(Icons.add, size: 16, color: Colors.white),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        //  Space(height: 4),
                                        Divider(color: Color(0xFFe7e8ea)),
                                        //  Space(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: DesignText(
                                                text: ticketOption.description,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: DesignColors.primary,
                                                maxLines: null,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: DesignText(
                                                text: "Max: ${ticketOption.maxQuantity}",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: DesignColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            if (lobbyData.hasForm && formList.isNotEmpty) ...[
                              Space.h(height: 24),
                              DesignText(
                                text: "Fill the form below to book your ticket",

                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: DesignColors.primary,
                              ),
                              Space.h(height: 16),
                              if (slotCount > 0)
                                ...List.generate(slotCount, (index) {
                                  if (index == 0) {
                                    return formCard(
                                      tileText: "Your form response",
                                      formIndex: 0,
                                      lobbyId: lobbyData.id,
                                    );
                                  }
                                  return formCard(
                                    tileText: "Form for slot ${index + 1}",
                                    formIndex: index,
                                    lobbyId: lobbyData.id,
                                  );
                                }),
                            ],

                            if (lobbyData.priceDetails?.price != 0.0 && !lobbyData.isAdvancedPricing) ...[
                              Space.h(height: 24),
                              DesignTextField(
                                hintText: "Have a coupon code ?",
                                borderRadius: 18,
                                suffixIcon:
                                    couponState.isLoading
                                        ? SizedBox(
                                          width: 8,
                                          height: 8,
                                          child: CircularProgressIndicator(
                                            padding: EdgeInsets.all(12),
                                            strokeWidth: 2,
                                            color: const Color(0xFFEC4B5D),
                                          ),
                                        )
                                        : GestureDetector(
                                          onTap: () {
                                            // If field is empty, don't validate
                                            if (_couponController.text.trim().isEmpty) {
                                              return;
                                            }

                                            // If already validated, clear the coupon
                                            if (couponState.validatedOffer != null) {
                                              _couponController.clear();
                                              ref.read(couponProvider.notifier).clearCoupon();
                                              ref.read(selectedOfferProvider.notifier).state = null;
                                            } else {
                                              _validateCoupon(lobbyData.id);
                                            }
                                          },
                                          child:
                                              ((couponState.validatedOffer == null) && couponState.errorMessage == null)
                                                  ? Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(right: 8),
                                                        child: DesignText(
                                                          text: 'Apply',
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: DesignColors.accent,
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : DesignIcon.icon(
                                                    icon:
                                                        couponState.validatedOffer != null
                                                            ? Icons
                                                                .done_outlined // Change to  icon for removal
                                                            : couponState.errorMessage != null
                                                            ? Icons
                                                                .error_outline_rounded // Show error icon for invalid codes
                                                            : Icons.arrow_forward_ios_rounded, // Default arrow icon
                                                    color:
                                                        couponState.validatedOffer != null
                                                            ? Colors.green
                                                            : couponState.errorMessage != null
                                                            ? Colors.red
                                                            : const Color(0xFFEC4B5D),
                                                    size: 16,
                                                  ),
                                        ),
                                controller: _couponController,
                                errorText: couponState.errorMessage,
                                onChanged: (val) {
                                  // Update coupon code in provider for any change
                                  // _couponController.text = _couponController.text.toUpperCase();
                                  final upperVal = val?.trim().toUpperCase() ?? '';
                                  ref.read(selectedOfferProvider.notifier).state = null;
                                  ref.read(couponProvider.notifier).clearCoupon();
                                  // ref.read(couponProvider.notifier).updateCouponCode(val ?? '');
                                  ref.read(couponProvider.notifier).updateCouponCode(upperVal);
                                },
                                onEditingComplete: () {
                                  if (_couponController.text.trim().isNotEmpty) {
                                    ref.read(selectedOfferProvider.notifier).state = null;
                                    _validateCoupon(lobbyData.id);
                                  }
                                },
                              ),
                            ],

                            SizedBox(height: 24),

                            // Price summary
                            if ((!lobbyData.isAdvancedPricing || currentLobbyTickets.isNotEmpty) &&
                                lobbyData.priceDetails.originalPrice > 0)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: DesignColors.border.withOpacity(0.5), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    if (!lobbyData.isAdvancedPricing) ...[
                                      if (pricingState.pricingData?.pricingModel == 'TIERED_GROUP' &&
                                          pricingState.pricingData?.priceBreakdown != null &&
                                          pricingState.pricingData!.priceBreakdown!.isNotEmpty)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Parse and display individual pricing tiers
                                            ..._buildPricingTiers(pricingState.pricingData!.priceBreakdown!),
                                            SizedBox(height: 16),
                                            if (selectedOffer != null) ...[
                                              Container(
                                                margin: EdgeInsets.only(bottom: 8),
                                                padding: EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey[200]!, width: 1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.02),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        DesignText(
                                                          text: "Discount",
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: DesignColors.primary,
                                                        ),
                                                        // Updated to format price with commas
                                                        DesignText(
                                                          text:
                                                              "Flat ${selectedOffer.discountValue} ${(selectedOffer.discountType == "PERCENTAGE") ? "%" : "Rs."} off",
                                                          fontSize: 13,
                                                          color: Colors.green[600],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.green, width: 1.0),
                                                      ),
                                                      child: DesignText(
                                                        // Updated to format total with commas
                                                        text:
                                                            "-${_extractDiscountFromBreakdown(pricingState.pricingData!.priceBreakdown!)}",
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                            ],
                                            Divider(height: 1, color: Colors.grey[300]),
                                            SizedBox(height: 16),
                                            // Total section
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    DesignColors.primary.withOpacity(0.05),
                                                    DesignColors.primary.withOpacity(0.02),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: DesignColors.primary.withOpacity(0.1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      DesignText(
                                                        text: 'Total Amount',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: DesignColors.primary,
                                                      ),
                                                      DesignText(
                                                        text: 'Including all slots',
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: DesignColors.accent.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(
                                                        color: DesignColors.accent.withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: DesignText(
                                                      text: _extractTotalFromBreakdown(
                                                        pricingState.pricingData!.priceBreakdown!,
                                                      ),
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: DesignColors.accent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      else ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            DesignText(
                                              text: 'Price per slot:',
                                              fontSize: 16,
                                              color: DesignColors.secondary,
                                            ),
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: DesignColors.primary.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: AnimatedDefaultTextStyle(
                                                duration: Duration(milliseconds: 300),
                                                style: TextStyle(fontSize: 16, color: DesignColors.primary),
                                                child: DesignText(
                                                  text: slotPrice > 0 ? '₹$slotPrice' : 'Free',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: DesignColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            DesignText(
                                              text: 'Number of slots:',
                                              fontSize: 16,
                                              color: DesignColors.secondary,
                                            ),
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: DesignColors.primary.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: AnimatedDefaultTextStyle(
                                                duration: Duration(milliseconds: 300),
                                                style: TextStyle(fontSize: 16, color: DesignColors.primary),
                                                child: DesignText(
                                                  text: '$slotCount',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: DesignColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (selectedOffer != null) ...[
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              DesignText(
                                                text: 'Discount:',
                                                fontSize: 16,
                                                color: DesignColors.secondary,
                                              ),
                                              AnimatedContainer(
                                                duration: Duration(milliseconds: 300),
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: DesignColors.primary.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: AnimatedDefaultTextStyle(
                                                  duration: Duration(milliseconds: 300),
                                                  style: TextStyle(fontSize: 16, color: DesignColors.primary),
                                                  child: DesignText(
                                                    text:
                                                        '-₹${calculateDiscount(pricingData: pricingState.pricingData, selectedOffer: selectedOffer)}',
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        SizedBox(height: 8),
                                        Divider(),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            DesignText(
                                              text: 'Total:',

                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: DesignColors.primary,
                                            ),
                                            AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: DesignColors.accent.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: AnimatedDefaultTextStyle(
                                                duration: Duration(milliseconds: 300),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: DesignColors.accent,
                                                ),
                                                child: DesignText(
                                                  text: totalPrice > 0 ? '₹$totalPrice' : 'Free',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: DesignColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ] else if (currentLobbyTickets.isNotEmpty) ...[
                                      ...List.generate(currentLobbyTickets.length, (index) {
                                        final ticket = currentLobbyTickets[index];
                                        final slots = ticket.slots ?? 1;
                                        final price =
                                            lobbyData.ticketOptions
                                                .firstWhere((option) => option.id == ticket.ticketId)
                                                .price;
                                        final totalPrice = price * slots;
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[200]!, width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        DesignText(
                                                          text: ticket.name,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF323232),
                                                        ),
                                                        Space.h(height: 2),
                                                        DesignText(
                                                          text: '₹ ${price.toStringAsFixed(0)} each',
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF666666),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      DesignText(
                                                        text: '× $slots',
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF444444),
                                                      ),
                                                      Space.h(height: 2),
                                                      DesignText(
                                                        text: '₹ ${totalPrice.toStringAsFixed(0)}',
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF323232),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      SizedBox(height: 8),
                                      Divider(),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          DesignText(
                                            text: 'Total:',

                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: DesignColors.primary,
                                          ),
                                          AnimatedContainer(
                                            duration: Duration(milliseconds: 300),
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: DesignColors.accent.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: Duration(milliseconds: 300),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: DesignColors.accent,
                                              ),
                                              child: DesignText(
                                                text: '₹$totalPrice',

                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: DesignColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            SizedBox(height: 24),

                            // Checkout button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    bool isHovered = false;
                                    return InkWell(
                                      onHover: (hover) {
                                        setState(() {
                                          isHovered = hover;
                                        });
                                      },
                                      child: DesignButton(
                                        onPress:
                                            () => _handleCheckout(
                                              lobbyData,
                                              pricingState.pricingData?.total ?? totalPrice,
                                            ),

                                        title:
                                            _isProcessing
                                                ? 'Processing...'
                                                : (totalPrice > 0 ? 'Proceed to Checkout' : 'Save Your Spot'),
                                        isLoading: _isProcessing,
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        bgColor:
                                            (slotCount > 0 &&
                                                    ref.watch(formsListProvider.notifier).validateAllForms() == null)
                                                ? DesignColors.accent
                                                : const Color(0xFF989898),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                DesignIcon.icon(icon: Icons.info_outline_rounded, color: DesignColors.accent, size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: DesignText(
                                    text:
                                        "After successfull checkout, you will get your tickets and other details on your entered email.",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: DesignColors.secondary,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    : _buildLobbyUnavailableMessage(lobbyData),
          ),
        ),
      ),
    );
  }

  Widget _buildLobbyUnavailableMessage(Lobby lobbyData) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Icon(Icons.event_busy_outlined, size: 64, color: DesignColors.accent),
          SizedBox(height: 24),
          // Title
          DesignText(
            text: _getLobbyUnavailableTitle(lobbyData),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DesignColors.primary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          // Message
          DesignText(
            text: _getLobbyUnavailableMessage(lobbyData),
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: DesignColors.secondary,
            textAlign: TextAlign.center,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
          // SizedBox(height: 24),
          // // Contact admin button
          // SizedBox(
          //   width: 200,
          //   child: DesignButton(
          //     onPress: () {
          //       // You can implement contact admin functionality here
          //       CustomSnackBar.show(
          //         context: context,
          //         message: 'Please contact the lobby admin for more information',
          //         type: SnackBarType.info,
          //       );
          //     },
          //     title: 'Contact Admin',
          //     padding: EdgeInsets.symmetric(vertical: 16),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   ),
          // ),
        ],
      ),
    );
  }

  String _getLobbyUnavailableTitle(Lobby lobbyData) {
    switch (lobbyData.lobbyStatus) {
      case "PAST":
        return "Lobby Event Has Ended";
      case "CLOSED":
        return "Lobby registrations closed";
      case "FULL":
        return "Lobby is Full";
      default:
        return "Lobby Not Available";
    }
  }

  String _getLobbyUnavailableMessage(Lobby lobbyData) {
    switch (lobbyData.lobbyStatus) {
      case "PAST":
        return "This event has already taken place. Check out other upcoming events or contact the admin for any queries.";
      case "CLOSED":
        return "This lobby is no longer accepting registrations. Please check other available lobbies or contact the admin for more information.";
      case "FULL":
        return "This lobby has reached its maximum capacity and is no longer accepting new registrations. Please check other available lobbies or contact the admin for more information.";
      default:
        return "This lobby is currently not available for registration. Please contact the lobby admin for more information.";
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final lobbyDetailsAsync = ref.watch(lobbyQuickCheckoutDetailsProvider(widget.lobbyId));

    return lobbyDetailsAsync.when(
      data: (lobbyData) {
        return lobbyData == null
            ? Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  onPressed: () {
                    Get.back();
                  },
                  icon: DesignIcon.icon(icon: Icons.arrow_back_ios_sharp, size: 20),
                ),
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
              ),
              body: RefreshIndicator(
                key: Key("nullDataStateRefreshIndicator"),
                onRefresh: () async {
                  ref.read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier).reset();
                  await ref
                      .read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier)
                      .fetchLobbyQuickCheckoutDetails(widget.lobbyId);
                },
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: 0.85 * sh,
                    child: Center(
                      child: DesignText(
                        text: "Lobby Not Found !!!",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                        maxLines: 10,
                      ),
                    ),
                  ),
                ),
              ),
            )
            : Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Builder(
                  builder: (context) {
                    // Get device type for responsive design
                    final deviceType = DesignUtils.getDeviceType(context);
                    final isDesktop = deviceType == DeviceScreenType.desktop;
                    if (lobbyData.lobby.priceDetails.originalPrice <= 0) ;
                    Future.microtask(() {
                      ref.read(expandStateProvider("Your form response").notifier).state = true;
                    });

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
                      child: Row(
                        children: [
                          // Back button
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                            },
                            icon: DesignIcon.icon(icon: Icons.arrow_back_ios_sharp, size: 18),
                          ),
                          SizedBox(width: 16),
                          // Logo
                          Image.asset('assets/icons/aroundu.png', height: 32, fit: BoxFit.contain),
                          SizedBox(width: 12),
                          // App name
                          Text(
                            'AroundU',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Spacer(),
                          // Optional: Add more elements for desktop view
                          if (isDesktop) ...[
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.splash),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_outline, size: 18, color: Color(0xFF444444)),
                                    SizedBox(width: 8),
                                    Text(
                                      'My Account',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              body: Builder(
                builder: (context) {
                  // Get device type for responsive design
                  final deviceType = DesignUtils.getDeviceType(context);
                  final isDesktop = deviceType == DeviceScreenType.desktop;

                  return Container(
                    color: DesignColors.white,
                    child:
                        isDesktop
                            ? _buildDesktopLayout(context, lobbyData.lobby)
                            : _buildMobileLayout(context, lobbyData.lobby),
                  );
                },
              ),
            );
      },
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white70),
              onPressed: () {
                Get.back();
              },
              icon: DesignIcon.icon(icon: Icons.arrow_back_ios_sharp, size: 20),
            ),
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          body: RefreshIndicator(
            key: Key("errorStateRefreshIndicator"),
            onRefresh: () async {
              ref.read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier).reset();
              await ref
                  .read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier)
                  .fetchLobbyQuickCheckoutDetails(widget.lobbyId);
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: 0.85 * sh,
                child: Column(
                  children: [
                    Center(
                      child: DesignText(
                        text: "Something went wrong \n Please try again !!!",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                        maxLines: 10,
                      ),
                    ),
                    Space.h(height: 32),
                    DesignButton(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: DesignText(text: "Retry", fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      onPress: () async {
                        ref.read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier).reset();
                        await ref
                            .read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier)
                            .fetchLobbyQuickCheckoutDetails(widget.lobbyId);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              style: IconButton.styleFrom(backgroundColor: Colors.white70),
              onPressed: () {
                Get.back();
              },
              icon: DesignIcon.icon(icon: Icons.arrow_back_ios_sharp, size: 20),
            ),
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              height: 0.85 * sh,
              child: Center(child: CircularProgressIndicator(color: DesignColors.accent)),
            ),
          ),
        );
      },
    );
  }

  Widget formCard({required String tileText, required int formIndex, required String lobbyId}) {
    final isExpanded = ref.watch(expandStateProvider(tileText));

    return GestureDetector(
      onTap: () {
        toggle(ref, tileText);
        // ref.read(expandStateProvider(tileText).notifier).state = !isExpanded;
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: (formIndex == ref.watch(formsListProvider).length - 1) ? 0 : 16),
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
                  DesignIcon.icon(icon: Icons.description_outlined, color: const Color(0xFFEC4B5D)),
                  Space.w(width: 14),
                  DesignText(text: tileText, fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF323232)),
                  const Spacer(),
                  DesignIcon.icon(
                    icon: isExpanded ? Icons.expand_less : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFEC4B5D),
                    size: 16,
                  ),
                ],
              ),
              if (isExpanded) ...[
                Space.h(height: 16),
                _buildFormQuestions(formIndex: formIndex, lobbyId: lobbyId),
                Space.h(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormQuestions({required int formIndex, required String lobbyId}) {
    final formNotifier = ref.read(formsListProvider.notifier);
    final formListData = ref.watch(formsListProvider);
    FormModel formData = formListData[formIndex];

    kLogger.trace("message formdata :  $formData");

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
          padding: EdgeInsets.only(bottom: 0),
          child:
              formData.questions.isEmpty
                  ? FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 2500)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFEC4B5D)));
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
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer.toString()) {
                          controller.text = question.answer.toString();
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    fontSize: 12,
                                    onChanged: (val) => formNotifier.updateAnswer(formIndex, question.id, val!),
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Number question
                      else if (question.questionType == 'number') {
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter a number",
                                    fontSize: 12,
                                    inputType: TextInputType.number,
                                    onEditingComplete: () {
                                      if (controller.text != null) {
                                        if (controller.text.isEmpty || RegExp(r'^\d+$').hasMatch(controller.text)) {
                                          formNotifier.updateAnswer(formIndex, question.id, controller.text);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          Fluttertoast.showToast(
                                            msg: "Please enter digits only",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                    onChanged: (val) {
                                      // Validate: only allow digits
                                      if (val != null) {
                                        if (val.isEmpty || RegExp(r'^\d+$').hasMatch(val)) {
                                          formNotifier.updateAnswer(formIndex, question.id, val);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter digits only",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.red,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Email question
                      else if (question.questionType == 'email') {
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter your email",
                                    fontSize: 12,
                                    inputType: TextInputType.emailAddress,
                                    onEditingComplete: () {
                                      if (controller.text.isNotEmpty &&
                                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid email address",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(formIndex, question.id, val);

                                        // Validate email format if not empty
                                        if (val.isNotEmpty &&
                                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                          // Show warning but don't revert the text
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter a valid email address",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.orange,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Date question
                      else if (question.questionType == 'date') {
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            controller.text.isNotEmpty
                                                ? DateTime.parse(controller.text)
                                                : DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: DesignColors.accent,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF262933),
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: DesignColors.accent,
                                                  textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (picked != null) {
                                        // Format date as ISO string for storage
                                        final formattedDate = picked.toIso8601String();
                                        controller.text = formattedDate;
                                        formNotifier.updateAnswer(formIndex, question.id, formattedDate);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            controller.text.isNotEmpty ? _formatDate(controller.text) : "Select a date",
                                            style: TextStyle(
                                              color: controller.text.isNotEmpty ? Colors.black : Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // File question
                      else if (question.questionType == 'file') {
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 8),
                                  Text(
                                    "Accepts PDF, PNG, JPG, MP4 files (Max 50MB)",
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins'),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'mp4'],
                                          withData: true, // Required for web
                                        );

                                        if (result != null && result.files.single.bytes != null) {
                                          // Get file data for web
                                          final file = result.files.single;
                                          final bytes = file.bytes!;
                                          final filename = file.name;

                                          // Check file size (50MB = 50 * 1024 * 1024 bytes)
                                          if (bytes.length > 50 * 1024 * 1024) {
                                            Fluttertoast.showToast(
                                              msg: "File size exceeds 50MB limit",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          // Show loading indicator
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.transparent,
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(color: DesignColors.accent),
                                                    SizedBox(height: 16),
                                                    Text("Uploading file...", style: TextStyle(color: Colors.white)),
                                                  ],
                                                ),
                                              );
                                            },
                                          );

                                          // Upload file
                                          try {
                                            final uploadBody = {
                                              'userId': await GetStorage().read("userUID") ?? '',
                                              'lobbyId': lobbyId,
                                              'questionId': question.id,
                                            };

                                            final result = await FileUploadService().uploadBytes(
                                              "user/upload/api/v1/file",
                                              bytes,
                                              filename,
                                              uploadBody,
                                            );

                                            // Close loading dialog
                                            Navigator.pop(context);

                                            if (result.statusCode == 200) {
                                              String fileUrl = result.data['imageUrl'];
                                              controller.text = fileUrl;
                                              formNotifier.updateAnswer(formIndex, question.id, fileUrl);

                                              Fluttertoast.showToast(
                                                msg: "File uploaded successfully",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Failed to upload file",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            // Close loading dialog
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                              msg: "Error uploading file: $e",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                          }
                                        }
                                      } catch (e, s) {
                                        kLogger.error("Error selecting file:", error: e, stackTrace: s);
                                        Fluttertoast.showToast(
                                          msg: "Error selecting file: $e",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child:
                                          controller.text.isEmpty
                                              ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.cloud_upload_outlined,
                                                      color: Colors.grey.shade600,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "Upload File",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(Icons.add, color: Colors.grey.shade600, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              : Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.topRight,
                                                    children: [
                                                      if (_isImageFile(controller.text))
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            controller.text,
                                                            height: 120,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error, stackTrace) =>
                                                                    Icon(Icons.image, size: 50, color: Colors.grey),
                                                          ),
                                                        )
                                                      else if (_isPdfFile(controller.text))
                                                        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red)
                                                      else if (_isVideoFile(controller.text))
                                                        Icon(Icons.video_file, size: 50, color: Colors.blue),
                                                      IconButton(
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          minimumSize: Size(32, 32),
                                                          maximumSize: Size(32, 32),
                                                        ),
                                                        icon: Icon(Icons.close, color: Colors.black, size: 16),
                                                        onPressed: () {
                                                          controller.clear();
                                                          formNotifier.updateAnswer(formIndex, question.id, '');
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    _getFileNameFromUrl(controller.text),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // URL question
                      else if (question.questionType == 'url') {
                        final controller = formNotifier.getControllerForQuestion(formIndex, question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter URL",
                                    fontSize: 12,
                                    inputType: TextInputType.url,
                                    onEditingComplete: () {
                                      kLogger.trace(isValidUrl(controller.text).toString());
                                      // Validate URL format if not empty
                                      if (controller.text.isNotEmpty && !isValidUrl(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid URL",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(formIndex, question.id, val);

                                        // Validate URL format if not empty
                                        // if (val.isNotEmpty && !_isValidUrl(val)) {
                                        //   // Show warning but don't revert the text
                                        //   Fluttertoast.showToast(
                                        //     msg: "Please enter a valid URL",
                                        //     toastLength: Toast.LENGTH_SHORT,
                                        //     gravity: ToastGravity.BOTTOM,
                                        //     backgroundColor: Colors.orange,
                                        //     textColor: Colors.white,
                                        //   );
                                        // }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
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
                                          formNotifier.updateAnswer(formIndex, question.id, option);
                                        }
                                      },
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      dense: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Default fallback for unsupported question types
                        return Container();
                      }
                    }),
                  ),
        ),
      ],
    );
  }

  // Helper method to format date for display
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoString; // Return original string if parsing fails
    }
  }

  List<Widget> _buildPricingTiers(String priceBreakdown) {
    try {
      // Remove "Pricing: " prefix and ". Total: ..." suffix
      String pricingPart = priceBreakdown.replaceFirst('Pricing: ', '');
      int totalIndex = pricingPart.indexOf('. Total:');
      if (totalIndex != -1) {
        pricingPart = pricingPart.substring(0, totalIndex);
      }

      // Split by commas to get individual tiers
      List<String> tiers = pricingPart.split(',').map((e) => e.trim()).toList();

      return tiers.map((tier) {
        // Updated regex to handle comma-separated prices
        final match = RegExp(r'(\d+)\s+slots?\s+@\s+₹\s*([\d,]+(?:\.\d+)?)').firstMatch(tier);
        if (match != null) {
          final slots = int.parse(match.group(1)!);
          // Remove commas from price before parsing
          final price = double.parse(match.group(2)!.replaceAll(',', ''));
          final total = slots * price;

          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: Offset(0, 1))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: slots == 1 ? '$slots slot' : '$slots slots',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.primary,
                    ),
                    // Updated to format price with commas
                    DesignText(
                      text: '₹ ${NumberFormat('#,##0.00').format(price)} per slot',
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DesignColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DesignText(
                    // Updated to format total with commas
                    text: '₹ ${NumberFormat('#,##0.00').format(total)}',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignColors.primary,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      }).toList();
    } catch (e) {
      // Fallback to simple text display if parsing fails
      return [DesignText(text: priceBreakdown, fontSize: 16, color: DesignColors.secondary)];
    }
  }

  String _extractTotalFromBreakdown(String priceBreakdown) {
    try {
      // Updated regex to handle comma-separated numbers
      final match = RegExp(r'Total:\s*₹\s*([\d,]+(?:\.\d+)?)').firstMatch(priceBreakdown);
      if (match != null) {
        // Remove commas from the number and format properly
        String amount = match.group(1)!.replaceAll(',', '');
        double value =
            double.parse(amount) -
            calculateDiscount(
              pricingData: PricingResponse(total: double.parse(amount)),
              selectedOffer: ref.read(selectedOfferProvider),
            );

        // Format with commas for display
        final formatter = NumberFormat('#,##0.00');
        return '₹ ${formatter.format(value)}';
      }
    } catch (e) {
      // Fallback
    }
    return '₹ 0.00';
  }

  String _extractDiscountFromBreakdown(String priceBreakdown) {
    try {
      // Updated regex to handle comma-separated numbers
      final match = RegExp(r'Total:\s*₹\s*([\d,]+(?:\.\d+)?)').firstMatch(priceBreakdown);
      if (match != null) {
        // Remove commas from the number and format properly
        String amount = match.group(1)!.replaceAll(',', '');
        double value = calculateDiscount(
          pricingData: PricingResponse(total: double.parse(amount)),
          selectedOffer: ref.read(selectedOfferProvider),
        );

        // Format with commas for display
        final formatter = NumberFormat('#,##0.00');
        return '₹ ${formatter.format(value)}';
      }
    } catch (e) {
      // Fallback
    }
    return '₹ 0.00';
  }

  double calculateTotalPrice({required PricingResponse? pricingData, Offer? selectedOffer}) {
    double total = pricingData?.total ?? 0.0;
    if (selectedOffer != null) {
      if (selectedOffer.discountType == 'PERCENTAGE') {
        // double percentage = selectedOffer.discountValue;
        double discount = calculateDiscount(pricingData: pricingData, selectedOffer: selectedOffer);
        total = total - discount;
      } else if (selectedOffer.discountType == 'FLAT') {
        total = total - selectedOffer.discountValue;
      }
    }

    return total;
  }

  double calculateDiscount({required PricingResponse? pricingData, Offer? selectedOffer}) {
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

    return discount;
  }

  // Helper method to extract file name from URL
  String _getFileNameFromUrl(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return url; // Return original URL if extraction fails
    }
  }

  bool isValidUrl(String url) {
    if (url.isEmpty || url.trim().isEmpty) return false;

    String cleanUrl = url.trim();

    // Basic sanity checks
    if (cleanUrl.length < 3 ||
        cleanUrl.contains(' ') ||
        cleanUrl.contains('\n') ||
        cleanUrl.contains('\t') ||
        cleanUrl.contains('\r')) {
      return false;
    }

    // Remove protocol if present to check the domain part
    String domainPart = cleanUrl;
    bool hasProtocol = false;

    if (cleanUrl.startsWith('http://')) {
      domainPart = cleanUrl.substring(7);
      hasProtocol = true;
    } else if (cleanUrl.startsWith('https://')) {
      domainPart = cleanUrl.substring(8);
      hasProtocol = true;
    }

    // Remove path, query, and fragment to isolate domain
    domainPart = domainPart.split('/')[0].split('?')[0].split('#')[0];

    // Handle port
    String domain = domainPart.split(':')[0];

    // Domain must not be empty after all parsing
    if (domain.isEmpty) return false;

    // Validate the domain structure BEFORE trying Uri.parse
    if (!_isValidDomainStructure(domain)) {
      return false;
    }

    // Now try to parse with https if no protocol
    String urlToParse = hasProtocol ? cleanUrl : 'https://$cleanUrl';

    // Additional attempt with www if needed
    if (!hasProtocol && !cleanUrl.startsWith('www.') && !_isIpAddress(domain)) {
      String urlWithWww = 'https://www.$cleanUrl';
      Uri? uriWithWww = Uri.tryParse(urlWithWww);
      if (uriWithWww != null && _isValidParsedUri(uriWithWww)) {
        return true;
      }
    }

    Uri? uri = Uri.tryParse(urlToParse);
    return uri != null && _isValidParsedUri(uri);
  }

  bool _isValidDomainStructure(String domain) {
    if (domain.isEmpty || domain.length > 253) return false;

    // Handle localhost
    if (domain == 'localhost') return true;

    // Check if it's an IP address
    if (_isIpAddress(domain)) {
      return _isValidIpAddress(domain);
    }

    // For domain names, must contain at least one dot
    if (!domain.contains('.')) return false;

    // Cannot start or end with dot or hyphen
    if (domain.startsWith('.') || domain.endsWith('.') || domain.startsWith('-') || domain.endsWith('-')) {
      return false;
    }

    // Cannot contain consecutive dots
    if (domain.contains('..')) return false;

    // Split into labels and validate each
    final labels = domain.split('.');
    if (labels.length < 2) return false;

    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      if (!_isValidDomainLabel(label, i == labels.length - 1)) {
        return false;
      }
    }

    return true;
  }

  bool _isValidDomainLabel(String label, bool isTLD) {
    if (label.isEmpty || label.length > 63) return false;

    // Cannot start or end with hyphen
    if (label.startsWith('-') || label.endsWith('-')) return false;

    // Must contain only alphanumeric characters and hyphens
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(label)) return false;

    // If it's a TLD (last label), additional validation
    if (isTLD) {
      // TLD must be at least 2 characters
      if (label.length < 2) return false;

      // TLD should contain at least one letter
      if (!RegExp(r'[a-zA-Z]').hasMatch(label)) return false;

      // Common valid TLD patterns - reject obvious random strings
      if (!_isValidTLD(label)) return false;
    } else {
      // Non-TLD labels cannot be all hyphens or have weird patterns
      if (RegExp(r'^-+$').hasMatch(label)) return false;
    }

    return true;
  }

  bool _isValidTLD(String tld) {
    // Convert to lowercase for checking
    String lowerTLD = tld.toLowerCase();

    // List of definitely invalid TLDs (random letter combinations)
    final obviouslyInvalid = {
      'aa',
      'bb',
      'cc',
      'dd',
      'ee',
      'ff',
      'gg',
      'hh',
      'ii',
      'jj',
      'kk',
      'll',
      'mm',
      'nn',
      'oo',
      'pp',
      'qq',
      'rr',
      'ss',
      'tt',
      'uu',
      'vv',
      'ww',
      'xx',
      'yy',
      'zz',
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh',
      'iii',
      'jjj',
      'kkk',
      'lll',
      'mmm',
      'nnn',
      'ooo',
      'ppp',
      'qqq',
      'rrr',
      'sss',
      'ttt',
      'uuu',
      'vvv',
      'www',
      'xxx',
      'yyy',
      'zzz',
    };

    if (obviouslyInvalid.contains(lowerTLD)) return false;

    // Check for common valid TLD patterns
    // Real TLDs usually have meaningful patterns
    final commonValidTLDs = {
      'com',
      'org',
      'net',
      'gov',
      'edu',
      'mil',
      'int',
      'co',
      'io',
      'ai',
      'me',
      'uk',
      'us',
      'ca',
      'au',
      'de',
      'fr',
      'jp',
      'cn',
      'in',
      'br',
      'mx',
      'ru',
      'info',
      'biz',
      'name',
      'pro',
      'aero',
      'asia',
      'cat',
      'coop',
      'jobs',
      'mobi',
      'museum',
      'post',
      'tel',
      'travel',
      'xxx',
      'app',
      'dev',
      'tech',
      'online',
      'site',
      'website',
      'store',
      'blog',
      'news',
      'today',
      'world',
    };

    // If it's a common valid TLD, accept it
    if (commonValidTLDs.contains(lowerTLD)) return true;

    // For other TLDs, check if they look reasonable
    // Real TLDs typically:
    // 1. Are not random character sequences
    // 2. Have vowels and consonants mixed reasonably
    // 3. Don't have repeating patterns

    // Check for reasonable letter distribution
    if (lowerTLD.length >= 3) {
      // Count vowels
      int vowels = 0;
      for (int i = 0; i < lowerTLD.length; i++) {
        if ('aeiou'.contains(lowerTLD[i])) vowels++;
      }

      // Should have at least one vowel for longer TLDs
      if (vowels == 0 && lowerTLD.length > 3) return false;

      // Check for excessive repetition
      if (RegExp(r'(.)\1{2,}').hasMatch(lowerTLD)) return false;
    }

    // If it passes basic checks and isn't obviously invalid, accept it
    return true;
  }

  bool _isIpAddress(String host) {
    // IPv4 pattern
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // Basic IPv6 pattern (simplified)
    if (host.contains(':') && RegExp(r'^[0-9a-fA-F:]+$').hasMatch(host)) {
      return true;
    }

    return false;
  }

  bool _isValidIpAddress(String host) {
    // IPv4 validation
    final ipv4Pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4Pattern.firstMatch(host);

    if (match != null) {
      for (int i = 1; i <= 4; i++) {
        final octet = int.tryParse(match.group(i)!);
        if (octet == null || octet < 0 || octet > 255) {
          return false;
        }
      }
      return true;
    }

    // IPv6 basic validation
    if (host.contains(':')) {
      final parts = host.split(':');
      if (parts.length > 8) return false;

      for (final part in parts) {
        if (part.isNotEmpty && (part.length > 4 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(part))) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  bool _isValidParsedUri(Uri uri) {
    // Must be http or https
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    // Must have a valid host
    if (uri.host.isEmpty) return false;

    // Final validation of the host
    return _isValidDomainStructure(uri.host);
  }

  // Helper functions to check file types
  bool _isImageFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ['png', 'jpg', 'jpeg'].contains(ext);
  }

  bool _isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isVideoFile(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }
}

class LobbyQuickCheckoutDetailsNotifier extends StateNotifier<AsyncValue<LobbyDetails?>> {
  LobbyQuickCheckoutDetailsNotifier() : super(const AsyncValue.loading());

  Future<void> fetchLobbyQuickCheckoutDetails(String lobbyId) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      String endPoint = "match/lobby/public/$lobbyId/detail";

      final response = await ApiService().get(endPoint);

      if (response.data != null) {
        kLogger.debug('Lobby details fetched successfully');
        // Update state with data
        state = AsyncValue.data(LobbyDetails.fromJson(response.data));
      } else {
        kLogger.debug('Lobby data not found for ID: $lobbyId');
        // Update state with null data
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      kLogger.error('Error in fetching lobby details: $e \n $stack');

      state = const AsyncValue.loading();
    }
  }

  // Method to manually reset to loading state
  void reset() {
    state = const AsyncValue.loading();
  }
}

// Create the provider
final lobbyQuickCheckoutDetailsProvider =
    StateNotifierProvider.family<LobbyQuickCheckoutDetailsNotifier, AsyncValue<LobbyDetails?>, String>((ref, lobbyId) {
      final notifier = LobbyQuickCheckoutDetailsNotifier();
      // Automatically fetch data when the provider is first accessed
      notifier.fetchLobbyQuickCheckoutDetails(lobbyId);
      return notifier;
    });
