import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/fonts.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';



final lobbyPriceProvider =
    StateNotifierProvider<LobbyPriceNotifier, Map<String, dynamic>>((ref) {
  return LobbyPriceNotifier();
});

class LobbyPriceNotifier extends StateNotifier<Map<String, dynamic>> {
  LobbyPriceNotifier() : super({'currencyCode': 'INR', 'value': 0.0});

  void updatePrice(double value) {
    state = {...state, 'value': value};
  }

  void updateCurrency(String code) {
    state = {...state, 'currencyCode': code};
  }

  void resetState() {
    state = {'currencyCode': 'INR', 'value': 0.0};
  }
}

final lobbyAttendeesProvider =
    StateNotifierProvider<LobbyAttendeesNotifier, int>((ref) {
  return LobbyAttendeesNotifier();
});

class LobbyAttendeesNotifier extends StateNotifier<int> {
  LobbyAttendeesNotifier() : super(0);

  void updateAttendees(int count) {
    if (count >= 0) {
      state = count;
    }
  }

  void resetState() {
    state = 0;
  }
}

class LobbySmallEditSheet extends ConsumerStatefulWidget {
  const LobbySmallEditSheet({super.key, required this.lobby});

  final Lobby lobby;

  @override
  ConsumerState<LobbySmallEditSheet> createState() =>
      _LobbySmallEditSheetState();
}

