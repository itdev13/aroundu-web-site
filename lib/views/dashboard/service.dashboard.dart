

import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  DashboardService._internal();
  factory DashboardService() {
    return _instance;
  }

  final apiService = ApiService();

  Future<dynamic> updateUserLocation({
    required double lat,
    required double lon,
  }) async {
    final data = {
      "lat": lat,
      "lon": lon,
    };
    final res = await apiService.post(
      "user/api/v1/updateLocation",
      body: data,
    );
    return res.data;
  }

  Future<ProfileModel> getUserIdData() async {
    final res = await apiService.get(
      "user/api/v1/getUserDetailedView",
    );
    return ProfileModel.fromJson(res.data);
  }
}
