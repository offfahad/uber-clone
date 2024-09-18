import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String driverEarnings = "";

  getTotalEarningsOfCurrentDriver() async {
    DatabaseReference driversRef =
        FirebaseDatabase.instance.ref().child("drivers");

    await driversRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      var data = snap.snapshot.value as Map?;
      if (data != null && data["earnings"] != null) {
        setState(() {
          // Convert the earnings to double safely
          double earnings = double.tryParse(data["earnings"].toString()) ?? 0.0;
          driverEarnings =
              earnings.toStringAsFixed(2); // Display 2 digits after decimal
        }); 
      } else {
        setState(() {
          driverEarnings = "0";
        });
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    getTotalEarningsOfCurrentDriver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: Colors.indigo,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/totalearnings.png",
                      width: 120,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Total Earnings:",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Rs $driverEarnings",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
