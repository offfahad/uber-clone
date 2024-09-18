import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentDriver =
      FirebaseDatabase.instance.ref().child("tripRequest");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Completed Trips',
        ),

      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentDriver.onValue,
        builder: (BuildContext context, snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Error Occurred.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          if (!snapshotData.hasData ||
              snapshotData.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No record found.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          // Safely cast to Map if the snapshot is not null
          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips
              .forEach((key, value) => tripsList.add({"key": key, ...value}));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index) {
              if (tripsList[index]["status"] != null &&
                  tripsList[index]["status"] == "ended" &&
                  tripsList[index]["driverId"] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //pickup - fare amount
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/initial.png',
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Text(
                                tripsList[index]["pickUpAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Rs${tripsList[index]["fareAmount"]}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        //dropoff
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/final.png',
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(
                              width: 18,
                            ),
                            Expanded(
                              child: Text(
                                tripsList[index]["dropOffAddress"].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
