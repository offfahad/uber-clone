import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import '../../../const.dart';

class SignUpController extends GetxController {
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>(debugLabel: '__signUpFormKey__');

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final carModelController = TextEditingController();
  final carColorController = TextEditingController();
  final carNumberController = TextEditingController();
  final commonMethods = CommonMethods();

  final profileImagePath = ''.obs;
  final ImagePicker imagePicker = ImagePicker();
  File? profileImageFile;
  String? urlOfUploadImage;

  var isVisible = false.obs;
  var agreement = false.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    carModelController.dispose();
    carColorController.dispose();
    carNumberController.dispose();
    super.onClose();
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      profileImagePath.value = pickedFile.path;
      profileImageFile = File(pickedFile.path);
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      commonMethods.displaySnackBar("Profile picture is required!", context);
    } else {
      profileImagePath.value = pickedFile.path;
      profileImageFile = File(pickedFile.path);
    }
  }

  Future<String?> uploadImageToStorage(File profileImageFile) async {
    try {
      String imageIDName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceImage = FirebaseStorage.instance.ref().child('Images').child(imageIDName);
      UploadTask uploadTask = referenceImage.putFile(profileImageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      commonMethods.displaySnackBar("Failed to upload image: $e", Get.context!);
      return null;
    }
  }

  Future<void> registerNow() async {
    FocusScope.of(Get.context!).unfocus();

    if (!signUpFormKey.currentState!.validate() || !agreement.value) {
      return;
    }

    if (profileImageFile == null) {
      commonMethods.displaySnackBar("Profile picture is required!", Get.context!);
      return;
    }

    // Close the keyboard

    isLoading.value = true;
    try {
      final User? userFirebase = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.toLowerCase().trim(),
        password: passwordController.text.trim(),
      )).user;

      if (userFirebase != null) {
        final imageUrl = await uploadImageToStorage(profileImageFile!);
        if (imageUrl != null) {
          urlOfUploadImage = imageUrl;

          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(userFirebase.uid);

          Map driverCarInfo = {
            "carModel": carModelController.text.trim(),
            "carColor": carColorController.text.trim(),
            "carNumber": carNumberController.text.trim(),
          };

          Map userDataMap = {
            "profileImageUrl": urlOfUploadImage!,
            "name": nameController.text.trim(),
            "email": emailController.text.toLowerCase().trim(),
            "id": userFirebase.uid,
            "blockStatus": "no",
            "car_details": driverCarInfo,
          };

          await userRef.set(userDataMap);
          Get.offAll(() => Dashboard(), transition: Transition.cupertino);
        }
      }
    } catch (e) {
      commonMethods.displaySnackBar(e.toString(), Get.context!);
    } finally {
      isLoading.value = false;
    }
  }
}
