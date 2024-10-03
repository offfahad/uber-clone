import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/authentication/user_information_screen.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/blocked_screen.dart';
import 'package:uber_users_app/pages/home_page.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

CommonMethods commonMethods = CommonMethods();

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
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
                  height: 16,
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
        // 1. check database if the current user exist
        bool userExits = await authProvider.checkUserExistById();
        if (userExits) {
          // 2. Check if the driver is blocked
          bool isBlocked = await authProvider.checkIfUserIsBlocked();
          // 2. get user data from database

          if (isBlocked) {
            // Navigate to Block Screen if blocked
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BlockedScreen(),
              ),
            );
          } else {
            await authProvider.getUserDataFromFirebaseDatabase();
            // 4. Check if driver fields are filled
            bool isUserComplete = await authProvider.checkUserFieldsFilled();

            if (isUserComplete) {
              // Navigate to dashboard if profile is complete
              navigate(isSingedIn: true);
            } else {
              // Navigate to driver registration if profile is incomplete
              navigate(isSingedIn: false);
              commonMethods.displaySnackBar(
                "Fill your missing information!",
                context,
              );
            }
          }
        } else {
          // navigate to user information screen
          navigate(isSingedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserInformationScreen()));
    }
  }
}
