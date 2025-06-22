// import 'package:aroundu/core/services/api.service.dart';

import 'package:aroundu/models/offers_model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/api_service/api_service.dart' as api_service;
import 'package:aroundu/views/lobby/checkout.view.lobby.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:epvi_sales/models/customers_model.dart';
// import 'package:epvi_sales/models/property_overview_model.dart';
// import 'package:epvi_sales/models/sales_dashboard_model.dart';
// import 'package:epvi_sales/models/user_model.dart';
// import 'package:epvi_sales/services/hive/hive.dart';



class Api {
  static Future<dynamic> addPanDetails(String pan) async {
    try {
      final response = await ApiService().post(
        "user/api/v1/savePan",
        body: {
          "pan": pan,
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> addPanDetailsHouse(
      String pan, String name, String houseId) async {
    try {
      final response = await ApiService().post(
        "match/house/savePan",
        body: {
          "pan": pan,
          "name": name,
          "type": "business",
          "houseId": houseId
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> postReport(
      String itemId, String message, String entityType, String type) async {
    try {
      final response = await ApiService().post(
        "match/report",
        body: {
          "itemId": itemId, //lobby id or houseId
          "entityType": entityType, //or HOUSE
          "type": type,
          "message": message
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> verifyPanDetails(
      String pan, String type, String name) async {
    try {
      final response = await ApiService().post(
        "payment/api/verify/pan",
        body: {"pan": pan, "type": type, "name": name},
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> consentAgreement(String entityId, String entityType,
      String agreementUrl, String configId) async {
    try {
      final response = await ApiService().post(
        "match/api/consents",
        body: {
          "entityId": entityId,
          "entityType": entityType,
          "agreementUrl": agreementUrl,
          "configId": configId
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> addBankDetails(
      String ifscCode,
      int accountNumber,
      String accountName,
      String bankName,
      bool isIndividual,
      String upi) async {
    try {
      final endpoint = isIndividual
          ? "user/api/v1/saveBankAccount"
          : "match/house/saveBankAccount";
      final response = await ApiService().post(
        endpoint,
        // final response = await apiClient.post(
        //   "user/api/v1/saveBankAccount",
        body: {
          "ifscCode": ifscCode,
          "accountNumber": accountNumber,
          "accountName": accountName,
          "bankName": bankName,
          "upi": upi
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> addHouseBankDetails(
      String ifscCode,
      int accountNumber,
      String accountName,
      String bankName,
      bool isIndividual,
      String upi,
      String houseId) async {
    try {
      final endpoint = isIndividual
          ? "user/api/v1/saveBankAccount"
          : "match/house/saveBankAccount";
      final response = await ApiService().post(
        endpoint,
        // final response = await apiClient.post(
        //   "user/api/v1/saveBankAccount",
        body: {
          "ifscCode": ifscCode,
          "accountNumber": accountNumber,
          "accountName": accountName,
          "bankName": bankName,
          "upi": upi,
          "houseId": houseId
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> verifyBankDetails(
      {String? ifscCode, int? accountNumber, String? upiId}) async {
    try {
      // final response = await apiClient.post(

      // );
      // async {
      //   try {
      Map<String, dynamic> body = {};
      if (ifscCode != null && accountNumber != null) {
        body = {
          "ifscCode": ifscCode,
          "accountNumber": accountNumber
          // "accountName": accountName,
          // "bankName": bankName
        };
      } else if (upiId != null) {
        body = {"upi": upiId};
      }
      final response = await ApiService().post(
        "payment/api/verify/bank",
        body: body,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> addGstDetails(
      String houseId, String gstIn, String orgName, String orgAddress) async {
    try {
      final response = await ApiService().post(
        "match/house/gst",
        body: {
          "source": "app",
          "houseId": houseId,
          "gstIn": gstIn,
          "orgName": orgName,
          "orgAddress": orgAddress,
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getPanDetails() async {
    try {
      final response = await ApiService().get(
        "user/api/v1/pan",
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getTransactionsHistory(String adminId) async {
    try {
      final response = await ApiService().get(
        "payment/transactions/api/v1/filter",
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getLobbyTransactionsHistory(String adminId) async {
    try {
      final response = await ApiService().get(
        "payment/transactions/api/v1/filter?lobbyId=$adminId",
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getSettingPermission() async {
    try {
      final response = await ApiService().get(
        "user/api/v1/user-settings",
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getFilterOption() async {
    try {
      final response = await ApiService().get(
        "payment/transactions/api/v1/filter",
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> updateSettingPermission(
     {required bool showFollowedHouses,
      required bool receiveNotifications,
      required bool showMoments,
      required bool showLobbiesAttended}) async {
    try {
      final response = await ApiService().post(
        "user/api/v1/user-settings",
        body: {
          "showFollowedHouses": showFollowedHouses,
          "receiveNotifications": receiveNotifications,
          "showMoments": showMoments,
          "showLobbiesAttended": showLobbiesAttended
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> updatePermission(
      String houseId, String gstIn, String orgName, String orgAddress) async {
    try {
      final response = await ApiService().post(
        "match/house/gst",
        body: {
          "source": "app",
          "houseId": houseId,
          "gstIn": gstIn,
          "orgName": orgName,
          "orgAddress": orgAddress,
        },
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> deleteAccount() async {
    try {
      final response = await api_service.ApiService().delete(
        "user/api/v1/deleteUser",
        (json) => json,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getPanHouseDetails(String houseId) async {
    try {
      final response = await ApiService().get("match/house/pan/$houseId");
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getBankDetails() async {
    try {
      final response = await ApiService().get("user/api/v1/bankAccount");
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getHouseBankDetails(String houseId) async {
    try {
      final response =
          await ApiService().get("match/house/bankAccount/$houseId");
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getGstDetails(String houseId) async {
    try {
      final response = await ApiService().get("match/house/gst/$houseId");
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> getAgreementDetails(
      String entityId, bool isIndividual) async {
    try {
      final response = await ApiService().get(
        "match/api/v1/agreementAndCommercials",
        queryParameters: {
          "entityId": entityId,
          "entityType": isIndividual ? "USER" : "HOUSE",
        },
      );

      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  // offers api ......................................

  // static Future<Offer> getOffers(String entityId) async {
  //   try {
  //     final response = await apiClient.get(
  //       "match/offers/fetch",
  //       query: {
  //         "entityId": entityId,
  //         "entityType": "LOBBY",
  //       },
  //     );

  //     return response;
  //   } catch (e) {
  //     if (e is DioException) {
  //       return Future.error("${e.response!.data['error']}");
  //     }
  //     return Future.error("error");
  //   }
  // }
  static Future<List<Offer>> getOffers({
    required String entityId,
    required bool isApplicable,
    WidgetRef? ref,
  }) async {
    int slots = 1;
    if (ref != null) {
      slots = ref.watch(counterProvider);
    }
    final response = await ApiService().get(
      (isApplicable)
          ? "match/offers/applicable?entityId=$entityId&entityType=LOBBY&slots=$slots"
          : "match/offers/fetch?entityId=$entityId&entityType=LOBBY",
    );

    if (response.data is String && response.data.trim().isEmpty) {
      return [];
    }

    if (response.data != null) {
      List<dynamic> jsonList = response.data;
      // Ensure response.data is a list
      return jsonList.map((json) => Offer.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<dynamic> addOffers(
      String entityId,
      String entityType,
      String discountType,
      String startDate,
      String endDate,
      dynamic discountValue,
      List<String> applicableTo) async {
    List<String> mappedValues = [];

    for (String value in applicableTo) {
      switch (value) {
        case "All":
          mappedValues.add("ALL");
          break;
        case "First-time joiner – Welcome new attendees.":
          mappedValues.add("FIRST_TIME_JOINER");
          break;
        case "Frequent joiner – Joined 50%+ lobbies.":
          mappedValues.add("FREQUENT_JOINER");
          break;
        case "Early bird – Joined within 12 hours.":
          mappedValues.add("EARLY_BIRD");
          break;
        case "Birthday – Special offer.":
          mappedValues.add("BIRTHDAY");
          break;
        case "Couple":
          mappedValues.add("COUPLE");
          break;
        case "Female only":
          mappedValues.add("FEMALE_ONLY");
          break;
        case "Small group (<3)":
          mappedValues.add("GROUP_SMALL");
          break;
        case "Medium group (3-5)":
          mappedValues.add("GROUP_MEDIUM");
          break;
        case "Large group (≥6)":
          mappedValues.add("GROUP_LARGE");
          break;
        case "Friends":
          mappedValues.add("FRIENDS");
          break;
        case "House members":
          mappedValues.add("HOUSE_MEMBERS");
          break;
        default:
          break;
      }
    }
    print(mappedValues);
    try {
      Map<String, dynamic> body = {
        "entityId": entityId, //add lobbyid
        "entityType": entityType,
        "discountType": discountType.toUpperCase(),
        "discountValue": discountValue,
        "applicableTo": mappedValues
      };

// Add dates if both start and end dates are provided
      if (startDate != null && startDate.isNotEmpty) {
        body["startDate"] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        body["endDate"] = endDate;
      }

      final response = await ApiService().post(
        "match/offers/create",
        body: body,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  static Future<dynamic> editOffers(
      String entityId,
      String entityType,
      String discountType,
      String startDate,
      String endDate,
      dynamic discountValue,
      List<String> applicableTo) async {
    try {
      Map<String, dynamic> body = {
        "entityId": entityId, //add lobbyid
        "entityType": entityType,
        "discountType": discountType.toUpperCase(),
        "discountValue": discountValue,
        "startDate": startDate, //optional
        "endDate": endDate, //optional
        "applicableTo": applicableTo
            .map((e) => e.toUpperCase().replaceAll(' ', '_'))
            .toList()
      };

      // Add dates if both start and end dates are provided
      if (startDate != null && startDate.isNotEmpty) {
        body["startDate"] = startDate;
      }

      if (endDate != null && endDate.isNotEmpty) {
        body["endDate"] = endDate;
      }

      final response = await api_service.ApiService().put(
        "match/offers/create",
        body,
        (json) => json,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        return Future.error("${e.response!.data['error']}");
      }
      return Future.error("error");
    }
  }

  // static Future<dynamic> deleteOffers(String entityId) async {
  //   try {
  //     final response = await apiClient.delete(
  //       "match/offers/delete/67af90fc2e57d66d56063f25",
  //       query: {},
  //     );
  //     if (response.statusCode == 204) {
  //       print("Offer deleted successfully");
  //       // return response;
  //     }
  //     return response;
  //   } catch (e) {
  //     if (e is DioException) {
  //       return Future.error("${e.response?.data['error'] ?? 'Unknown error'}");
  //     }
  //     return Future.error("Error fetching offers");
  //   }
  // }

  static Future<bool> deleteOffers(String entityId) async {
    try {
      final response = await api_service.ApiService()
          .delete("match/offers/delete/$entityId", {});

      if (response) {
        print("Offer deleted successfully");
        return response;
      } else {
        print("Unexpected response");
        return Future.error("Unexpected error while deleting offer");
      }
    } catch (e, stack) {
      print("General Exception: $e \n $stack");
      return Future.error("Unexpected error while deleting offer");
    }
  }
}
