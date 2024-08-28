import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_drivers_app/widgets/loading_dialog.dart';

import '../global/global.dart';
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const LoadingDialog(messageText: "getting details..."),
    );

    DatabaseReference tripRequestsRef =
        FirebaseDatabase.instance.ref().child("tripRequest").child(tripID);

    tripRequestsRef.once().then((dataSnapshot) {
      Navigator.pop(context);

      audioPlayer.open(
        Audio("assets/audio/alert-sound.mp3"),
      );

      audioPlayer.play();

      TripDetails tripDetailsInfo = TripDetails();
      double pickUpLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      tripDetailsInfo.pickupAddress =
          (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress =
          (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName =
          (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone =
          (dataSnapshot.snapshot.value! as Map)["userPhone"];

      tripDetailsInfo.tripID = tripID;

      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(
          tripDetailsInfo: tripDetailsInfo,
        ),
      );
    });
  }
}
