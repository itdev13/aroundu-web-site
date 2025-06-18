import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  final phoneNumber = ''.obs;
  final countryCode = '+91'.obs;
  final isLoading = false.obs;

  void updatePhoneNumber(String number) {
    phoneNumber.value = number;
  }

  void updateCountryCode(String code) {
    countryCode.value = code;
  }

  String getFullPhoneNumber() {
    // return '${countryCode.value}${phoneNumber.value.trim()}';
    return phoneNumber.value.trim();
    
  }
}