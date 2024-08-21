import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_users_app/authentication/login_screen.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';

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

  CommonMethods commonMethods = CommonMethods();
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
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
                    Future.delayed(Duration(milliseconds: 100), () {
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
            )
          ],
        ),
      ),
    );
  }
}
