import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trips_provider.dart';

class TripsHistoryPage extends StatefulWidget {
  @override
  _TripsHistoryPageState createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the completed trips data when the widget is initialized
    Future.microtask(() =>
        Provider.of<TripProvider>(context, listen: false).getCompletedTrips());
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Completed Trips'),
      ),
      body: tripProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tripProvider.completedTrips.isEmpty
              ? const Center(
                  child: Text(
                    "No record found.",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : ListView.builder(
                  itemCount: tripProvider.completedTrips.length,
                  itemBuilder: (context, index) {
                    var trip = tripProvider.completedTrips[index];
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
                                    trip["pickUpAddress"].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Rs${trip["fareAmount"]}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                    trip["dropOffAddress"].toString(),
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
                  },
                ),
    );
  }
}
