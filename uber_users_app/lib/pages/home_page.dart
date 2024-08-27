import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/authentication/login_screen.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/methods/manage_drivers_methods.dart';
import 'package:uber_users_app/models/direction_details.dart';
import 'package:uber_users_app/models/online_nearby_drivers.dart';
import 'package:uber_users_app/pages/search_destination_place.dart';
import 'package:http/http.dart' as http;
import 'package:uber_users_app/widgets/info_dialog.dart';

import '../widgets/loading_dialog.dart';
import '../global/trip_var.dart';

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
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;

  CommonMethods commonMethods = CommonMethods();
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetailsInfo;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylineSet = {};

  bool isDrawerOpen = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers> availableNearbyOnlineDriversList = [];
  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(
        context,
        size: Size(0.5, 0.5),
      );
      BitmapDescriptor.fromAssetImage(
              configuration, "assets/images/tracking.png")
          .then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

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

      await initlaizeGeoFireListner();
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
              userPhone = (snap.snapshot.value as Map)["phone"];
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
      rideDetailsContainerHeight = MediaQuery.of(context).size.height * .30;
      isDrawerOpen = false;
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = MediaQuery.of(context).size.height * .30;
      bottomMapPadding = MediaQuery.of(context).size.height * .30;
      isDrawerOpen = true;
    });

    //send ride request
    makeTripRequest();
  }

  makeTripRequest() {
    tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequest").push();

    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    Map pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };
    Map dropOffDesitinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoOrdinates = {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "username": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDesitinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,
      "driverId": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new"
    };

    tripRequestRef!.set(dataMap);
  }

  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    var pickupGeoGraphicCoordinate = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffDestinationGraphicCoordinate = LatLng(
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
            pickupGeoGraphicCoordinate, dropOffDestinationGraphicCoordinate);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    // Close the loading dialog
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> latlngPointsFromPickUpToDestination =
        polylinePoints.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);
    polylineCoordinates.clear();

    polylineSet.clear();
    if (latlngPointsFromPickUpToDestination.isNotEmpty) {
      latlngPointsFromPickUpToDestination.forEach((PointLatLng latlngPoint) {
        polylineCoordinates
            .add(LatLng(latlngPoint.latitude, latlngPoint.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("polylineID"),
          color: Colors.blue,
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickupGeoGraphicCoordinate.latitude >
            dropOffDestinationGraphicCoordinate.latitude &&
        pickupGeoGraphicCoordinate.longitude >
            dropOffDestinationGraphicCoordinate.longitude) {
      latLngBounds = LatLngBounds(
          southwest: dropOffDestinationGraphicCoordinate,
          northeast: pickupGeoGraphicCoordinate);
    } else if (pickupGeoGraphicCoordinate.longitude >
        dropOffDestinationGraphicCoordinate.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoordinate.latitude,
            dropOffDestinationGraphicCoordinate.longitude),
        northeast: LatLng(dropOffDestinationGraphicCoordinate.latitude,
            pickupGeoGraphicCoordinate.longitude),
      );
    } else if (pickupGeoGraphicCoordinate.latitude >
        dropOffDestinationGraphicCoordinate.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(dropOffDestinationGraphicCoordinate.latitude,
            pickupGeoGraphicCoordinate.longitude),
        northeast: LatLng(pickupGeoGraphicCoordinate.latitude,
            dropOffDestinationGraphicCoordinate.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(
          southwest: pickupGeoGraphicCoordinate,
          northeast: dropOffDestinationGraphicCoordinate);
    }

    controllerGoogleMap!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBounds, 72),
    );
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarker"),
      position: pickupGeoGraphicCoordinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOfDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOfDestinationPointMarker"),
      position: dropOffDestinationGraphicCoordinate,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: dropOffDestinationLocation.placeName,
          snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOfDestinationPointMarker);
    });

    Circle pickUpPointCircle = Circle(
      circleId: const CircleId("pickupCircleID"),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoordinate,
      fillColor: Colors.blue,
    );

    Circle dropOffDestinationCircle = Circle(
      circleId: const CircleId("destinationCircleID"),
      strokeColor: Colors.green,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGraphicCoordinate,
      fillColor: Colors.green,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationCircle);
    });
  }

  resetAppNow() {
    setState(() {
      polylineCoordinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      seachContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpen == true;

      status = "";
      nameDriver = "";
      photoNumber = "";
      photoNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = "Diver is Arriving";
    });
  }

  updateAvailableNearbyOnlineDriversOnMap() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyDrivers eachOnlineNearbyDrivers
        in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPostion = LatLng(eachOnlineNearbyDrivers.latDriver!,
          eachOnlineNearbyDrivers.lngDriver!);
      Marker driverMarker = Marker(
        markerId: MarkerId(
          "driver Id" + eachOnlineNearbyDrivers.uidDriver.toString(),
        ),
        position: driverCurrentPostion,
        icon: carIconNearbyDriver!,
      );
      markersTempSet.add(driverMarker);
    }
    setState(() {
      markerSet = markersTempSet;
    });
  }

  initlaizeGeoFireListner() {
    Geofire.initialize("onlineDrivers");
    Geofire.queryAtLocation(
            currentPositionUser!.latitude, currentPositionUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];
        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethods.nearbyOnlineDriversList
                .add(onlineNearbyDrivers);
            if (nearbyOnlineDriversKeysLoaded == true) {
              //update driver on google map
              updateAvailableNearbyOnlineDriversOnMap();
            }
            break;
          case Geofire.onKeyExited:
            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
            updateAvailableNearbyOnlineDriversOnMap();
            break;
          case Geofire.onKeyMoved:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethods.updateOnlineNearbyDriversLocation(
                onlineNearbyDrivers);
            updateAvailableNearbyOnlineDriversOnMap();
            break;
          case Geofire.onGeoQueryReady:
            //display nearset online drivers
            nearbyOnlineDriversKeysLoaded = true;
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  noDriverAvailable() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => InfoDialog(
          title: "No Driver Available",
          description:
              "No driver found in the nearby. Please try again shortly."),
    );
  }

  searchDriver() {
    if (availableNearbyOnlineDriversList.length == 0) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }
    var currentDriver = availableNearbyOnlineDriversList[0];

    //send push notification

    availableNearbyOnlineDriversList!.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();
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
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
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
                  if (isDrawerOpen == true) {
                    sKey.currentState!.openDrawer();
                  } else {
                    resetAppNow();
                  }
                  setState(() {
                    isDrawerOpen = !isDrawerOpen; // Toggle the drawer state
                  });
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
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 20,
                    child: Icon(
                      isDrawerOpen == true ? Icons.menu : Icons.close,
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
                  padding: const EdgeInsets.symmetric(vertical: 0),
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
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          (tripDirectionDetailsInfo != null)
                                              ? tripDirectionDetailsInfo!
                                                  .distanceTextString!
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
                                      onTap: () {
                                        setState(() {
                                          stateOfApp = "requesting";
                                        });
                                        displayRequestContainer();

                                        //get nearest availbe driver
                                        availableNearbyOnlineDriversList =
                                            ManageDriversMethods
                                                .nearbyOnlineDriversList;
                                        //search driver
                                        searchDriver();
                                      },
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: requestContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 200,
                        child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.greenAccent,
                          rightDotColor: Colors.pinkAccent,
                          size: 50,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          resetAppNow();
                          cancelRideRequest();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1.0, color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  cancelRideRequest() {
    tripRequestRef!.remove();
    setState(() {
      stateOfApp = "normal";
    });
  }
}
