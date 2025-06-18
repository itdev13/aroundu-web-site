import 'package:aroundu/views/profile/public_profile/public.profile.model.dart';
import 'package:aroundu/views/profile/public_profile/service.public.profile.dart';
import 'package:get/get.dart';

class PublicProfileController extends GetxController {
  final service = PublicProfileService();
  final isLoading = true.obs;
  final Rx<PublicProfileModel?> publicProfileData =
      Rx<PublicProfileModel?>(null);

  Future<void> getUserPublicProfileData(String userId) async {
    try {
      isLoading.value = true;
      publicProfileData.value =
          await service.getUserPublicProfile(userId); // Fetch profile data
    } catch (e, stackTrace) {
      // Handle error if necessary
      print("Error fetching user data: $e \n $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }
}
