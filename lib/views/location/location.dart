import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/google_search.dart';
import 'package:aroundu/views/dashboard/controller.dashboard.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../designs/colors.designs.dart';
import '../../../designs/fonts.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final String _text = '';
  double _lat = 20.593683;
  double _lng = 78.962883;
  String? _currentAddress;
  Position? _currentPosition;
  GoogleSearchResponseWrapper? _predictions = GoogleSearchResponseWrapper(
    predictions: [],
  );
  GoogleSearchResponse? _selectedPrediction;

  final DashboardController dashboardController =
      Get.put(
    DashboardController());

  final FocusNode locationSearchFocusNode = FocusNode();

  @override
  void initState() {
    _fetchLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationSearchFocusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    locationSearchFocusNode.dispose();
    super.dispose();
  }

  _fetchLocation() async {
    await dashboardController.getUserCurrentLocation();
    _lat = dashboardController.userLocation['lat'];
    _lng = dashboardController.userLocation['lng'];
  }

  _handleSearch(
      {required String input, required double lat, required double lng}) {
    GoogleSearch.getAutoComplete(input: input, lat: lat, lng: lng, radius: 5000)
        .then((value) {
      if (value != null) {
        setState(() {
          _predictions = value;
        });
      }
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 16, left: 8, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        focusNode: locationSearchFocusNode,
                        onChanged: (value) => _handleSearch(
                          input: value,
                          lat: _lat,
                          lng: _lng,
                        ),
                        style: DesignFonts.poppins.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true, // Enables background color
                          fillColor: Colors.white,
                          counterStyle: DesignFonts.poppins.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: DesignColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: DesignColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: DesignColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: DesignColors.accent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorStyle: DesignFonts.poppins.copyWith(
                            color: DesignColors.accent,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 14,
                                  ),
                                  onPressed: () {
                                    _handleSearch(
                                      input: '',
                                      lat: _lat,
                                      lng: _lng,
                                    );
                                  },
                                )
                              : null,
                          hintText: 'Search for your area or apartment name',
                          hintStyle: DesignFonts.poppins.copyWith(
                            color: DesignColors.primary.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Space.h(height: 16),

                      // TextButton(
                      //   onPressed: () {
                      //     _getCurrentPosition();
                      //   },
                      //   child: const Row(
                      //     children: [
                      //       Icon(
                      //         Icons.near_me,
                      //         size: 16,
                      //       ),
                      //       SizedBox(width: 4),
                      //       Text('Use my current location'),
                      //     ],
                      //   ),
                      // ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (final prediction
                                  in _predictions!.predictions)
                                ListTile(
                                  title: Row(
                                    children: [
                                      Icon(Icons.near_me, size: 16),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: DesignText(
                                          text: prediction
                                              .structuredFormatting.mainText,
                                          fontSize: 14,
                                          maxLines: 1,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: DesignText(
                                    text: prediction
                                        .structuredFormatting.secondaryText,
                                    fontSize: 12,
                                    maxLines: 1,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedPrediction = prediction;
                                    });
                                    Navigator.pop(context, _selectedPrediction);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
