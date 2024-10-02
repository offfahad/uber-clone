import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../global/global.dart';
import '../main.dart';
import '../models/trip_details.dart';
import '../widgets/notification_dialog.dart';

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;
  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();

    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");
    referenceOnlineDriver.set(deviceRecognitionToken);
    firebaseCloudMessaging.subscribeToTopic("drivers");
    firebaseCloudMessaging.subscribeToTopic("users");
    return null;
  }

  startListeningForNewNotification(BuildContext context) async {
    var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'uberApp',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'UberApp',
    );

    log('\nNotification Channel Result: $result');

    //Terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });
    //Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });

    //Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context) {
    // Use the global navigatorKey to get the current context
    final currentContext = navigatorKey.currentContext;

    if (currentContext != null) {
      // Reference to the trip request
      DatabaseReference tripRequestsRef =
          FirebaseDatabase.instance.ref().child("tripRequest").child(tripID);

      tripRequestsRef.once().then((dataSnapshot) {
        // Log the snapshot to see the structure and content
        log("DataSnapshot: ${dataSnapshot.snapshot.value}");

        if (dataSnapshot.snapshot.value == null) {
          log("Error: No data found for tripID $tripID");
          return;
        }

        try {
          // Parse the data
          final data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

          // Log the received data for debugging
          log("Trip Data: $data");

          audioPlayer.open(
            Audio("assets/audio/alert-sound.mp3"),
          );

          audioPlayer.play();

          TripDetails tripDetailsInfo = TripDetails();

          // Extracting pickup location
          final pickUpLatLng = data["pickUpLatLng"] as Map<dynamic, dynamic>;
          double pickUpLat = double.parse(pickUpLatLng["latitude"].toString());
          double pickUpLng = double.parse(pickUpLatLng["longitude"].toString());
          tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

          // Pickup address
          tripDetailsInfo.pickupAddress = data["pickUpAddress"].toString();

          // Extracting dropoff location
          final dropOffLatLng = data["dropOffLatLng"] as Map<dynamic, dynamic>;
          double dropOffLat =
              double.parse(dropOffLatLng["latitude"].toString());
          double dropOffLng =
              double.parse(dropOffLatLng["longitude"].toString());
          tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

          // Dropoff address
          tripDetailsInfo.dropOffAddress = data["dropOffAddress"].toString();

          // User details
          tripDetailsInfo.userName = data["userName"].toString();
          tripDetailsInfo.userPhone = data["userPhone"].toString();
          bidAmount = data["bidAmount"].toString();
          fareAmount = data["fareAmount"].toString();

          // Trip ID
          tripDetailsInfo.tripID = tripID;

          // Show the notification dialog with trip details
          showDialog(
            context: currentContext,
            builder: (BuildContext context) => NotificationDialog(
              tripDetailsInfo: tripDetailsInfo,
              bidAmount: bidAmount,
              fareAmount: fareAmount,
            ),
          );
        } catch (e, stackTrace) {
          // Catch any errors during parsing or UI update
          log("Error parsing trip request info: $e\n$stackTrace");
        }
      }).catchError((error) {
        // Handle errors from the Firebase call itself
        Navigator.pop(currentContext);
        log("Firebase error: $error");
      });
    }
  }
}
