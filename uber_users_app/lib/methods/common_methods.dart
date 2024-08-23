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

// Example function to extract the formatted address from the API response
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiGeoCodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error" && responseFromAPI["results"].isNotEmpty) {
      // Extracting the formatted address
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];
      print("HumanReadableAddress = $humanReadableAddress");
    } else {
      //humanReadableAddress = "Address not found";
      print("address not found");
    }
    return humanReadableAddress;
  }

  static Future<String?> fetchFormattedAddress(
      double latitude, double longitude, BuildContext context) async {
    const String apiKey = googleMapKey;
    const String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

    final String latlng = '$latitude,$longitude';
    final Uri url = Uri.parse('$baseUrl?latlng=$latlng&key=$apiKey');

    print("API Request URL: $url"); // Debug line to check the URL

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'OK') {
        String formattedAddress =
            jsonResponse['results'][0]['formatted_address'];
        print('Formatted Address: $formattedAddress');

        AddressModel model = AddressModel();
        model.humanReadableAddress = formattedAddress;
        model.latitudePosition = latitude;
        model.longitudePosition = longitude;

        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocation(model);
        return formattedAddress;
      } else {
        print(
            'Error: ${jsonResponse['status']} - ${jsonResponse['error_message']}');
        return null;
      }
    } else {
      print('Failed to load data: ${response.statusCode}');
      return null;
    }
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
}