class _LobbySmallEditSheetState extends ConsumerState<LobbySmallEditSheet> {
  late TextEditingController _priceController;
  late TextEditingController _attendeeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lobbyPriceProvider.notifier)
          .updatePrice(
          widget.lobby.priceDetails?.originalPrice ?? widget.lobby.priceDetails?.price ?? 0.0);
      final price = ref.read(lobbyPriceProvider)['value'].toString();
      ref
          .read(lobbyAttendeesProvider.notifier)
          .updateAttendees(widget.lobby.totalMembers);
      final attendees = ref.read(lobbyAttendeesProvider).toString();
      _priceController = TextEditingController(text: price);
      _attendeeController = TextEditingController(text: attendees);
    });
  }

  void _resetState() {
    ref.read(lobbyPriceProvider.notifier).resetState();
    ref.read(lobbyAttendeesProvider.notifier).resetState();
    _priceController.text = '0.0';
    _attendeeController.text = '0';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceState = ref.watch(lobbyPriceProvider);
    final attendeesCount = ref.watch(lobbyAttendeesProvider);

    return SingleChildScrollView(
      child: Container(
       padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        // Using ConstrainedBox to limit maximum height while allowing content to be smaller
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button on the left
                IconButton(
                  icon: DesignIcon.icon(
                    icon: Icons.close,
                    color: const Color(0xFF3E79A1),
                  ),
                  onPressed: () {
                    _resetState();
                    Navigator.pop(context);
                  },
                  // padding: EdgeInsets.zero,
                  // constraints: BoxConstraints(),
                ),
                // Title in center
                DesignText(
                  text: 'Edit Lobby Settings',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF444444),
                ),
                // Save button on the right
                TextButton(
                  onPressed: () async {
                    try {
                      final response = await ApiService().put(
                        "match/lobby/${widget.lobby.id}/critical",
                        {
                          "price": priceState['value'],
                          "totalMembers": attendeesCount,
                        },
                        (json) => json,
                      );
                      Fluttertoast.showToast(msg: response['status']);
                      if (response['status'] == "SUCCESS") {
                        kLogger.debug('Updated successfully');
                        Fluttertoast.showToast(msg: "Updated successfully");
                        // Refresh lobby details after successful update
                        ref
                            .read(
                                lobbyDetailsProvider(widget.lobby.id).notifier)
                            .reset();
                        await ref
                            .read(
                                lobbyDetailsProvider(widget.lobby.id).notifier)
                            .fetchLobbyDetails(widget.lobby.id);
                      } else {
                        kLogger.error('Failed to Updated');
                        Fluttertoast.showToast(
                            msg: "failed to Updated try again later");
                      }
                    } catch (e, stack) {
                      kLogger
                          .error('Error in Updated small edit: $e \n $stack');
                      Fluttertoast.showToast(msg: "something went wrong");
                    }
                    _resetState();
                    Get.back();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const DesignText(
                    text: 'Save',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEC4B5D),
                  ),
                ),
              ],
            ),
        
            const Divider(color: Color(0x4d323232), thickness: 0.4),
            SizedBox(height: 16),
        
            // Price section with card
            Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: 'Set up lobby attending charges',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF444444),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DesignTextField(
                            controller: _priceController,
                            hintText: 'Enter amount',
                            inputType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (value) {
                              ref.read(lobbyPriceProvider.notifier).updatePrice(
                                  double.tryParse(value ?? '0.0') ?? 0.0);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: DesignColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              DesignText(
                                text: priceState['currencyCode'],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF444444),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        DesignText(
                          text: "Per Attendee",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF444444),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        
            SizedBox(height: 24),
        
            // Attendees section with card
            Card(
              elevation: 1,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: "No. of Attendees",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF444444),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Changed from ElevatedButton to IconButton with white background
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFECECEC)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              final count = attendeesCount - 1;
                              if (count < widget.lobby.currentMembers) {
                                Fluttertoast.showToast(
                                    msg: "Can't reduce below total members");
                                ref
                                    .read(lobbyAttendeesProvider.notifier)
                                    .updateAttendees(
                                        widget.lobby.currentMembers);
                                _attendeeController.text =
                                    (widget.lobby.currentMembers).toString();
                                return;
                              } else {
                                ref
                                    .read(lobbyAttendeesProvider.notifier)
                                    .updateAttendees(attendeesCount - 1);
                                _attendeeController.text =
                                    (attendeesCount - 1).toString();
                              }
                            },
                            icon: const Icon(Icons.remove,
                                color: Color(0xFF3E79A1)),
                            padding: EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: DesignColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _attendeeController,
                            textAlign: TextAlign.center,
                            style: DesignFonts.poppins.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444444),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final count = int.parse(value);
                                if (count < widget.lobby.currentMembers) {
                                  Fluttertoast.showToast(
                                      msg: "Can't reduce below total members");
                                  ref
                                      .read(lobbyAttendeesProvider.notifier)
                                      .updateAttendees(
                                          widget.lobby.currentMembers);
                                  _attendeeController.text =
                                      (widget.lobby.currentMembers).toString();
                                  return;
                                } else {
                                  ref
                                      .read(lobbyAttendeesProvider.notifier)
                                      .updateAttendees(int.parse(value));
                                }
                              } else {
                                ref
                                    .read(lobbyAttendeesProvider.notifier)
                                    .updateAttendees(
                                        widget.lobby.currentMembers);
                                _attendeeController.text =
                                    (widget.lobby.currentMembers).toString();
                              }
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Changed from ElevatedButton to IconButton with white background
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFECECEC)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              ref
                                  .read(lobbyAttendeesProvider.notifier)
                                  .updateAttendees(attendeesCount + 1);
                              _attendeeController.text =
                                  (attendeesCount + 1).toString();
                            },
                            icon:
                                const Icon(Icons.add, color: Color(0xFF3E79A1)),
                            padding: EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        
            SizedBox(height: 24),
        
            // Summary section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DesignText(
                    text: "Summary",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF444444),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DesignText(
                        text: "Price per attendee:",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF444444),
                      ),
                      DesignText(
                        text:
                            "${priceState['value']} ${priceState['currencyCode']}",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DesignText(
                        text: "Maximum attendees:",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF444444),
                      ),
                      DesignText(
                        text: "$attendeesCount",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DesignText(
                        text: "Total potential revenue:",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF444444),
                      ),
                      DesignText(
                        text:
                            "${(priceState['value'] * attendeesCount).toStringAsFixed(2)} ${priceState['currencyCode']}",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEC4B5D),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        
            SizedBox(height: 16),
            // Bottom padding to ensure content is not cut off
            SizedBox(
                height:
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
          ],
        ),
      ),
    );
  }
}

//=============================================================================================

// attendance_state

enum AttendanceStatus {
  attending,
  notAttending,
}

final attendanceStatusProvider = StateProvider.autoDispose<AttendanceStatus>(
    (ref) => AttendanceStatus.attending);

