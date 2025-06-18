import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// This part will generate the required code.
part 'save_lobby_provider.g.dart';

// Function-based provider to toggle the bookmark status
@riverpod
Future<void> toggleBookmark(
  Ref ref, {
  required String itemId,
  required bool isSaved,
  required String entityType,
}) async {
  if (isSaved) {
    // Remove bookmark if it's already saved
    await _removeBookmark(itemId, entityType);
  } else {
    // Add bookmark if it's not saved
    await _addBookmark(itemId, entityType);
  }
}

// Function to add a bookmark (POST request)
Future<void> _addBookmark(String itemId, String entityType) async {
  try {
    final response = await ApiService().post(
      ApiConstants.saveItem, // API endpoint
      {'itemId': itemId, 'entityType': entityType}, // Payload
      (json) => json,
      // useFormUrlEncoded: true, // Use form data
    );
    kLogger.debug('Bookmark added successfully: $response');
  } catch (e) {
    kLogger.error('Error adding bookmark: $e');
    rethrow;
  }
}

// Function to remove a bookmark (DELETE request)
Future<void> _removeBookmark(String itemId, String entityType) async {
  try {
    final response = await ApiService().delete(
      ApiConstants.saveItem, // API endpoint to remove the lobby
      {'itemId': itemId, 'entityType': entityType},
    );
    if (response) {
      kLogger.debug('Bookmark removed successfully: $response');
    }
  } catch (e) {
    kLogger.error('Error removing bookmark: $e');
    rethrow;
  }
}
