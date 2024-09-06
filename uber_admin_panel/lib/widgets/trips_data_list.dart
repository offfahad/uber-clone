import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../methods/common_methods.dart';

class TripsDataList extends StatefulWidget {
  const TripsDataList({super.key});

  @override
  State<TripsDataList> createState() => _TripsDataListState();
}

class _TripsDataListState extends State<TripsDataList> {
  final completedTripsRecordsFromDatabase =
      FirebaseDatabase.instance.ref().child("tripRequest");
  CommonMethods cMethods = CommonMethods();

  launchGoogleMapFromSourceToDestination(
    pickUpLat,
    pickUpLng,
    dropOffLat,
    dropOffLng,
  ) async {
    String directionAPIUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$pickUpLat,$pickUpLng&destination=$dropOffLat,$dropOffLng&dir_action=navigate";

    if (await canLaunchUrl(Uri.parse(directionAPIUrl))) {
      await launchUrl(Uri.parse(directionAPIUrl));
    } else {
      throw "Could not lauch google map";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: completedTripsRecordsFromDatabase.onValue,
      builder: (BuildContext context, snapshotData) {
        if (snapshotData.hasError) {
          return const Center(
            child: Text(
              "Error Occurred. Try Later.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          );
        }

        if (snapshotData.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map dataMap = snapshotData.data!.snapshot.value as Map;
        List itemsList = [];
        dataMap.forEach((key, value) {
          itemsList.add({"key": key, ...value});
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itemsList.length,
          itemBuilder: ((context, index) {
            if (itemsList[index]["status"] != null &&
                itemsList[index]["status"] == "ended") {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cMethods.data(
                      2,
                      Text(itemsList[index]["tripID"].toString(), style: TextStyle(fontSize: 12),),
                    ),
                    cMethods.data(
                      1,
                      Text(itemsList[index]["userName"].toString(), style: TextStyle(fontSize: 12)),
                    ),
                    cMethods.data(
                      1,
                      Text(itemsList[index]["driverName"].toString(), style: TextStyle(fontSize: 12)),
                    ),
                    cMethods.data(
                      1,
                      Text(itemsList[index]["carDetails"].toString(), style: TextStyle(fontSize: 12)),
                    ),
                    cMethods.data(
                      1,
                      Text(itemsList[index]["publishDateTime"].toString(), style: TextStyle(fontSize: 12)),
                    ),
                    cMethods.data(
                      1,
                      Text("\Rs " + itemsList[index]["fareAmount"].toString(), style: TextStyle(fontSize: 12)),
                    ),
                    cMethods.data(
                      1,
                      SizedBox(
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
                            String pickUpLat =
                                itemsList[index]["pickUpLatLng"]["latitude"];
                            String pickUpLng =
                                itemsList[index]["pickUpLatLng"]["longitude"];

                            String dropOffLat =
                                itemsList[index]["dropOffLatLng"]["latitude"];
                            String dropOffLng =
                                itemsList[index]["dropOffLatLng"]["longitude"];

                            launchGoogleMapFromSourceToDestination(
                              pickUpLat,
                              pickUpLng,
                              dropOffLat,
                              dropOffLng,
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
                  ]);
            } else {
              return Container();
            }
          }),
        );
      },
    );
  }
}