class LobbyAttendingStatusBottomSheet extends ConsumerWidget {
  const LobbyAttendingStatusBottomSheet({super.key, required this.lobby});

  final Lobby lobby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceStatus = ref.watch(attendanceStatusProvider);

    return Container(
      height: 324,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: DesignIcon.icon(
                  icon: Icons.cancel_outlined,
                  color: const Color(0xFF3E79A1),
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
          // SizedBox(height: 4),
          Card(
            elevation: 4,
            color: Colors.white,
            shadowColor: const Color(0x143E79A1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DesignText(
                    text: 'Are you attending this Lobby?',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF323232),
                  ),
                  SizedBox(height: 34),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<AttendanceStatus>(
                          title: DesignText(
                            text: 'Attending',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF323232),
                          ),
                          value: AttendanceStatus.attending,
                          groupValue: attendanceStatus,
                          onChanged: (value) {
                            ref.read(attendanceStatusProvider.notifier).state =
                                value ?? AttendanceStatus.attending;
                          },
                          activeColor: const Color(0xFFEC4B5D),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<AttendanceStatus>(
                          title: DesignText(
                            text: 'Not - Attending',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF323232),
                          ),
                          value: AttendanceStatus.notAttending,
                          groupValue: attendanceStatus,
                          onChanged: (value) {
                            if (lobby.priceDetails != null) {
                              if (lobby.priceDetails!.price > 0.0 &&
                                  lobby.isRefundNotPossible) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: DesignText(
                                        text: "Attention!!!",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          "⏳ The refund period for this lobby has expired. Leaving now won’t process a refund.",
                                          style: DesignFonts.poppins.merge(
                                            TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF323232),
                                            ),
                                          ),
                                          maxLines: null,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: DesignText(
                                            text: "Got it",
                                            fontSize: 14,
                                            color: const Color(0xFFEC4B5D),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (lobby.priceDetails!.price > 0.0 &&
                                  lobby.priceDetails.isRefundAllowed) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: DesignText(
                                        text: "Attention!!!",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF444444),
                                      ),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          "🚫 Refunds are not available for this lobby as per the admin’s settings. Exiting now won’t initiate a refund.",
                                          style: DesignFonts.poppins.merge(
                                            TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF323232),
                                            ),
                                          ),
                                          maxLines: null,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: DesignText(
                                            text: "Got it",
                                            fontSize: 14,
                                            color: const Color(0xFFEC4B5D),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }

                            ref.read(attendanceStatusProvider.notifier).state =
                                value ?? AttendanceStatus.attending;
                          },
                          activeColor: const Color(0xFFEC4B5D),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: DesignButton(
              onPress: attendanceStatus == AttendanceStatus.notAttending
                  ? () async {
                      try {
                        final response = await ApiService().delete(
                          "match/lobby/${lobby.id}/member",
                          {},
                        );
                        Fluttertoast.showToast(
                            msg: response == true ? "Success" : "Failed");
                        //Refund initiated or Removed
                        if (response == true) {
                          kLogger.debug('Removed successfully');
                          Fluttertoast.showToast(msg: "Removed successfully");
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: DesignText(
                                  text: "Refund Initiated",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF444444),
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: Text(
                                    "✅ Your refund has been successfully initiated! Expect the amount to be credited within 7-8 business days.",
                                    style: DesignFonts.poppins.merge(
                                      TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF323232),
                                      ),
                                    ),
                                    maxLines: null,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: DesignText(
                                      text: "Got it",
                                      fontSize: 14,
                                      color: const Color(0xFFEC4B5D),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          kLogger.error('Failed to Removed');
                          Fluttertoast.showToast(
                              msg: "failed to Removed try again later");
                        }
                      } catch (e, stack) {
                        kLogger
                            .error('Error in Removed attendee: $e \n $stack');
                        Fluttertoast.showToast(msg: "something went wrong");
                      }
                      Get.back();
                      ref.read(lobbyDetailsProvider(lobby.id).notifier).reset();
                      await ref
                          .read(lobbyDetailsProvider(lobby.id).notifier)
                          .fetchLobbyDetails(lobby.id);
                    }
                  : () {
                      Get.back();
                    },
              title: "Update",
            ),
          ),
        ],
      ),
    );
  }
}
