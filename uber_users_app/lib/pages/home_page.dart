import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/register_screen.dart';
import 'package:uber_users_app/pages/profile_page.dart';
import 'package:uber_users_app/pages/search_destination_place.dart';
import 'package:uber_users_app/widgets/custome_drawer.dart';
import 'package:uber_users_app/widgets/sign_out_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global/global_var.dart';
import '../global/trip_var.dart';
import '../methods/common_methods.dart';
import '../methods/manage_drivers_methods.dart';
import '../methods/push_notification_service.dart';
import '../models/direction_details.dart';
import '../models/online_nearby_drivers.dart';
import '../widgets/bid_dialog.dart';
import '../widgets/info_dialog.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/payment_dialog.dart';
import 'about_page.dart';
import 'trips_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 230;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  bool requestingDirectionDetailsInfo = false;
  String selectedPaymentMethod = "Cash"; // Default selection
  TextEditingController bidController = TextEditingController();
  double actualFareAmountCar = 0.0; // To store the actual fare amount
  double? bidAmount; // To store the entered bid amount
  String selectedVehicle = "Car";
  String estimatedTimeCar = "";
  double actualFareAmount = 0.0;
  String estimatedTime = "";

  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
              configuration, "assets/images/tracking.png")
          .then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes("themes/night_style.json")
        .then((value) => setGoogleMapStyle(value, controller));
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
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          if (mounted) {
            setState(() {
              userName = (snap.snapshot.value as Map)["name"];
              userPhone = (snap.snapshot.value as Map)["phone"];
              userEmail = (snap.snapshot.value as Map)["email"];
            });
          }
        } else {
          FirebaseAuth.instance.signOut();

          Navigator.push(context,
              MaterialPageRoute(builder: (c) => const RegisterScreen()));

          cMethods.displaySnackBar(
              "You are blocked. Contact admin: gulzarsoft@gmail.com", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const RegisterScreen()));
      }
    });
  }

  displayUserRideDetailsContainer() async {
    ///Directions API
    await retrieveDirectionDetails();
    if (mounted) {
      setState(() {
        searchContainerHeight = 0;
        bottomMapPadding = 240;
        rideDetailsContainerHeight = 500;
        isDrawerOpened = false;
      });
    }
  }

  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfoClass>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfoClass>(context, listen: false).dropOffLocation;

    var pickupGeoGraphicCoOrdinates = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
        dropOffDestinationLocation!.latitudePosition!,
        dropOffDestinationLocation.longitudePosition!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting direction..."),
    );

    ///Directions API
    var detailsFromDirectionAPI =
        await CommonMethods.getDirectionDetailsFromAPI(
            pickupGeoGraphicCoOrdinates,
            dropOffDestinationGeoGraphicCoOrdinates);
    if (mounted) {
      setState(() {
        tripDirectionDetailsInfo = detailsFromDirectionAPI;
      });
    }

    Navigator.pop(context);

    //draw route from pickup to dropOffDestination
    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination =
        pointsPolyline.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);

    polylineCoOrdinates.clear();
    if (latLngPointsFromPickUpToDestination.isNotEmpty) {
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) {
        polylineCoOrdinates
            .add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polylineSet.clear();
    if (mounted) {
      setState(() {
        Polyline polyline = Polyline(
          polylineId: const PolylineId("polylineID"),
          color: Colors.pink,
          points: polylineCoOrdinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );

        polylineSet.add(polyline);
      });
    }

    //fit the polyline into the map
    LatLngBounds boundsLatLng;
    if (pickupGeoGraphicCoOrdinates.latitude >
            dropOffDestinationGeoGraphicCoOrdinates.latitude &&
        pickupGeoGraphicCoOrdinates.longitude >
            dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationGeoGraphicCoOrdinates,
        northeast: pickupGeoGraphicCoOrdinates,
      );
    } else if (pickupGeoGraphicCoOrdinates.longitude >
        dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
      );
    } else if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: pickupGeoGraphicCoOrdinates,
        northeast: dropOffDestinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    //add markers to pickup and dropOffDestination points
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: dropOffDestinationLocation.placeName,
          snippet: "Destination Location"),
    );
    if (mounted) {
      setState(() {
        markerSet.add(pickUpPointMarker);
        markerSet.add(dropOffDestinationPointMarker);
      });
    }

    //add circles to pickup and dropOffDestination points
    Circle pickUpPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );
    if (mounted) {
      setState(() {
        circleSet.add(pickUpPointCircle);
        circleSet.add(dropOffDestinationPointCircle);
      });
    }
  }

  resetAppNow() {
    setState(() {
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 230;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = 'Driver is Arriving';
    });
  }

  cancelRideRequest() {
    //remove ride request from database
    tripRequestRef!.remove();
    if (mounted) {
      setState(() {
        stateOfApp = "normal";
      });
    }
  }

  displayRequestContainer() {
    if (mounted) {
      setState(() {
        rideDetailsContainerHeight = 0;
        requestContainerHeight = 220;
        bottomMapPadding = 200;
        isDrawerOpened = true;
      });
    }

    //send ride request
    makeTripRequest();
  }

  updateAvailableNearbyOnlineDriversOnMap() {
    if (mounted) {
      setState(() {
        markerSet.clear();
      });
    }

    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyDrivers eachOnlineNearbyDriver
        in ManageDriversMethods.nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
        markerId: MarkerId(
            "driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      if (mounted) {
        markerSet = markersTempSet;
      }
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("onlineDrivers");

    // Guard against no drivers collection
    Geofire.queryAtLocation(currentPositionOfUser?.latitude ?? 0.0,
            currentPositionOfUser?.longitude ?? 0.0, 42)
        ?.listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            if (driverEvent["key"] != null &&
                driverEvent["latitude"] != null &&
                driverEvent["longitude"] != null) {
              OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
              onlineNearbyDrivers.uidDriver = driverEvent["key"];
              onlineNearbyDrivers.latDriver = driverEvent["latitude"];
              onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
              ManageDriversMethods.nearbyOnlineDriversList
                  .add(onlineNearbyDrivers);

              if (nearbyOnlineDriversKeysLoaded == true) {
                updateAvailableNearbyOnlineDriversOnMap();
              }
            }
            break;

          case Geofire.onKeyExited:
            if (driverEvent["key"] != null) {
              ManageDriversMethods.removeDriverFromList(driverEvent["key"]);
              updateAvailableNearbyOnlineDriversOnMap();
            }
            break;

          case Geofire.onKeyMoved:
            if (driverEvent["key"] != null &&
                driverEvent["latitude"] != null &&
                driverEvent["longitude"] != null) {
              OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
              onlineNearbyDrivers.uidDriver = driverEvent["key"];
              onlineNearbyDrivers.latDriver = driverEvent["latitude"];
              onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
              ManageDriversMethods.updateOnlineNearbyDriversLocation(
                  onlineNearbyDrivers);
              updateAvailableNearbyOnlineDriversOnMap();
            }
            break;

          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;
            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  makeTripRequest() {
    tripRequestRef =
        FirebaseDatabase.instance.ref().child("tripRequest").push();

    var pickUpLocation =
        Provider.of<AppInfoClass>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfoClass>(context, listen: false).dropOffLocation;

    // Guard against null locations
    if (pickUpLocation == null || dropOffDestinationLocation == null) {
      print('Error: Pickup or Drop-off location is null.');
      return;
    }

    Map<String, String> pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map<String, String> dropOffDestinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map<String, String> driverCoOrdinates = {
      "latitude": "",
      "longitude": "",
    };

    Map<String, dynamic> dataMap = {
      "tripID": tripRequestRef?.key ?? "",
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,
      "driverId": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": selectedVehicle == "Car"
          ? actualFareAmountCar.toString()
          : actualFareAmount.toString(),
      "status": "new",
      "bidAmount": bidAmount.toString(),
      "vehicleType": selectedVehicle.toString(),
    };
    print("Bidded Amount ${bidAmount}");

    tripRequestRef?.set(dataMap);

    tripStreamSubscription =
        tripRequestRef?.onValue.listen((eventSnapshot) async {
      var data = eventSnapshot.snapshot.value as Map?;
      if (data == null) return;

      nameDriver = data["driverName"] ?? nameDriver;
      phoneNumberDriver = data["driverPhone"] ?? phoneNumberDriver;
      photoDriver = data["driverPhoto"] ?? photoDriver;
      carDetailsDriver = data["carDetails"] ?? carDetailsDriver;
      status = data["status"] ?? status;
      if (data["driverLocation"] != null) {
        var latitudeString = data["driverLocation"]["latitude"].toString();
        var longitudeString = data["driverLocation"]["longitude"].toString();

        // Ensure the latitude and longitude are not empty and valid numbers
        if (latitudeString.isNotEmpty && longitudeString.isNotEmpty) {
          try {
            double driverLatitude = double.parse(latitudeString);
            double driverLongitude = double.parse(longitudeString);

            // Update driver's current location
            LatLng driverCurrentLocationLatLng =
                LatLng(driverLatitude, driverLongitude);

            // Update status based on trip phase
            if (status == "accepted") {
              updateFromDriverCurrentLocationToPickUp(
                  driverCurrentLocationLatLng);
            } else if (status == "arrived") {
              setState(() {
                tripStatusDisplay = 'Driver has Arrived';
              });
            } else if (status == "ontrip") {
              updateFromDriverCurrentLocationToDropOffDestination(
                  driverCurrentLocationLatLng);
            }
          } catch (e) {
            // Log an error if parsing fails
            print('Error parsing driver location: $e');
          }
        } else {
          print('Driver latitude or longitude is empty.');
        }
      }

      if (status == "accepted") {
        displayTripDetailsContainer();
        Geofire.stopListener();

        setState(() {
          markerSet.removeWhere(
              (element) => element.markerId.value.contains("driver"));
        });
      }

      if (status == "ended") {
        // Parse the actual fare amount from the trip data
        double fareAmount = double.parse(data["fareAmount"].toString());

        // Determine the amount to pass to the PaymentDialog based on bidAmount
        double? finalFareAmount = bidAmount ?? fareAmount;

        var responseFromPaymentDialog = await showDialog(
          context: context,
          builder: (BuildContext context) =>
              PaymentDialog(fareAmount: finalFareAmount.toString()),
        );

        if (responseFromPaymentDialog == "paid") {
          tripRequestRef?.onDisconnect();
          tripRequestRef = null;

          tripStreamSubscription?.cancel();
          tripStreamSubscription = null;

          resetAppNow();
          Restart.restartApp();
        }
      }
    });
  }

  displayTripDetailsContainer() {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 295;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      // Check if currentPositionOfUser is null
      if (currentPositionOfUser == null) {
        requestingDirectionDetailsInfo = false;
        return; // Early return to avoid further execution
      }

      var userPickUpLocationLatLng = LatLng(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude,
      );

      var directionDetailsPickup =
          await CommonMethods.getDirectionDetailsFromAPI(
              driverCurrentLocationLatLng, userPickUpLocationLatLng);

      if (directionDetailsPickup == null) {
        requestingDirectionDetailsInfo =
            false; // Reset the flag in case of null
        return;
      }

      setState(() {
        tripStatusDisplay =
            "Driver is Coming ${directionDetailsPickup.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  updateFromDriverCurrentLocationToDropOffDestination(
      driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      // Check if dropOffLocation is null
      var dropOffLocation =
          Provider.of<AppInfoClass>(context, listen: false).dropOffLocation;

      if (dropOffLocation == null) {
        requestingDirectionDetailsInfo = false;
        return; // Early return to avoid further execution
      }

      var userDropOffLocationLatLng = LatLng(
        dropOffLocation.latitudePosition!,
        dropOffLocation.longitudePosition!,
      );

      var directionDetailsPickup =
          await CommonMethods.getDirectionDetailsFromAPI(
              driverCurrentLocationLatLng, userDropOffLocationLatLng);

      if (directionDetailsPickup == null) {
        requestingDirectionDetailsInfo =
            false; // Reset the flag in case of null
        return;
      }

      setState(() {
        tripStatusDisplay =
            "Drop Off Location ${directionDetailsPickup.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  noDriverAvailable() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => InfoDialog(
        title: "No Driver Available",
        description:
            "No driver found in the nearby location. Please try again shortly.",
      ),
    );
  }

  searchDriver() {
    if (availableNearbyOnlineDriversList!.length == 0) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    var currentDriver = availableNearbyOnlineDriversList![0];

    //send notification to this currentDriver - currentDriver means selected driver
    sendNotificationToDriver(currentDriver);

    availableNearbyOnlineDriversList!.removeAt(0);
  }

  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    // Ensure tripRequestRef and driver UID are not null
    if (tripRequestRef == null || currentDriver.uidDriver == null) {
      print("Error: tripRequestRef or driver UID is null.");
      return;
    }

    // Update driver's newTripStatus - assign tripID to current driver
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");

    try {
      currentDriverRef.set(tripRequestRef!.key);
    } catch (e) {
      print("Error updating driver's newTripStatus: $e");
      return;
    }

    // Get current driver's device recognition token
    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        // Send notification
        try {
          PushNotificationService.sendNotificationToSelectedDriver(
              deviceToken, context, tripRequestRef!.key.toString());
        } catch (e) {
          print("Error sending notification: $e");
          return;
        }
      } else {
        print("No deviceToken found for the driver.");
        return;
      }

      const oneTickPerSec = Duration(seconds: 1);
      Timer? timer;

      try {
        timer = Timer.periodic(oneTickPerSec, (timer) {
          requestTimeoutDriver = requestTimeoutDriver - 1;

          // When trip request is canceled or state changes
          if (stateOfApp != "requesting") {
            timer.cancel();
            currentDriverRef.set("cancelled");
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 40;
          }

          // Listen for driver acceptance
          currentDriverRef.onValue.listen((dataSnapshot) {
            if (dataSnapshot.snapshot.value != null &&
                dataSnapshot.snapshot.value.toString() == "accepted") {
              timer.cancel();
              currentDriverRef.onDisconnect();
              requestTimeoutDriver = 40;
            }
          });

          // If timeout occurs after 40 seconds, notify the next available driver
          if (requestTimeoutDriver == 0) {
            timer.cancel();
            currentDriverRef.set("timeout");
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 40;

            // Search for the next available driver
            searchDriver();
          }
        });
      } catch (e) {
        print("Error during timer execution: $e");
        timer?.cancel();
      }
    }).catchError((error) {
      print("Error fetching driver's device token: $error");
    });
  }

  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    String? userAddress = Provider.of<AppInfoClass>(context, listen: false)
                .pickUpLocation !=
            null
        ? (Provider.of<AppInfoClass>(context, listen: false)
                    .pickUpLocation!
                    .placeName!
                    .length >
                35
            ? "${Provider.of<AppInfoClass>(context, listen: false).pickUpLocation!.placeName!.substring(0, 35)}..."
            : Provider.of<AppInfoClass>(context, listen: false)
                .pickUpLocation!
                .placeName)
        : 'Fetching Your Current Location.';

    if (tripDirectionDetailsInfo != null) {
      var fareString = cMethods.calculateFareAmountInPKR(
        tripDirectionDetailsInfo!,
      ); // Save the fare amount
      actualFareAmountCar = double.tryParse(fareString) ?? 0.0;
      estimatedTimeCar =
          tripDirectionDetailsInfo!.durationTextString.toString();
    }

    void calculateFareAndTime() {
      // Parse the time for the car into total minutes
      int totalMinutes = 0;
      if (estimatedTimeCar.contains("hours")) {
        List<String> timeParts = estimatedTimeCar.split(" ");
        int hours = int.tryParse(timeParts[0]) ?? 0; // Parse the hours
        int minutes = int.tryParse(timeParts[2]) ?? 0; // Parse the minutes
        totalMinutes = (hours * 60) + minutes;
      } else {
        // If it's just minutes, like "24 mins"
        totalMinutes = int.tryParse(estimatedTimeCar.split(" ")[0]) ?? 0;
      }

      // Adjust fare and time based on selected vehicle
      if (selectedVehicle == "Car") {
        setState(() {
          actualFareAmount = actualFareAmountCar;
          estimatedTime =
              estimatedTimeCar; // Show the car's estimated time directly
        });
      } else if (selectedVehicle == "Auto") {
        setState(() {
          actualFareAmount =
              actualFareAmountCar * 0.8; // Auto fare is 80% of the car fare
          int updatedMinutes =
              (totalMinutes * 1.2).toInt(); // Increase time by 20%
          estimatedTime = commonMethods
              .formatTime(updatedMinutes); // Convert back to hours and minutes
        });
      } else if (selectedVehicle == "Bike") {
        setState(() {
          actualFareAmount =
              actualFareAmountCar * 0.4; // Bike fare is 40% of car fare
          int updatedMinutes =
              (totalMinutes * 0.8).toInt(); // Decrease time by 20%
          estimatedTime = commonMethods
              .formatTime(updatedMinutes); // Convert back to hours and minutes
        });
      }
    }

    if (tripDirectionDetailsInfo != null) {
      calculateFareAndTime();
    }

    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final appProvider = Provider.of<AppInfoClass>(context, listen: false);
    makeDriverNearbyCarIcon();

    return SafeArea(
      child: Scaffold(
        key: sKey,
        drawer: CustomDrawer(userName: userName, authProvider: authProvider),
        body: Stack(
          children: [
            ///google map
            GoogleMap(
              padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) async {
                controllerGoogleMap = mapController;
                //updateMapTheme(controllerGoogleMap!);

                googleMapCompleterController.complete(controllerGoogleMap);

                setState(() {
                  bottomMapPadding = 300;
                });

                await getCurrentLiveLocationOfUser();
              },
            ),

            ///drawer button
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  if (isDrawerOpened == true) {
                    sKey.currentState!.openDrawer();
                  } else {
                    resetAppNow();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                    backgroundColor: Colors.white60,
                    radius: 30,
                    child: Icon(
                      isDrawerOpened == true ? Icons.menu : Icons.close,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(microseconds: 122),
                child: Container(
                  height: searchContainerHeight,
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
                        offset: Offset(.7, .7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "From",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  userAddress!,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 13,
                            ),
                            GestureDetector(
                              onTap: () async {
                                var responseFromSearchPage =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const SearchDestinationPlace()));

                                if (responseFromSearchPage == "placeSelected") {
                                  displayUserRideDetailsContainer();
                                }
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "To",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  Text(
                                    "Where would you like to go?",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Select Desination",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              var responseFromSearchPage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const SearchDestinationPlace()));

                              if (responseFromSearchPage == "placeSelected") {
                                displayUserRideDetailsContainer();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///ride details container
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
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(.7, .7),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicle = "Car";
                              });
                              calculateFareAndTime();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: selectedVehicle == "Car"
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                              width: 100,
                              height: 70,
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Image.asset(
                                  "assets/vehicles/home_car.png",
                                  width: 100,
                                  height: 70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicle = "Auto";
                              });
                              calculateFareAndTime();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: selectedVehicle == "Auto"
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                              ),
                              width: 100,
                              height: 70,
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: Image.asset(
                                  "assets/vehicles/auto.png",
                                  height: 50,
                                  width: 60,
                                ), // Ensures the image stays at its original size
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedVehicle = "Bike";
                              });
                              calculateFareAndTime();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: selectedVehicle == "Bike"
                                        ? Colors.white
                                        : Colors.transparent),
                              ),
                              width: 100,
                              height: 70,
                              child: FittedBox(
                                child: Image.asset(
                                  "assets/vehicles/bike.png",
                                  width: 60,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          FittedBox(
                            child: Image.asset(
                              "assets/images/initial.png",
                              width: 20,
                              height: 40,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              // First check if pickUpLocation is null, then access placeName
                              (appProvider.pickUpLocation != null &&
                                      appProvider.pickUpLocation!.placeName !=
                                          null)
                                  ? appProvider.pickUpLocation!.placeName
                                      .toString()
                                  : "Location not available", // Fallback text if null
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          FittedBox(
                            child: Image.asset(
                              "assets/images/final.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              // First check if dropOffLocation and placeName are not null
                              (appProvider.dropOffLocation != null &&
                                      appProvider.dropOffLocation!.placeName !=
                                          null)
                                  ? appProvider.dropOffLocation!.placeName
                                      .toString()
                                  : "Location not available", // Fallback text if null
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(
                        thickness: 2.0,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.travel_explore_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Distace",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  (tripDirectionDetailsInfo != null)
                                      ? tripDirectionDetailsInfo!
                                          .distanceTextString!
                                      : "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.time_to_leave,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Estimated Time",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  selectedVehicle == "Car"
                                      ? estimatedTimeCar
                                      : estimatedTime, // Fallback if estimatedTime is null
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(
                        thickness: 2.0,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.money_sharp,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Fare Fee",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          selectedVehicle == "Car"
                                              ? "Rs ${actualFareAmountCar.toStringAsFixed(2).toString()}" // Use null-aware operator
                                              : "Rs ${actualFareAmount.toStringAsFixed(2).toString()}", // Use null-aware operator here as well
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Payment Method",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        DropdownButton<String>(
                                          value: selectedPaymentMethod,
                                          dropdownColor: Colors.grey,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedPaymentMethod = newValue!;
                                            });
                                          },
                                          items: <String>[
                                            'Cash',
                                            'Credit Card',
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(
                        thickness: 2.0,
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 50,
                              child: BidDialogWidget(
                                initialFareAmount: actualFareAmount,
                                onBidAmountChanged: (bidAmountNew) {
                                  setState(() {
                                    bidAmount = bidAmountNew;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  "Find Driver",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  setState(() {
                                    stateOfApp = "requesting";
                                    displayRequestContainer();

                                    //get nearest available online drivers
                                    availableNearbyOnlineDriversList =
                                        ManageDriversMethods
                                            .nearbyOnlineDriversList;

                                    //search driver
                                    searchDriver();
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            ///request container
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
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                        "Searhing For Nearset Drivers..",
                        style: TextStyle(color: Colors.white),
                      ),
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
                            border: Border.all(width: 1.5, color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///trip details container
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: tripContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white12,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      //trip status display text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tripStatusDisplay,
                            style: const TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 19,
                      ),

                      const Divider(
                        height: 1,
                        color: Colors.white,
                        thickness: 1,
                      ),

                      const SizedBox(
                        height: 19,
                      ),

                      //image - driver name and driver car details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.network(
                              photoDriver == ''
                                  ? "https://firebasestorage.googleapis.com/v0/b/everyone-2de50.appspot.com/o/avatarman.png?alt=media&token=702d209c-9f99-46b2-832f-5bb986bc5eac"
                                  : photoDriver,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameDriver,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                carDetailsDriver,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Divider(
                        height: 1,
                        color: Colors.white,
                        thickness: 1,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      //call driver btn
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse("tel://$phoneNumberDriver"));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25)),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 11,
                                ),
                                const Text(
                                  "Call",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
