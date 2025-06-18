class ApiConstants {
  static const String baseUrl = 'https://api.aroundu.in/';
  static const String profile = 'user/api/v1/getProfile/';
  static const String updateBasicProfile = 'user/api/v1/updateBasicProfile/';
  static const String updateProfileInterest =
      'user/api/v1/updateProfileInterest';
  static String updateUserInterest = 'user/api/v1/updateUserInterests';
  static const String profileInterest =
      'match/category/api/v1/getAll/PROFILE_INFO';
  static const String userInterest = 'match/category/api/v1/getAll/INTERESTS';
  static const String userRecommendations =
      'match/user/api/v1/userRecommendations';
  static const String lobbyFields = 'match/api/v1/getFilters';
  static const String createLobby = 'match/lobby';
  static const String getLobbies = 'match/lobby';
  static const String getHouses = 'match/house/all';
  static const String updateDeviceToken = "user/api/v1/updateDeviceToken";
  static const String uploadFile = 'user/upload/api/v1/file';
  static const String saveItem = 'match/saved-items';
}
