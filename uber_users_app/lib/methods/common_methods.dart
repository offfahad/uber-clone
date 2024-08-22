import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/models/address_models.dart';

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
}
