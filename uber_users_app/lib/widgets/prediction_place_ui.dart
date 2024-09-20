import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/address_models.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/widgets/loading_dialog.dart';

class PredictionPlaceUI extends StatefulWidget {
  PredictionModel? predictedPlaceData;

  PredictionPlaceUI({super.key, this.predictedPlaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  fetchClickedPlaceDetails(String placeId) async {
    // Show loading dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting details..."),
    );

    // Construct the API URL
    String urlPlaceDetailAPI =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";
    print("Requesting URL: $urlPlaceDetailAPI"); // Debug: Check the URL

    // Send the request to the API
    var responseFromPlaceDetailsAPI =
        await CommonMethods.sendRequestToAPI(urlPlaceDetailAPI);

    // Close the loading dialog
    Navigator.pop(context);

    // Debug: Check if there's an error in the response
    if (responseFromPlaceDetailsAPI == "error") {
      print("Error: Failed to fetch place details");
      return;
    }

    // Debug: Check the response structure
    print("API Response: $responseFromPlaceDetailsAPI");

    // Check the status of the response
    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      AddressModel dropOffLocation = AddressModel();

      // Extract place name
      dropOffLocation.placeName = responseFromPlaceDetailsAPI["result"]["name"];
      print(
          "Place Name: ${dropOffLocation.placeName}"); // Debug: Check place name

      // Extract latitude
      dropOffLocation.latitudePosition =
          responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      print(
          "Latitude: ${dropOffLocation.latitudePosition}"); // Debug: Check latitude

      // Extract longitude
      dropOffLocation.longitudePosition =
          responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];
      print(
          "Longitude: ${dropOffLocation.longitudePosition}"); // Debug: Check longitude

      // Set the place ID
      dropOffLocation.placeID = placeId;
      print("Place ID: ${dropOffLocation.placeID}"); // Debug: Check place ID

      // Update the drop-off location in the provider
      Provider.of<AppInfoClass>(context, listen: false)
          .updateDropOffLocation(dropOffLocation);

      // Pop the current screen and return "placeSelected"
      Navigator.pop(context, "placeSelected");
    } else {
      print(
          "Error: ${responseFromPlaceDetailsAPI["status"]} - ${responseFromPlaceDetailsAPI["error_message"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        fetchClickedPlaceDetails(
            widget.predictedPlaceData!.place_id.toString());
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.share_location,
                color: Colors.grey,
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaceData!.main_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      widget.predictedPlaceData!.secondary_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
