import 'package:flutter/material.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Add padding around the content
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Center the column content vertically
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Align content to the center horizontally
              children: [
                const Text(
                  "You are currently blocked by the admin.\nPlease contact the administrator for more information at gulzarsoft@gmail.com",
                  textAlign: TextAlign.center, // Center the text alignment
                  style: TextStyle(
                    fontSize: 16, // Adjust the font size for readability
                  ),
                ),
                const SizedBox(height: 20), // Space between text and button
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width * 0.6, // Set button width
                  height: 50, // Fixed button height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16, // Button text size
                        color: Colors.black, // Button text color
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
