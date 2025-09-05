import 'dart:io';
import 'dart:typed_data';

import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// State for the external attendees screen
class ExternalAttendeeState {
  final bool isLoading;
  final bool isUploading;
  final String? fileUrl;
  final List<ManualEntry> manualEntries;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isSuccess;

  ExternalAttendeeState({
    this.isLoading = false,
    this.isUploading = false,
    this.fileUrl,
    this.manualEntries = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  ExternalAttendeeState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? fileUrl,
    List<ManualEntry>? manualEntries,
    String? errorMessage,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return ExternalAttendeeState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      // Use null-aware operator to handle explicit null assignment
      fileUrl: fileUrl, // Remove the ?? this.fileUrl to allow null assignment
      manualEntries: manualEntries ?? this.manualEntries,
      errorMessage: errorMessage, // This is already correctly handling null
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Model for manual entries
class ManualEntry {
  final String mobile;
  final int slots;

  ManualEntry({required this.mobile, required this.slots});

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'slots': slots,
    };
  }
}

// Provider for external attendees
class ExternalAttendeeNotifier extends StateNotifier<ExternalAttendeeState> {
  final String lobbyId;

  ExternalAttendeeNotifier({required this.lobbyId})
      : super(ExternalAttendeeState());

  void removeFileSelection() {
    // Use an empty string instead of null to ensure the state updates
    state = state.copyWith(fileUrl: "");
    // Then set it to null in a separate update to ensure the UI reflects the change
    state = state.copyWith(fileUrl: null);
  }

  // Add this new method to reset the entire state
  void resetState() {
    state = ExternalAttendeeState();
  }

  // Upload Excel file
  Future<void> uploadFile() async {
    try {
      state = state.copyWith(isUploading: true, errorMessage: null);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        withData: true, // Required for web
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final bytes = file.bytes!;
        final filename = file.name;

        final uploadBody = {
          'lobbyId': lobbyId,
          'type': 'external_attendees',
        };

        final response = await FileUploadService().uploadBytes(
          ApiConstants.uploadFile, // API endpoint
          bytes,
          filename,
          uploadBody,
        );

        if (response.statusCode == 200) {
          String fileUrl = response.data.toString().trim();
          state = state.copyWith(fileUrl: fileUrl, isUploading: false);
          _showSnackBar('File uploaded successfully');
        } else {
          throw Exception('Failed to upload file: ${response.statusCode}');
        }
      } else {
        // User canceled the picker
        state = state.copyWith(isUploading: false);
      }
    } catch (e, s) {
      kLogger.error("Error uploading file", error: e, stackTrace: s);
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Error uploading file: ${e.toString()}',
      );
      _showSnackBar('Error uploading file');
    }
  }

  // Add manual entry
  void addManualEntry(String mobile, int slots) {
    if (mobile.isEmpty || slots <= 0) {
      _showSnackBar('Please enter valid mobile number and slots');
      return;
    }

    final entry = ManualEntry(mobile: mobile, slots: slots);
    final updatedEntries = [...state.manualEntries, entry];
    state = state.copyWith(manualEntries: updatedEntries);
  }

  // Remove manual entry
  void removeManualEntry(int index) {
    if (index >= 0 && index < state.manualEntries.length) {
      final updatedEntries = [...state.manualEntries];
      updatedEntries.removeAt(index);
      state = state.copyWith(manualEntries: updatedEntries);
    }
  }

  // Submit external attendees
  Future<bool> submitExternalAttendees() async {
    try {
      // Check if at least one method is provided
      if (state.fileUrl == null && state.manualEntries.isEmpty) {
        _showSnackBar('Please upload a file or add manual entries');
        return false;
      }

      state = state.copyWith(isSubmitting: true, errorMessage: null);

      // Prepare request body
      Map<String, dynamic> requestBody = {
        "lobbyId": lobbyId,
      };

      // Add fileUrl if available
      if (state.fileUrl != null) {
        requestBody["fileUrl"] = state.fileUrl;
      }

      // Add manual entries if available
      if (state.manualEntries.isNotEmpty) {
        requestBody["manualEntries"] =
            state.manualEntries.map((entry) => entry.toJson()).toList();
      }

      // Make API call
      final response = await ApiService().post(
        'match/lobby/external-attendee',
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reset state after successful submission
        resetState();
        return true;
      } else {
        throw Exception(
            'Failed to add external attendees: ${response.statusCode}');
      }
    } catch (e, s) {
      kLogger.error("Error adding external attendees", error: e, stackTrace: s);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error adding external attendees: ${e.toString()}',
      );
      _showSnackBar('Error adding external attendees');
      return false;
    }
  }

  // Helper to show snackbar
  void _showSnackBar(String message) {
    Get.snackbar(
      'External Attendees',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: DesignColors.accent.withOpacity(0.8),
      colorText: Colors.white,
      margin: EdgeInsets.all(8),
    );
  }
}

