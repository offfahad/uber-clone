import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uber_drivers_app/global/global.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isVisible = false.obs;
  final GlobalKey<FormState> loginFormKey =
      GlobalKey<FormState>(debugLabel: '__loginFormKey__');

  CommonMethods cMethods = CommonMethods();

    @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signInUser() async {
    if (!loginFormKey.currentState!.validate()) return;
    // Close the keyboard
    FocusScope.of(Get.context!).unfocus();
    isLoading.value = true;
    try {
      final User? userFirebase = (await _auth.signInWithEmailAndPassword(
        email: emailController.text.toLowerCase().trim(),
        password: passwordController.text.trim(),
      ))
          .user;

      if (userFirebase != null) {
        final userRef = _database.child("drivers").child(userFirebase.uid);
        userRef.once().then((snap) {
          if (snap.snapshot.value != null) {
            if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
              userName = (snap.snapshot.value as Map)["name"];
              userEmail = (snap.snapshot.value as Map)["email"];
              Get.to(() => const Dashboard());
            } else {
              _auth.signOut();
              cMethods.displaySnackBar(
                  "Your account is blocked. Contact admin @mughalfahad544@gmail.com",
                  Get.context!);
            }
          } else {
            _auth.signOut();
            cMethods.displaySnackBar(
                "Your record does not exist as a user", Get.context!);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      cMethods.displaySnackBar(e.message ?? "An error occurred", Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }
}
