import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProvider with ChangeNotifier {
  final DatabaseReference _driversRef = FirebaseDatabase.instance.ref().child("users");

  // Method to update block status (block/unblock)
  Future<void> toggleBlockStatus(String userId, String currentStatus) async {
    // Toggle between "yes" and "no"
    String newStatus = currentStatus == "no" ? "yes" : "no";
    
    // Update in Firebase Realtime Database
    await _driversRef.child(userId).update({"blockStatus": newStatus});
    
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