// Provider definition
final externalAttendeeProvider = StateNotifierProvider.family<
    ExternalAttendeeNotifier, ExternalAttendeeState, String>(
  (ref, lobbyId) => ExternalAttendeeNotifier(lobbyId: lobbyId),
);

// External Attendees Screen
class ExternalAttendeesScreen extends ConsumerStatefulWidget {
  final String lobbyId;

  const ExternalAttendeesScreen({super.key, required this.lobbyId});

  @override
  ConsumerState<ExternalAttendeesScreen> createState() =>
      _ExternalAttendeesScreenState();
}

class _ExternalAttendeesScreenState
    extends ConsumerState<ExternalAttendeesScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _slotsController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(externalAttendeeProvider(widget.lobbyId));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: DesignColors.white,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.black,
            ),
          ),
          title: DesignText(
            text: 'External Attendees',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: _buildSubmitButton(state),
        body: Container(
          color: Colors.white,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       DesignColors.accent.withOpacity(0.05),
          //       Colors.white,
          //     ],
          //   ),
          // ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File Upload Card
                    _buildFileUploadCard(state),
                    SizedBox(height: 24),

                    // Manual Entry Section
                    _buildManualEntrySection(state),
                    SizedBox(height: 24),

                    // Manual Entries List
                    if (state.manualEntries.isNotEmpty) ...[
                      _buildManualEntriesList(state),
                      SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadCard(ExternalAttendeeState state) {
    return Card(
      elevation: 1,
      // shadowColor: DesignColors.accent.withOpacity(0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Colors.white,
          //     DesignColors.accent.withOpacity(0.05),
          //   ],
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: DesignColors.accent,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  DesignText(
                    text: "Upload Excel File",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignColors.border.withOpacity(0.5),
                  ),
                ),
                child: DesignText(
                  text:
                      'Please upload an Excel file with the following structure:\n'
                      '• Column 1: Mobile Number (10 digits)\n'
                      '• Column 2: Number of Slots (integer)',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: DesignColors.secondary,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
              SizedBox(height: 16),
              if (state.fileUrl != null) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: DesignText(
                          text: 'File uploaded successfully',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.green),
                        onPressed: () {
                          ref
                              .read(externalAttendeeProvider(widget.lobbyId)
                                  .notifier)
                              .removeFileSelection();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: DesignButton(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      onPress: () async {
                        final Uri uri = Uri.parse(
                            'https://aroundu.s3.ap-south-1.amazonaws.com//null_1747304546775_external_attendee_sample_file.xlsx');
                        try {
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch URL'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error opening URL: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      bgColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: DesignColors.accent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_outlined,
                            size: 18,
                            color: DesignColors.accent,
                          ),
                          SizedBox(width: 8),
                          DesignText(
                            text: 'Sample File',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DesignButton(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      onPress: state.isUploading
                          ? () {}
                          : () => ref
                              .read(externalAttendeeProvider(widget.lobbyId)
                                  .notifier)
                              .uploadFile(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: state.isUploading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                DesignText(
                                  text: 'Uploading...',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                DesignText(
                                  text: 'Upload Excel',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntrySection(ExternalAttendeeState state) {
    return Card(
      elevation: 1,
      color: Colors.white,
      // shadowColor: DesignColors.accent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Colors.white,
          //     DesignColors.accent.withOpacity(0.05),
          //   ],
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        color: DesignColors.accent,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      DesignText(
                        text: 'Add Attendees',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.primary,
                      ),
                    ],
                  ),
                 GestureDetector(
                  onTap: () {
                      if (_mobileController.text.length == 10 &&
                          _slotsController.text.isNotEmpty) {
                        ref
                            .read(externalAttendeeProvider(widget.lobbyId)
                                .notifier)
                            .addManualEntry(
                              _mobileController.text,
                              int.parse(_slotsController.text),
                            );
                        _mobileController.clear();
                        _slotsController.clear();
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'Please enter a valid 10-digit mobile number and slots',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                        );
                      }
                    },
                   child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: DesignColors.accent,
                          ),
                          SizedBox(width: 8),
                          DesignText(
                            text: 'Add Entry',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignColors.accent,
                          ),
                        ],
                      ),
                 ),
                  
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  // Mobile Number Field
                  Expanded(
                    flex: 4,
                    child: DesignTextField(
                      controller: _mobileController,
                      hintText: 'Mobile Number',
                      inputType: TextInputType.phone,
                      borderRadius: 16,
                      onChanged: (val) {
                        if (val == null) return;
                        if (val.length > 10) {
                          _mobileController.text = val.substring(0, 10);
                          Fluttertoast.showToast(
                            msg: 'Mobile number should be 10 digits',
                          );
                        }
                      },
                      prefixIcon: Icon(
                        Icons.phone_android_outlined,
                        size: 18,
                        color: DesignColors.accent,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Slots Field
                  Expanded(
                    flex: 2,
                    child: DesignTextField(
                      controller: _slotsController,
                      hintText: 'Slots',
                      inputType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      borderRadius: 16,
                      onChanged: (val) {
                        if (val == null || val.isEmpty) return;
                        final numericValue = int.tryParse(val) ?? 0;
                        if (numericValue <= 0) {
                          Fluttertoast.showToast(
                            msg: 'Slots must be a positive number',
                          );
                          _slotsController.text = '';
                        }
                      },
                      prefixIcon: Icon(
                        Icons.chair_outlined,
                        size: 18,
                        color: DesignColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Center(
              //   child: DesignButton(
              //     padding:
              //         EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              //     onPress: () {
              //       if (_mobileController.text.length == 10 &&
              //           _slotsController.text.isNotEmpty) {
              //         ref
              //             .read(
              //                 externalAttendeeProvider(widget.lobbyId).notifier)
              //             .addManualEntry(
              //               _mobileController.text,
              //               int.parse(_slotsController.text),
              //             );
              //         _mobileController.clear();
              //         _slotsController.clear();
              //       } else {
              //         Get.snackbar(
              //           'Invalid Input',
              //           'Please enter a valid 10-digit mobile number and slots',
              //           snackPosition: SnackPosition.BOTTOM,
              //           backgroundColor: Colors.red.withOpacity(0.8),
              //           colorText: Colors.white,
              //         );
              //       }
              //     },
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(
              //           Icons.add_circle_outline,
              //           size: 18,
              //           color: Colors.white,
              //         ),
              //         SizedBox(width: 8),
              //         DesignText(
              //           text: 'Add Entry',
              //           fontSize: 14,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.white,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntriesList(ExternalAttendeeState state) {
    return Card(
      elevation: 4,
      shadowColor: DesignColors.accent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              DesignColors.accent.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    color: DesignColors.accent,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  DesignText(
                    text: 'Manual Entries',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.primary,
                  ),
                  Spacer(),
                  DesignText(
                    text: '${state.manualEntries.length} entries',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: DesignColors.secondary,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignColors.border.withOpacity(0.3),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.manualEntries.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: DesignColors.border.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final entry = state.manualEntries[index];
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: DesignColors.accent.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          color: DesignColors.accent,
                          size: 20,
                        ),
                      ),
                      title: DesignText(
                        text: entry.mobile,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DesignColors.primary,
                      ),
                      subtitle: DesignText(
                        text:
                            '${entry.slots} slot${entry.slots > 1 ? 's' : ''}',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: DesignColors.secondary,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        onPressed: () => ref
                            .read(externalAttendeeProvider(widget.lobbyId)
                                .notifier)
                            .removeManualEntry(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ExternalAttendeeState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: DesignButton(
        padding: EdgeInsets.symmetric(vertical: 16),
        onPress: state.isSubmitting
            ? () {}
            : () async {
                final success = await ref
                    .read(externalAttendeeProvider(widget.lobbyId).notifier)
                    .submitExternalAttendees();

                if (success) {
                  // Show success message
                  CustomSnackBar.show(
                    context: context,
                    message: 'External attendees added successfully',
                    type: SnackBarType.success,
                  );
                } else {
                  CustomSnackBar.show(
                    context: context,
                    message: 'Failed to add External attendees',
                    type: SnackBarType.error,
                  );
                }
                // Navigate back
                Get.back();
              },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: state.isSubmitting
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  DesignText(
                    text: 'Submitting...',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  DesignText(
                    text: 'Submit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
