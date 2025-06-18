import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

// State class for notification action
class NotificationActionState {
  final bool isLoading;
  final bool isCompleted;
  final String? error;

  NotificationActionState({
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
  });

  NotificationActionState copyWith({
    bool? isLoading,
    bool? isCompleted,
    String? error,
  }) {
    return NotificationActionState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

// Provider family that creates a unique provider for each notification ID
final notificationActionProvider = StateNotifierProviderFamily<
  NotificationActionNotifier,
  NotificationActionState,
  String
>((ref, id) => NotificationActionNotifier());

class NotificationActionNotifier
    extends StateNotifier<NotificationActionState> {
  NotificationActionNotifier() : super(NotificationActionState());

  Future<bool> performAction({
    required BuildContext context,
    required String id,
    required String action,
  }) async {
    // Set loading state
    state = state.copyWith(isLoading: true);

    try {
      // Make API call
      final body = {'id': id, 'action': action};

      final response = await ApiService().post(
        "notification/api/v1/notificationAction",
        body: body,
      );

      if (response.statusCode == 200) {
        // Success
        CustomSnackBar.show(
          context: context,
          message: "Action completed successfully",
          type: SnackBarType.success,
        );

        // Update state to completed
        state = state.copyWith(
          isLoading: false,
          isCompleted: true,
          error: null,
        );
        return true;
      } else {
        // Error
        final errorMessage =
            "Failed to complete action: ${response.statusCode}";
        CustomSnackBar.show(
          context: context,
          message: errorMessage,
          type: SnackBarType.success,
        );

        // Update state with error
        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    } catch (e) {
      // Show error toast
      final errorMessage = "Error: ${e.toString()}";
     CustomSnackBar.show(
        context: context,
        message: errorMessage,
        type: SnackBarType.success,
      );

      // Update state with error
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }
}
