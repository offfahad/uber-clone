import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TripProvider with ChangeNotifier {
  String currentDriverTotalTripsCompleted = "";
  bool isLoading = true;
  List<Map<String, dynamic>> completedTrips = [];

  // Method to fetch the total trips completed by the current driver
  Future<void> getCurrentDriverTotalNumberOfTripsCompleted() async {
    try {
      isLoading = true;
      notifyListeners();
      DatabaseReference tripRequestsRef =
          FirebaseDatabase.instance.ref().child("tripRequest");

      final snapshot = await tripRequestsRef.once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> allTripsMap = snapshot.snapshot.value as Map;
        List<String> tripsCompletedByCurrentDriver = [];

        allTripsMap.forEach((key, value) {
          if (value["status"] == "ended" &&
              value["driverId"] == FirebaseAuth.instance.currentUser!.uid) {
            tripsCompletedByCurrentDriver.add(key);
          }
        });

        currentDriverTotalTripsCompleted =
            tripsCompletedByCurrentDriver.length.toString();
      } else {
        currentDriverTotalTripsCompleted = "0";
      }
    } catch (error) {
      print("Error fetching trips: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to fetch completed trips
  Future<void> getCompletedTrips() async {
    try {
      isLoading = true;
      notifyListeners();

      DatabaseReference tripRequestsRef =
          FirebaseDatabase.instance.ref().child("tripRequest");

      final snapshot = await tripRequestsRef.once();
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> allTripsMap = snapshot.snapshot.value as Map;

        completedTrips = [];
        allTripsMap.forEach((key, value) {
          if (value["status"] == "ended" &&
              value["driverId"] == FirebaseAuth.instance.currentUser!.uid) {
            completedTrips.add({"key": key, ...value});
          }
        });
      }
    } catch (error) {
      print("Error fetching completed trips: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
