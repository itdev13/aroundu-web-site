import 'dart:io' show Platform;
import 'dart:html' as html;
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
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_register_provider.dart';
import 'package:aroundu/views/lobby/widgets/infoCard.dart';
import 'package:aroundu/views/lobby/widgets/rich_text_display.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/api_service/api.service.dart';

class LobbyQuickCheckoutView extends ConsumerStatefulWidget {
  const LobbyQuickCheckoutView({super.key, required this.lobbyId});
  final String lobbyId;

  @override
  ConsumerState<LobbyQuickCheckoutView> createState() => _LobbyQuickCheckoutViewState();
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

class _LobbyQuickCheckoutViewState extends ConsumerState<LobbyQuickCheckoutView> {
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Initialize counter with 1
    ref.read(quickCheckoutCounterProvider.notifier).setValue(1);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      kLogger.error('Flutter Error: ${details.exception}');
      kLogger.error('Stack trace: ${details.stack}');
    };

    Future.microtask(() async {
      await ref
          .read(lobbyQuickCheckoutDetailsProvider(widget.lobbyId).notifier)
          .fetchLobbyQuickCheckoutDetails(widget.lobbyId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // Method to handle checkout process
  void _handleCheckout(Lobby lobbyData) {
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

    setState(() {
      _isProcessing = true;
    });

    // Get the number of slots from the counter provider
    final slotCount = ref.read(quickCheckoutCounterProvider);

    // Call the lobby registration provider
    final registrationNotifier = ref.read(lobbyRegistrationProvider(widget.lobbyId).notifier);

    registrationNotifier
        .registerGuest(widget.lobbyId, _nameController.text, _mobileController.text, _emailController.text, slotCount)
        .then((response) {
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
            _redirectToPaymentUrl(response.paymentUrl!);
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
  void _redirectToPaymentUrl(String url) {
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
              Expanded(flex: 1, child: _buildCheckoutForm(context, lobbyData)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Approximate location
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: DesignColors.white, borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, color: DesignColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: 'Location',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.secondary,
                    ),
                    SizedBox(height: 4),
                    DesignText(
                      text: (locationInfo?.googleSearchResponses.first.description ?? 'Unknown location'),
                      fontSize: 14,
                      color: DesignColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      lobbyData.mediaUrls!.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[500])),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 16),

                // Lobby description
                DesignText(text: 'Description', fontSize: 18, fontWeight: FontWeight.bold, color: DesignColors.primary),
                RichTextDisplay(
                  controller: TextEditingController(text: lobbyData.description),
                  hintText: '',
                  lobbyId: lobbyData.id,
                ),

                // Lobby details in a grid
                _buildLobbyDetailsGrid(lobbyData, isDesktop),

                // Price details if available
                if (lobbyData.priceDetails != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      DesignText(
                        text: 'Price Details',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignColors.primary,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DesignText(text: 'Price per slot:', fontSize: 16, color: DesignColors.secondary),
                          DesignText(
                            text: '₹${lobbyData.priceDetails?.price ?? 0}',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DesignColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
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

  // Build the checkout form
  Widget _buildCheckoutForm(BuildContext context, Lobby lobbyData) {
    final deviceType = DesignUtils.getDeviceType(context);
    final isDesktop = deviceType == DeviceScreenType.desktop;
    final padding = isDesktop ? EdgeInsets.all(24) : EdgeInsets.all(16);
    final slotCount = ref.watch(quickCheckoutCounterProvider);
    final slotPrice = lobbyData.priceDetails?.price ?? 0.0;
    final totalPrice = slotPrice * slotCount;

    // Check if lobby is active or upcoming
    final bool isLobbyAvailable = lobbyData.lobbyStatus == "ACTIVE" || lobbyData.lobbyStatus == "UPCOMING";

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
                            DesignText(
                              text: 'Checkout',

                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: DesignColors.primary,
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
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: DesignColors.border.withOpacity(0.5), width: 1),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 2)),
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
                                              onTap: () {
                                                ref.read(quickCheckoutCounterProvider.notifier).decrement();
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
                                                      isHovered ? DesignColors.primary.withOpacity(0.05) : Colors.white,
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
                                              onTap: () {
                                                ref.read(quickCheckoutCounterProvider.notifier).increment();
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
                                                      isHovered ? DesignColors.primary.withOpacity(0.05) : Colors.white,
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
                            ),
                            SizedBox(height: 24),

                            // Price summary
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: DesignColors.border.withOpacity(0.5), width: 1),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      DesignText(text: 'Price per slot:', fontSize: 16, color: DesignColors.secondary),
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
                                            text: '₹$slotPrice',
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
                                      DesignText(text: 'Number of slots:', fontSize: 16, color: DesignColors.secondary),
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
                                        onPress: () => _handleCheckout(lobbyData),
                                        title: _isProcessing ? 'Processing...' : 'Proceed to Checkout',
                                        isLoading: _isProcessing,
                                        padding: EdgeInsets.symmetric(vertical: 16),
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
                                        "After successfull checkout, you will get you tickets and other details on your entered email.",
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
