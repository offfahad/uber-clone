import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentUser =
      FirebaseDatabase.instance.ref().child("tripRequest");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'My Trips History',
          style: TextStyle(
            color: Colors.black,
          ),
          
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentUser.onValue,
        builder:
            (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Error Occurred.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          if (!snapshotData.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Show progress indicator while loading
            );
          }

          if (snapshotData.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "No record found.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final snapshotValue = snapshotData.data!.snapshot.value;
          if (snapshotValue is Map) {
            final Map<String, dynamic> dataTrips =
                snapshotValue.cast<String, dynamic>();
            final List<Map<String, dynamic>> tripsList = [];
            dataTrips.forEach((key, value) {
              if (value is Map) {
                tripsList.add({"key": key, ...value});
              }
            });

            return ListView.builder(
              padding: EdgeInsets.all(5),
              shrinkWrap: true,
              itemCount: tripsList.length,
              itemBuilder: (context, index) {
                if (tripsList[index]["status"] != null &&
                    tripsList[index]["status"] == "ended" &&
                    tripsList[index]["userID"] ==
                        FirebaseAuth.instance.currentUser!.uid) {
                  return Card(
                    color: Colors.white,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup - fare amount
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/initial.png',
                                height: 16,
                                width: 16,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  tripsList[index]["pickUpAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    //color: Colors.white38,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "\Rs " +
                                    tripsList[index]["fareAmount"].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  //color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Dropoff
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/final.png',
                                height: 16,
                                width: 16,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  tripsList[index]["dropOffAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    //color: Colors.white38,
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
              },
            );
          } else {
            return const Center(
              child: Text(
                "Invalid data format.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}
