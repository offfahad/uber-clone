import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import 'package:uber_drivers_app/pages/driverRegistration/driver_registration.dart';
import 'package:uber_drivers_app/pages/home/home_page.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //const SizedBox(height: 50,),

                // Container(
                //   decoration: BoxDecoration(
                //       border: Border.all(color: Colors.black, width: 2),
                //       borderRadius: BorderRadius.circular(90)),
                //   child: CircleAvatar(
                //     radius: 80,
                //     backgroundImage: AssetImage(AssetsManager.openAILogo),
                //   ),
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
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

                const Text(
                  'Resend New Code',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
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
        bool driverExits = await authProvider.checkUserExistById();
        if (driverExits) {
          // 2. get user data from database
          await authProvider.getUserDataFromFirebaseDatabase();

          bool isDriverComplete = await authProvider.checkDriverFieldsFilled();

          if (isDriverComplete) {
            navigate(isSingedIn: true);
          } else {
            navigate(isSingedIn: false);
            commonMethods.displaySnackBar(
                "Fill your missing information!", context);
          }

          // 3. save user data to shared preferences
          //await authProvider.saveUserDataToSharedPref();

          // 4. save this user as signed in
          //await authProvider.setSignedIn();

          // 5. navigate to Home
          //navigate(isSingedIn: true);
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
          MaterialPageRoute(builder: (context) => const Dashboard()),
          (route) => false);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DriverRegistration()));
    }
  }
}
