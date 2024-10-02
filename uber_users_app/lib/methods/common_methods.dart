import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/models/address_models.dart';

import '../models/direction_details.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar(
          "Your Internet is not Available. Check your connection. Try Again.",
          context);
    }
  }

  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        print('error');
        return "error";
      }
    } catch (errorMsg) {
      print(errorMsg);
      return "error";
    }
  }

  ///Reverse GeoCoding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiGeoCodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error") {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfoClass>(context, listen: false)
          .updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  /// This method shortens the full address by extracting key parts.
  static String shortenAddress(String fullAddress) {
    // Split the address by commas
    List<String> parts = fullAddress.split(',');

    // Return a shorter version of the address: e.g., "Street Name, City"
    if (parts.length >= 2) {
      return "${parts[0].trim()}, ${parts[1].trim()}";
    }

    // If the address has fewer parts, return it as is
    return fullAddress;
  }

  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      LatLng source, LatLng destination) async {
    String urlDirectionAPI =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    print("URL: $urlDirectionAPI"); // Debugging: Log the URL

    var responseFromDirectionAPI = await sendRequestToAPI(urlDirectionAPI);

    if (responseFromDirectionAPI == "error") {
      print("Error in response"); // Debugging: Log error
      return null;
    }

    print("Response: $responseFromDirectionAPI"); // Debugging: Log the response

    if (responseFromDirectionAPI["routes"] == null ||
        responseFromDirectionAPI["routes"].isEmpty) {
      print("No routes found in the response.");
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    try {
      directionDetails.distanceTextString =
          responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["text"];
      directionDetails.distanceValueDigit =
          responseFromDirectionAPI["routes"][0]["legs"][0]["distance"]["value"];
      directionDetails.durationTextString =
          responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["text"];
      directionDetails.durationValueDigit =
          responseFromDirectionAPI["routes"][0]["legs"][0]["duration"]["value"];
      directionDetails.encodedPoints =
          responseFromDirectionAPI["routes"][0]["overview_polyline"]["points"];
    } catch (e) {
      print("Error processing response data: $e");
      return null;
    }
    return directionDetails;
  }

  calculateFareAmountInPKR(DirectionDetails directionDetails,
      {double surgeMultiplier = 1.0}) {
    double distancePerKmAmountPKR = 20; // 20 PKR per km
    double durationPerMinuteAmountPKR = 15; // 15 PKR per minute
    double baseFareAmountPKR = 150; // Base fare in PKR
    double bookingFeePKR = 50; // Booking fee in PKR
    double minimumFarePKR = 200; // Minimum fare in PKR

    // Calculate fare based on distance and time
    double totalDistanceTravelledFareAmountPKR =
        (directionDetails.distanceValueDigit! / 1000) * distancePerKmAmountPKR;
    double totalDurationSpendFareAmountPKR =
        (directionDetails.durationValueDigit! / 60) *
            durationPerMinuteAmountPKR;

    // Total fare before applying surge
    double totalFareBeforeSurgePKR = baseFareAmountPKR +
        totalDistanceTravelledFareAmountPKR +
        totalDurationSpendFareAmountPKR +
        bookingFeePKR;

    // Apply surge pricing
    double overAllTotalFareAmountPKR =
        totalFareBeforeSurgePKR * surgeMultiplier;

    // Apply minimum fare
    if (overAllTotalFareAmountPKR < minimumFarePKR) {
      overAllTotalFareAmountPKR = minimumFarePKR;
    }

    return overAllTotalFareAmountPKR.toStringAsFixed(2);
  }

  // Utility function to format time from total minutes into "X hours Y mins"
  String formatTime(int totalMinutes) {
    int hours = totalMinutes ~/ 60; // Get the number of full hours
    int minutes = totalMinutes % 60; // Get the remaining minutes
    if (hours > 0) {
      return "$hours hours $minutes mins";
    } else {
      return "$minutes mins"; // If there are no hours, just show minutes
    }
  }
}
