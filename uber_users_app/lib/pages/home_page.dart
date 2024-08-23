import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/authentication/login_screen.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/direction_details.dart';
import 'package:uber_users_app/pages/search_destination_place.dart';
import 'package:http/http.dart' as http;

import '../widgets/loading_dialog.dart';

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
  double seachContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  CommonMethods commonMethods = CommonMethods();
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetailsInfo;
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
      print("postion of the user = $positionOfUser");
      LatLng positionOfUserInLatLang =
          LatLng(currentPositionUser!.latitude, currentPositionUser!.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: positionOfUserInLatLang, zoom: 15);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      await CommonMethods.fetchFormattedAddress(
          positionOfUser.latitude, positionOfUser.longitude, context);
      await getUserInfoAndCheckBlockStatus();
    }
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await userRef.once().then(
      (snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            setState(() {
              userName = (snap.snapshot.value as Map)["name"];
            });
          } else {
            FirebaseAuth.instance.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => const LoginScreen(),
              ),
            );
            commonMethods.displaySnackBar(
                "You are blocked. Contact admin: mughalfahad544@gmail.com",
                context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          commonMethods.displaySnackBar(
              "You record do not exists as a User", context);
        }
      },
    );
  }

  displayUserRideDetailsContainer() async {
    //draw routes
    await retrieveDirectionDetails();

    setState(() {
      seachContainerHeight = 0;
      bottomMapPadding = MediaQuery.of(context).size.height * .30;
      rideDetailsContainerHeight = MediaQuery.of(context).size.height * .25;
    });
  }

  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    var pickupGeoGraphicCoordinate = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffGeoGraphicCoordinate = LatLng(
        dropOffDestinationLocation!.latitudePosition!,
        dropOffDestinationLocation.longitudePosition!);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting details..."),
    );
    var detailsFromDirectionAPI =
        await CommonMethods.getDirectionDetailsFromAPI(
            pickupGeoGraphicCoordinate, dropOffGeoGraphicCoordinate);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    // Close the loading dialog
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: sKey,
        drawer: Container(
          width: 256,
          color: Colors.black87,
          child: Drawer(
            backgroundColor: Colors.white10,
            child: ListView(
              children: [
                Container(
                  color: Colors.black,
                  height: 160,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/avatarman.png",
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Profile",
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.white,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "About",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.grey,
                      ),
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 5, bottom: bottomMapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                updateMapTheme(controllerGoogleMap);
                googleMapCompleterController.complete(controllerGoogleMap);
                getCurrentLiveLocationOfUser();
                setState(() {
                  bottomMapPadding = 120;
                });
              },
            ),
            //Drawer Button
            Positioned(
              top: 15,
              left: 25,
              child: GestureDetector(
                onTap: () {
                  if (sKey.currentState != null) {
                    sKey.currentState!.openDrawer();
                  } else {
                    // You can add a delayed attempt to open the drawer
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (sKey.currentState != null) {
                        sKey.currentState!.openDrawer();
                      }
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 20,
                    child: Icon(
                      Icons.menu,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -80,
              child: SizedBox(
                height: seachContainerHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.all(24),
                      ),
                      onPressed: () async {
                        var responseFromSearchPage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const SearchDestinationPlace(),
                          ),
                        );
                        if (responseFromSearchPage == "placeSelected") {
                          var dropOffLocation =
                              Provider.of<AppInfo>(context, listen: false)
                                  .dropOffLocation;
                          if (dropOffLocation != null) {
                            String placeName = dropOffLocation.placeName ?? "";
                            displayUserRideDetailsContainer();
                            print("Drop Off Location: $placeName");
                          } else {
                            print("Drop Off Location is null.");
                          }
                        }
                      },
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.all(24),
                      ),
                      onPressed: () {},
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.all(24),
                      ),
                      onPressed: () {},
                      child: const Icon(
                        Icons.work,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * .25,
                          child: Card(
                            elevation: 10,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey.shade900,
                              child: Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!.distanceTextString!
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                  .durationTextString!
                                              : "0 Sec",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset(
                                        "assets/images/uberexec.png",
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.1,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                    ),
                                    Text(
                                      (tripDirectionDetailsInfo != null)
                                          ? "\Rs ${(commonMethods.calculateFareAmountInPKR(tripDirectionDetailsInfo!)).toString()}"
                                          : "",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
