import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers_app/global/global.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? getPositionOfUser;

  //for updating the google style

  // void updateMapTheme(GoogleMapController controller){
  //   getJsonFileFromThemes("themes/dark_style.json").then((value)=> setGoogleMapStyle(value, controller));
  // }

  // Future<String> getJsonFileFromThemes(String mapStylePath) async {
  //   ByteData byteData = await rootBundle.load(mapStylePath);
  //   var list = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  //   return utf8.decode(list);
  // }

  // setGoogleMapStyle(String googleMapStyle, GoogleMapController controller){
  //   controller.setMapStyle(googleMapStyle);
  // }


  getCurrentLiveLocationUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    getPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLang = LatLng(getPositionOfUser!.latitude, getPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLang, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(initialCameraPosition: googlePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController mapController){
              controllerGoogleMap = mapController;
              googleMapCompleterController.complete(controllerGoogleMap);
              //updateMapTheme(controllerGoogleMap);
              getCurrentLiveLocationUser();
            },
            )
          ],
        )
      ),
    );
  }
}