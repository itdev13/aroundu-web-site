
import 'package:aroundu/models/notifications.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for notification types
enum NotificationType {
  access,
  invitation,
  generic,
  all,
}

// Extension to convert enum to string for API calls
extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.access:
        return 'access';
      case NotificationType.invitation:
        return 'invitation';
      case NotificationType.generic:
        return 'generic';
      case NotificationType.all:
        return '';
    }
  }
}

// State class to hold notification data and pagination info
class NotificationsState {
  final NotificationsMainModel? data;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentOffset;
  final NotificationType type;
  final bool isLoadingMore; // Added for pagination loading state

  NotificationsState({
    this.data,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentOffset = 0,
    this.type = NotificationType.all,
    this.isLoadingMore = false, // Initialize the new property
  });

  NotificationsState copyWith({
    NotificationsMainModel? data,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentOffset,
    NotificationType? type,
    bool? isLoadingMore, // Add to copyWith
  }) {
    return NotificationsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      type: type ?? this.type,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore, // Include in return
    );
  }
}

// Notification notifier to handle state changes
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState());

  // Fetch notifications with type and pagination
  Future<void> fetchNotifications(String userId, {
    NotificationType type = NotificationType.all,
    bool refresh = false,
    int? offset,
    bool isLoadingMore = false, // Add parameter to track if loading more
  }) async {
    try {
      // If refreshing, reset state
      if (refresh) {
        state = NotificationsState(
          isLoading: true,
          type: type,
        );
      } else {
        // If loading more, update loading state
        state = state.copyWith(
          isLoading: !isLoadingMore, // Only set main loading if not loading more
          isLoadingMore: isLoadingMore, // Set loading more state
          error: null,
        );
      }

      // Build URL with type and offset parameters
      String url = 'notification/api/v1/user/$userId';
      
      // Add type parameter if not 'all'
      if (type != NotificationType.all) {
        url += '/?type=${type.value}';
      }
      
      // Add offset parameter if provided
      final currentOffset = offset ?? state.currentOffset;
      if (currentOffset > 0) {
        final separator = url.contains('?') ? '&' : '?';
        url += '$separator''offset=$currentOffset';
      }

      kLogger.debug("Fetching notifications from: $url");
      final response = await ApiService().get(url);

      if (response.data != null) {
        final notifications = NotificationsMainModel.fromJson(response.data);
        
        // Check if we have more data to load
        bool hasMore = true;
        if (notifications.genericNotifications.isEmpty && 
            notifications.accessNotifications.isEmpty && 
            notifications.invitationNotifications.isEmpty) {
          hasMore = false;
        }

        // If refreshing or first load, replace data
        if (refresh || state.data == null) {
          state = state.copyWith(
            data: notifications,
            isLoading: false,
            isLoadingMore: false,
            error: null,
            hasMore: hasMore,
            currentOffset: currentOffset,
            type: type,
          );
        } else {
          // If loading more, merge data
          final mergedData = _mergeNotifications(state.data!, notifications);
          state = state.copyWith(
            data: mergedData,
            isLoading: false,
            isLoadingMore: false,
            error: null,
            hasMore: hasMore,
            currentOffset: currentOffset,
            type: type,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: "Failed to load notifications: No data received",
        );
      }
    } catch (e, s) {
      kLogger.error("Error fetching notifications: $e \n $s");
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: "Failed to fetch notifications: ${e.toString()}",
      );
    }
  }

  // Load more notifications
  Future<void> loadMore(String userId) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    
    // Calculate next offset (multiple of 21)
    final nextOffset = state.currentOffset + 21;
    await fetchNotifications(
      userId,
      type: state.type,
      offset: nextOffset,
      isLoadingMore: true, // Set loading more flag
    );
  }

  // Refresh notifications
  Future<void> refresh(String userId) async {
    await fetchNotifications(
      userId,
      type: state.type,
      refresh: true,
    );
  }

  // Change notification type
  Future<void> changeType(String userId, NotificationType type) async {
    if (type == state.type && state.data != null) return;
    
    await fetchNotifications(
      userId,
      type: type,
      refresh: true,
    );
  }

  // Helper method to merge notifications when paginating
  NotificationsMainModel _mergeNotifications(
    NotificationsMainModel existing,
    NotificationsMainModel newData,
  ) {
    return NotificationsMainModel(
      genericNotifications: [
        ...existing.genericNotifications,
        ...newData.genericNotifications,
      ],
      accessNotifications: [
        ...existing.accessNotifications,
        ...newData.accessNotifications,
      ],
      invitationNotifications: [
        ...existing.invitationNotifications,
        ...newData.invitationNotifications,
      ],
    );
  }
}

// Provider for notifications state
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

// Legacy provider for backward compatibility
final notificationDataProvider = FutureProvider.family<NotificationsMainModel, String>((ref, userId) async {
  final notificationsState = ref.watch(notificationsProvider);
  
  // If data is already loaded, return it
  if (notificationsState.data != null && !notificationsState.isLoading) {
    return notificationsState.data!;
  }
  
  // Otherwise, fetch new data
  await ref.read(notificationsProvider.notifier).fetchNotifications(userId);
  
  // Get the updated state
  final updatedState = ref.read(notificationsProvider);
  
  if (updatedState.error != null) {
    throw Exception(updatedState.error);
  }
  
  if (updatedState.data == null) {
    throw Exception("Failed to load notifications");
  }
  
  return updatedState.data!;
});
