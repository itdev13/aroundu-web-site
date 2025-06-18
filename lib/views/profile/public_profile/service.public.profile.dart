import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/views/profile/public_profile/public.profile.model.dart';



class PublicProfileService {
  static final PublicProfileService _instance =
      PublicProfileService._internal();
  PublicProfileService._internal();
  factory PublicProfileService() {
    return _instance;
  }

  final apiService = ApiService();

  Future<PublicProfileModel?> getUserPublicProfile(String userId) async {
    final res = await apiService.get(
      // "user/api/v1/getUserDetailedView?userId=$userId",
      "user/api/v1/getUserBasicInfo?userIds=$userId",
    );
    return PublicProfileModel.fromJson(res.data[0]);
  }
}
