import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/pages/driverRegistration/driver_registration.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/widgets/blocked_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  CommonMethods commonMethods = CommonMethods();
  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Enter The OPT Code Sent To Your Phone Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // pinput
                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      smsCode = value;
                    });

                    // verify OTP
                    verifyOTP(smsCode: smsCode!);
                  },
                ),

                const SizedBox(
                  height: 25,
                ),

                authRepo.isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const SizedBox.shrink(),

                authRepo.isSuccessful
                    ? Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 30,
                        ),
                      )
                    : const SizedBox.shrink(),

                const SizedBox(
                  height: 25,
                ),

                const Text(
                  'Didn\'t Receive Any Code?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.3, // Set button width
                  height: 50, // Fixed button height
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Resend",
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

  void verifyOTP({required String smsCode}) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    authProvider.verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onSuccess: () async {
        // 1. Check if the driver exists
        bool driverExists = await authProvider.checkUserExistById();

        if (driverExists) {
          // 2. Check if the driver is blocked
          bool isBlocked = await authProvider.checkIfDriverIsBlocked();

          if (isBlocked) {
            // Navigate to Block Screen if blocked
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const BlockedScreen()), // Replace 'BlockScreen' with your block screen widget
            );
          } else {
            // 3. Get user data from Firebase if not blocked
            await authProvider.getUserDataFromFirebaseDatabase();

            // 4. Check if driver fields are filled
            bool isDriverComplete =
                await authProvider.checkDriverFieldsFilled();

            if (isDriverComplete) {
              // Navigate to dashboard if profile is complete
              navigate(isSignedIn: true);
            } else {
              // Navigate to driver registration if profile is incomplete
              navigate(isSignedIn: false);
              commonMethods.displaySnackBar(
                "Fill your missing information!",
                context,
              );
            }
          }
        } else {
          // Navigate to user information screen if driver doesn't exist
          navigate(isSignedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DriverRegistration()),
        (route) => false,
      );
    }
  }
}
