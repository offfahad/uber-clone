import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uber_users_app/pages/home_page.dart';

import '../authentication/otp_screen.dart';
import '../models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  CommonMethods commonMethods = CommonMethods();
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isSignedIn = false;
  String? _uid;
  String? _phoneNumber;

  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  String? get uid => _uid;
  String get phoneNumber => _phoneNumber!;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseDatabase firebaseDatabase =
      FirebaseDatabase.instance; // Add this line
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
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

          // Navigate to the OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
              ),
            ),
          );
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

// Helper method to check if the phone number exists in Firebase Realtime Database
  Future<bool> _checkPhoneNumberExists(String phoneNumber) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("phone").equalTo(phoneNumber).once();

    return snapshot.snapshot.exists;
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
    required UserModel userModel,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Save user data to Realtime Database
      DatabaseReference usersRef =
          firebaseDatabase.ref().child("users").child(userModel.id);
      await usersRef.set(userModel.toMap()).then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });

      // Navigate to the home page or another appropriate screen
      // Navigator.push(context, MaterialPageRoute(builder: (c) => HomePage()));
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      commonMethods.displaySnackBar(e.toString(), context);
    }
  }

  // Method to check if user exists in Firebase Realtime Database
  Future<bool> checkUserExistByEmail(String email) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot =
        await usersRef.orderByChild("email").equalTo(email).once();

    if (snapshot.snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // Method to check if user exists in Firebase Realtime Database by phone number
  Future<bool> checkUserExistByPhone(String phoneNumber) async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild("phone")
        .equalTo(phoneNumber.toString().trim())
        .once();

    if (snapshot.snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkUserExistById() async {
    DatabaseReference usersRef = firebaseDatabase.ref().child("users");
    DatabaseEvent snapshot = await usersRef
        .orderByChild(
            "id") // Assuming "id" is the field where Firebase Auth ID is stored
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once();

    return snapshot.snapshot.exists;
  }

  // Method to get user data from Firebase Realtime Database
  Future<void> getUserDataFromFirebaseDatabase() async {
    try {
      // Get a reference to the user's data in the Realtime Database
      DatabaseReference usersRef = firebaseDatabase
          .ref()
          .child("users")
          .child(firebaseAuth.currentUser!.uid);

      // Fetch user data from the database
      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        // Convert the snapshot data into a Map
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        // Create a UserModel object from the retrieved data
        _userModel = UserModel(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'],
          blockStatus: userData['blockStatus'],
        );

        _uid = _userModel!.id;
        notifyListeners(); // Notify listeners to update the UI
      } else {
        // Handle the case where user data does not exist
        print("User data not found.");
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }
}
