import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods {
  Future<void> checkConnectivity(BuildContext context) async {
    var connectionResults = await Connectivity().checkConnectivity();
    print("Connectivity result: $connectionResults"); // Add this line

    if (connectionResults != ConnectivityResult.wifi &&
        connectionResults != ConnectivityResult.mobile) {
      if (!context.mounted) return;
      displaySnackBar(
          "Your internet is not working. Check your connection. Try again.",
          context);
    } else {
      print("Internet is working"); // Add this line
    }
  }

  void displaySnackBar(String message, BuildContext context) {
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
