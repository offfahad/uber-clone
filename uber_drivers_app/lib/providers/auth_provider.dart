import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uber_drivers_app/models/driver.dart';
import 'package:uber_drivers_app/pages/auth/register_screen.dart';
import '../methods/common_method.dart';
import '../models/vehicleInfo.dart';
import '../pages/auth/otp_screen.dart';

class AuthenticationProvider extends ChangeNotifier {
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isGoogleSignedIn = false;
  bool _isGoogleSignInLoading = false;
  String? _uid;
  String? _phoneNumber;

  Driver? _driverModel;

  Driver get driverModel => _driverModel!;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber!;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isGoogleSignedIn => _isGoogleSignedIn;
  bool get isGoogleSigInLoading => _isGoogleSignInLoading;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase =
      FirebaseDatabase.instance; // Add this line
  final GoogleSignIn googleSignIn = GoogleSignIn(); // Google Sign-In instance

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startGoogleLoading() {
    _isGoogleSignInLoading = true;
    notifyListeners();
  }

  void stopGoogleLoading() {
    _isGoogleSignInLoading = false;
    notifyListeners();
  }

  // Sign in user with phone
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    startLoading(); // Start loading and notify listeners

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Sign in the user automatically when the code is retrieved
          await firebaseAuth.signInWithCredential(credential);
          stopLoading(); // Stop loading and notify listeners
        },
        verificationFailed: (FirebaseAuthException e) {
          stopLoading(); // Stop loading if verification failed
          commonMethods.displaySnackBar(e.toString(), context);
          throw Exception(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          stopLoading(); // Stop loading when the code is sent
          _phoneNumber = phoneNumber;
          notifyListeners();
          // Navigate to the OTP screen
          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          stopLoading(); // Stop loading when code auto-retrieval times out
        },
      );
    } on FirebaseException catch (e) {
      stopLoading(); // Stop loading on Firebase exception
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      User? user =
          (await firebaseAuth.signInWithCredential(phoneAuthCredential)).user;

      if (user != null) {
        _uid = user.uid;
        notifyListeners();
        onSuccess();
      }

      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

// Method to register a new user
  void saveUserDataToFirebase({
    required BuildContext context,
    required Driver driverModel,
    required VoidCallback onSuccess,
  }) async {
    startLoading();
    notifyListeners();

    try {
      //Save user data to Realtime Database
      DatabaseReference usersRef =
          firebaseDatabase.ref().child("drivers").child(driverModel.id);
      await usersRef.set(driverModel.toMap()).then((value) {
        stopLoading();
        notifyListeners();

        onSuccess();
      });

      // Navigate to the home page or another appropriate screen
      // Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
    } on FirebaseException catch (e) {
      stopLoading();
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // Method to check if user exists in Firebase Realtime Database
  Future<bool> checkUserExistByEmail(String email) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("drivers");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("email").equalTo(email).once();

    if (snapshot.snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkUserExistById() async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("drivers");
    DatabaseEvent snapshot = await usersRef
        .orderByChild(
            "id") // Assuming "id" is the field where Firebase Auth ID is stored
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once();

    return snapshot.snapshot.exists;
  }

  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      // Get a reference to the user's data in the Realtime Database
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);

      // Fetch user data from the database
      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        // Cast the snapshot value to a Map
        Map driverData = snapshot.value as Map;

        // Retrieve individual values from the map and create the Driver object
        _driverModel = Driver(
          id: driverData["id"] ?? '',
          firstName: driverData["firstName"] ?? '',
          secondName: driverData["secondName"] ?? '',
          phoneNumber: driverData["phoneNumber"] ?? '',
          address: driverData["address"] ?? '',
          profilePicture: driverData["profilePicture"] ?? '',
          dob: driverData["dob"] ?? '',
          email: driverData["email"] ?? '',
          cnicNumber: driverData["cnicNumber"] ?? '',
          cnicFrontImage: driverData["cnicFrontImage"] ?? '',
          cnicBackImage: driverData["cnicBackImage"] ?? '',
          driverFaceWithCnic: driverData["driverFaceWithCnic"] ?? '',
          drivingLicenseNumber: driverData["drivingLicenseNumber"] ?? '',
          drivingLicenseFrontImage:
              driverData["drivingLicenseFrontImage"] ?? '',
          drivingLicenseBackImage: driverData["drivingLicenseBackImage"] ?? '',
          blockStatus: driverData["blockStatus"] ?? '',
          deviceToken: driverData["deviceToken"] ?? '',
          driverRattings: driverData["driverRattings"] ?? '',
          earnings: driverData["earnings"] ?? '',
          vehicleInfo: VehicleInfo(
            brand: driverData["vehicleInfo"]?["brand"] ?? '',
            color: driverData["vehicleInfo"]?["color"] ?? '',
            productionYear: driverData["vehicleInfo"]?["productionYear"] ?? '',
            vehiclePicture: driverData["vehicleInfo"]?["vehiclePicture"] ?? '',
            type: driverData["vehicleInfo"]?["type"] ?? '',
            registrationPlateNumber:
                driverData["vehicleInfo"]?["registrationPlateNumber"] ?? '',
            registrationCertificateFrontImage: driverData["vehicleInfo"]
                    ?["registrationCertificateFrontImage"] ??
                '',
            registrationCertificateBackImage: driverData["vehicleInfo"]
                    ?["registrationCertificateBackImage"] ??
                '',
          ),
        );

        // Print or use the driver model as needed
        print(_driverModel);
        _uid = _driverModel!.id;
        notifyListeners(); // Notify listeners to update the UI
      } else {
        print("User data not found or not in the expected format.");
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }

  Future<bool> checkDriverFieldsFilled() async {
    try {
      // Get a reference to the driver's data in the Realtime Database
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);

      // Fetch user data from the database
      DataSnapshot snapshot = await driverRef.get();
      print(snapshot.value);

      if (snapshot.exists && snapshot.value != null) {
        // Cast the snapshot value to a Map
        Map driverData = snapshot.value as Map;

        // Retrieve individual fields and perform null checks
        String profilePicture = driverData["profilePicture"] ?? '';
        String firstName = driverData["firstName"] ?? '';
        String secondName = driverData["secondName"] ?? '';
        String phoneNumber = driverData["phoneNumber"] ?? '';
        String dob = driverData["dob"] ?? '';
        String email = driverData["email"] ?? '';
        String cnicNumber = driverData["cnicNumber"] ?? '';
        String cnicFrontImage = driverData["cnicFrontImage"] ?? '';
        String cnicBackImage = driverData["cnicBackImage"] ?? '';
        String driverFaceWithCnic = driverData["driverFaceWithCnic"] ?? '';
        String drivingLicenseNumber = driverData["drivingLicenseNumber"] ?? '';
        String drivingLicenseFrontImage =
            driverData["drivingLicenseFrontImage"] ?? '';
        String drivingLicenseBackImage =
            driverData["drivingLicenseBackImage"] ?? '';

        // Extract and check nested vehicle info fields
        Map vehicleInfo = driverData["vehicleInfo"] ?? {};
        String carBrand = vehicleInfo["brand"] ?? '';
        String carColor = vehicleInfo["color"] ?? '';
        String productionYear = vehicleInfo["productionYear"] ?? '';
        String vehiclePicture = vehicleInfo["vehiclePicture"] ?? '';
        String vehicleType = vehicleInfo["type"] ?? '';
        String registrationPlateNumber =
            vehicleInfo["registrationPlateNumber"] ?? '';
        String registrationCertificateFrontImage =
            vehicleInfo["registrationCertificateFrontImage"] ?? '';
        String registrationCertificateBackImage =
            vehicleInfo["registrationCertificateBackImage"] ?? '';

        // Check if any of the required fields are missing or empty
        if (profilePicture.isEmpty ||
            firstName.isEmpty ||
            secondName.isEmpty ||
            phoneNumber.isEmpty ||
            dob.isEmpty ||
            email.isEmpty ||
            cnicNumber.isEmpty ||
            cnicFrontImage.isEmpty ||
            cnicBackImage.isEmpty ||
            driverFaceWithCnic.isEmpty ||
            drivingLicenseNumber.isEmpty ||
            drivingLicenseFrontImage.isEmpty ||
            drivingLicenseBackImage.isEmpty ||
            carBrand.isEmpty ||
            carColor.isEmpty ||
            productionYear.isEmpty ||
            vehiclePicture.isEmpty ||
            vehicleType.isEmpty ||
            registrationPlateNumber.isEmpty ||
            registrationCertificateFrontImage.isEmpty ||
            registrationCertificateBackImage.isEmpty) {
          return false; // Some fields are missing or empty
        } else {
          return true; // All fields are filled
        }
      } else {
        print("Driver data not found or not in the expected format.");
        return false;
      }
    } catch (e) {
      print("An error occurred while checking driver fields: $e");
      return false;
    }
  }

  // Google Sign-In method
  Future<void> signInWithGoogle(
      BuildContext context, VoidCallback onSuccess) async {
    startGoogleLoading();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        stopGoogleLoading();
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _uid = user.uid;
        _isGoogleSignedIn = true;
        notifyListeners();
        // Handle any post sign-in logic here (e.g., saving user data)
      }
      onSuccess();

      stopGoogleLoading();
    } on FirebaseAuthException catch (e) {
      stopGoogleLoading();
      commonMethods.displaySnackBar(
          e.message ?? "Failed to sign in with Google", context);
    }
  }

  Future<bool> checkIfDriverIsBlocked() async {
    try {
      // Get a reference to the user's data in the Realtime Database
      DatabaseReference driverRef = firebaseDatabase
          .ref()
          .child("drivers")
          .child(firebaseAuth.currentUser!.uid);

      // Fetch user data from the database
      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        // Cast the snapshot value to a Map
        Map driverData = snapshot.value as Map;

        // Check the block status
        String blockStatus = driverData["blockStatus"] ?? 'no';

        // If blockStatus is 'yes', return true (blocked)
        if (blockStatus == 'yes') {
          await firebaseAuth.signOut();
          await googleSignIn.signOut();

          _uid = null;
          _isGoogleSignedIn = false;
          notifyListeners();
          return true;
        } else {
          // If blockStatus is 'no', return false (not blocked)
          return false;
        }
      } else {
        print("Driver data not found or not in the expected format.");
        return false; // Default to not blocked if data isn't found
      }
    } catch (e) {
      print("An error occurred while checking block status: $e");
      return false; // Default to not blocked in case of an error
    }
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    startLoading();
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();

      _uid = null;
      _isGoogleSignedIn = false;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const RegisterScreen()), // Change to your login page
        (route) => false,
      );

      stopLoading();
    } on FirebaseAuthException catch (e) {
      stopLoading();
      commonMethods.displaySnackBar(e.message ?? "Failed to sign out", context);
    }
  }
}
