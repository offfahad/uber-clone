import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';

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
          itemCount: listItems.length,
          shrinkWrap: true,
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commonMethods.data(
                  1,
                  Image.network(
                    listItems[index]["photo"].toString(),
                    //width: 50,
                    //height: 50,
                  ),
                ),
                commonMethods.data(
                  2,
                  Text(
                    listItems[index]["id"].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["name"].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    "${listItems[index]["car_details"]["carModel"]} ${listItems[index]["car_details"]["carNumber"]}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["phone"].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  listItems[index]["earnings"] != null
                      ? Text(
                          style: const TextStyle(color: Colors.white),
                          "Rs ${listItems[index]["earnings"].toStringAsFixed(2)}")
                      : const Text(
                          "Rs 0.00",
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                commonMethods.data(
                  1,
                  listItems[index]["blockStatus"] == "no"
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            print(
                                "Block button pressed for ${listItems[index]["id"]}");
                          },
                          child: const Text(
                            "Block",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            print(
                                "Unblock button pressed for ${listItems[index]["id"]}");
                          },
                          child: const Text(
                            "Unblock",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
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
