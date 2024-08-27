import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers_app/global/global.dart';
import 'package:uber_drivers_app/pushNotifications/push_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionUser;
  Color colorToShow = Colors.green;
  String titleToShow = 'Go Online Now';
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;

  void updateMapTheme(GoogleMapController? controller) {
    getJsonFileFromThemes("themes/night_style.json")
        .then((value) => setGoogleMapStyle(value, controller!));
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    if (controllerGoogleMap != null) {
      Position positionOfUser = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPositionUser = positionOfUser;
      LatLng positionOfUserInLatLang =
          LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: positionOfUserInLatLang, zoom: 15);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  goOnlineNow() {
    //all drivers who are available for work
    Geofire.initialize("onlineDrivers");
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        currentPositionUser!.latitude, currentPositionUser!.longitude);
    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");
    newTripRequestReference!.onValue.listen((event) {});
  }

  goOfflineNow() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionUser = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
            currentPositionUser!.latitude, currentPositionUser!.longitude);
      }
      LatLng positionLatLang =
          LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLang));
    });
  }
  initalizePushNotificationSystem(){
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initalizePushNotificationSystem();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                updateMapTheme(controllerGoogleMap);
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfUser();
              },
            ),
            Positioned(
              top: 8,
              left: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(
                                      0.7,
                                      0.7,
                                    ),
                                  ),
                                ],
                              ),
                              height: 221,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 18),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 11),
                                    Text(
                                      (!isDriverAvailable)
                                          ? "Go Online Now"
                                          : "Go Offline Now",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 21,
                                    ),
                                    Text(
                                      (!isDriverAvailable)
                                          ? "You are about to go online, you will become available to receive trip requests from users."
                                          : "You are about to go offline, you will stop receiving new trip requests from users",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        //fontSize: 22,
                                        color: Colors.white30,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 22,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Back",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (!isDriverAvailable) {
                                                //go online
                                                goOnlineNow();
                                                //get driver location
                                                setAndGetLocationUpdates();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.pink;
                                                  titleToShow =
                                                      "Go Offline Now";
                                                  isDriverAvailable = true;
                                                });
                                              } else {
                                                //go offline
                                                goOfflineNow();
                                                Navigator.pop(context);
                                                setState(() {
                                                  colorToShow = Colors.green;
                                                  titleToShow = "Go Online Now";
                                                  isDriverAvailable = false;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: (titleToShow ==
                                                      "Go Online Now"
                                                  ? Colors.green
                                                  : Colors.pink),
                                            ),
                                            child: const Text(
                                              "Confirm",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorToShow,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0))),
                    child: Text(
                      titleToShow,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
