import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber_admin_panel/methods/common_methods.dart';

class UsersDataList extends StatefulWidget {
  const UsersDataList({super.key});

  @override
  State<UsersDataList> createState() => _UsersDataListState();
}

class _UsersDataListState extends State<UsersDataList> {
  final driversRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("users");
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
          padding: EdgeInsets.only(bottom: 5),
          itemCount: listItems.length,
          shrinkWrap: true,
          itemBuilder: ((context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                commonMethods.data(
                  2,
                  Text(
                    listItems[index]["id"].toString(),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["name"].toString(),
                    //style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["email"].toString(),
                    //style: const TextStyle(color: Colors.white),
                  ),
                ),
                commonMethods.data(
                  1,
                  Text(
                    listItems[index]["phone"].toString(),
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
                              print(
                                  "Block button pressed for ${listItems[index]["id"]}");
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
                              print(
                                  "Unblock button pressed for ${listItems[index]["id"]}");
                            },
                            child: const Text(
                              "Unblock",
                              style: TextStyle(
                                  color: Colors.white,
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 12),
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
