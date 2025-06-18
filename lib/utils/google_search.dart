import 'dart:convert';

import 'package:http/http.dart' as http;

var headers = {'Accept': 'application/json'};

const String baseUrl =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json';
const String queryUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
const String apiKey = 'AIzaSyDFHRpUMz9jXlON6WWU79usPY1Qoqr0v9o';

class StructuredFormatting {
  final String mainText;
  final String secondaryText;

  StructuredFormatting({
    required this.mainText,
    required this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] ?? '',
      secondaryText: json['secondary_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main_text': mainText,
      'secondary_text': secondaryText, // Convert DateTime to String
    };
  }
}

class GoogleSearchResponse {
  final String description;
  final String placeId;
  final StructuredFormatting structuredFormatting;

  GoogleSearchResponse({
    required this.description,
    required this.placeId,
    required this.structuredFormatting,
  });

  factory GoogleSearchResponse.fromJson(Map<String, dynamic> json) {
    return GoogleSearchResponse(
      description: json['description'],
      placeId: json['place_id'],
      structuredFormatting: StructuredFormatting.fromJson(
        json['structured_formatting'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'place_id': placeId,
      'structured_formatting':
          structuredFormatting.toJson(), // Convert DateTime to String
    };
  }
}

class GoogleSearchResponseWrapper {
  final List<GoogleSearchResponse> predictions;

  GoogleSearchResponseWrapper({required this.predictions});

  factory GoogleSearchResponseWrapper.fromJson(Map<String, dynamic> json) {
    List<GoogleSearchResponse> predictions = [];
    for (var prediction in json['predictions']) {
      predictions.add(GoogleSearchResponse.fromJson(prediction));
    }
    return GoogleSearchResponseWrapper(predictions: predictions);
  }
}

class GoogleSearch {
  static Future<GoogleSearchResponseWrapper?> getAutoComplete(
      {required String input,
      required double lat,
      required double lng,
      int radius = 100000}) async {
    var url = Uri.parse(
        '$baseUrl?input=$input&key=$apiKey&location=$lat,$lng&radius=$radius'); //&strictbounds
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return GoogleSearchResponseWrapper.fromJson(
        json.decode(response.body),
      );
    }
    return null;
  }
}

class GoogleLatLng {
  final double lat;
  final double lng;

  GoogleLatLng({
    required this.lat,
    required this.lng,
  });

  factory GoogleLatLng.fromJson(Map<String, dynamic> json) {
    final location = json['results'][0]['geometry']['location'];
    return GoogleLatLng(
      lat: location['lat'],
      lng: location['lng'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  static Future<GoogleSearchResponseWrapper?> getLatLan(String input) async {
    var url = Uri.parse('$queryUrl?place_id=$input&key=$apiKey');
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return GoogleSearchResponseWrapper.fromJson(
        json.decode(response.body),
      );
    }
    return null;
  }
}
