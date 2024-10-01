import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/registration_provider.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch the earnings as soon as the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false)
          .fetchDriverEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo,
        body: Column(
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
                        "assets/images/totalearnings.png",
                        width: 120,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Total Earnings:",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Consumer<RegistrationProvider>(
                        builder: (context, provider, child) {
                          // Check if data is still being fetched
                          if (provider.driverEarnings == null) {
                            return const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          } else {
                            return Text(
                              "Rs ${provider.driverEarnings}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
