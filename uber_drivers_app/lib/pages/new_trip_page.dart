import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/methods/map_theme_methods.dart';
import 'package:uber_drivers_app/models/trip_details.dart';
import 'package:uber_drivers_app/widgets/loading_dialog.dart';

import '../global/global.dart';

class NewTripPage extends StatefulWidget {
  TripDetails? newTripDetailsInfo;
  NewTripPage({super.key, this.newTripDetailsInfo});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;

  obtainDirectionAndDrawRoute(
      sourcetLocationLatLng, destinationLocationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          const LoadingDialog(messageText: "Please wait"),
    );
    var tripdDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(sourcetLocationLatLng, destinationLocationLatLng);

    Navigator.pop(context);
    


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);
              setState(() {
                googleMapPaddingFromBottom = 262;
              });

              var driverCurrentLocationLatLng = LatLng(
                  driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userPickUpLocationLatLng =
                  widget.newTripDetailsInfo!.pickUpLatLng;

              //getCurrentLiveLocationOfUser();
            },
          ),
        ],
      ),
    );
  }
}
