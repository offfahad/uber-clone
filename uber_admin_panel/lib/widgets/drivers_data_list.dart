import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';
import 'package:uber_admin_panel/pages/driver_data_screen.dart';

import '../provider/driver_provider.dart';

class DriversDataList extends StatefulWidget {
  const DriversDataList({super.key});

  @override
  State<DriversDataList> createState() => _DriversDataListState();
}

class _DriversDataListState extends State<DriversDataList> {
  final driversRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("drivers");
  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: driversRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          print("Error: ${snapshotData.error}");
          return const Center(
            child: Text(
              "Error occurred. Try later",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }
        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshotData.connectionState == ConnectionState.none) {
          return const Center(
            child: Text(
              "No connection. Please check your internet.",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }
        
        if (!snapshotData.hasData ||
            snapshotData.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "No data available",
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List listItems = [];
        dataMap.forEach((key, value) {
          listItems.add({"key": key, ...value});
        });

        print("Data received: $listItems"); // Log data for debugging

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 5),
          itemCount: listItems.length,
          shrinkWrap: true,
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commonMethods.data(
                  1,
                  Text(
                    "${listItems[index]["firstName"]} ${listItems[index]["secondName"]}",
                    //style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    "${listItems[index]["vehicleInfo"]["brand"]} ${listItems[index]["vehicleInfo"]["color"]} ${listItems[index]["vehicleInfo"]["productionYear"]}",
                    // You can apply any TextStyle here if needed
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["phoneNumber"].toString(),
                    //style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  listItems[index]["earnings"] != ""
                      ? Text(
                          //style: const TextStyle(color: Colors.white),
                          "Rs ${listItems[index]["earnings"].toStringAsFixed(2)}")
                      : const Text(
                          "Rs 0.00",
                          //style: const TextStyle(color: Colors.white),
                        ),
                ),
                commonMethods.data(
                  1,
                  listItems[index]["blockStatus"] == "no"
                      ? SizedBox(
                          height: 20,
                          width: 10,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(221, 39, 57, 99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            onPressed: () {
                              // Call Provider's method to toggle block status
                              Provider.of<DriverProvider>(context,
                                      listen: false)
                                  .toggleBlockStatus(listItems[index]["key"],
                                      listItems[index]["blockStatus"]);
                            },
                            child: const Text(
                              "Block",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 20,
                          width: 10,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(221, 39, 57, 99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            onPressed: () {
                              // Call Provider's method to toggle block status
                              Provider.of<DriverProvider>(context,
                                      listen: false)
                                  .toggleBlockStatus(listItems[index]["key"],
                                      listItems[index]["blockStatus"]);
                            },
                            child: const Text(
                              "Unblock",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                ),
                commonMethods.data(
                  1,
                  SizedBox(
                    height: 20,
                    width: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(221, 39, 57, 99),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: () {
                        String driverId = listItems[index]["key"] ??
                            'UnknownID'; // Safe access with default
                        print(
                            "Navigating to DriverDataScreen with driverId: $driverId"); // Debug print
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>
                                DriverDataScreen(driverId: driverId),
                          ),
                        );
                      },
                      child: const Text(
                        "View More",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

