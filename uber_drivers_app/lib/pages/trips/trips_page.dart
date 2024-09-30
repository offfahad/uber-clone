import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trips_provider.dart';
import 'trip_history_page.dart';

class TripsPage extends StatefulWidget {
  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the trip data when the widget is initialized
    Future.microtask(() =>
        Provider.of<TripProvider>(context, listen: false)
            .getCurrentDriverTotalNumberOfTripsCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: tripProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
          : Column(
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
                            "assets/images/totaltrips.png",
                            width: 120,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Total Trips:",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            tripProvider.currentDriverTotalTripsCompleted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => TripsHistoryPage()));
                  },
                  child: Center(
                    child: Container(
                      color: Colors.indigo,
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/tripscompleted.png",
                              width: 150,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Check Trips History",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
