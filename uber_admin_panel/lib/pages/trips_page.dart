import 'package:flutter/material.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';

class TripsPage extends StatefulWidget {
  static const String id = "\webTripsUsers";
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  CommonMethods commonMethods = CommonMethods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Manage Trips",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  commonMethods.header(2, "TRIP ID"),
                  commonMethods.header(1, "USER NAME"),
                  commonMethods.header(1, "DRIVER NAME"),
                  commonMethods.header(1, "CAR DETAILS"),
                  commonMethods.header(1, "FARE AMOUNT"),
                  commonMethods.header(1, "VIEW DETAILS"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
