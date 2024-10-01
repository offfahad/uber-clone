import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';
import 'package:uber_admin_panel/widgets/drivers_data_list.dart';

class DriverPage extends StatefulWidget {
  static const String id = "\webPageDrivers";
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
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
                  "Manage Drivers",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  //commonMethods.header(1, "PICTURE"),
                  // commonMethods.header(2, "DRIVER ID"),
                  commonMethods.header(1, "NAME"),
                  commonMethods.header(1, "CAR DETAILS"),
                  commonMethods.header(1, "PHONE"),
                  commonMethods.header(1, "TOTAL EARNING"),
                  commonMethods.header(1, "ACTIONS"),
                  commonMethods.header(1, "VIEW MORE"),
                ],
              ),
              const SizedBox(

                
                height: 12,
              ),
              const DriversDataList(),
            ],
          ),
        ),
      ),
    );
  }
}
