import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/pages/home_page.dart';

import '../models/user_model.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  CommonMethods commonMethods = CommonMethods();
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    gmailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    if (authProvider.isGoogleSignedIn == false) {
      phoneController.text = authProvider.phoneNumber;
    }

    if (authProvider.isGoogleSignedIn) {
      gmailController.text = authProvider.firebaseAuth.currentUser!.email.toString();
      phoneController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Setup',
          style: TextStyle(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
              child: Column(
                children: [
                  Column(
                    children: [
                      // textFormFields
                      myTextFormField(
                        hintText: 'Enter Your Full Name',
                        icon: Icons.account_circle,
                        textInputType: TextInputType.name,
                        maxLines: 1,
                        maxLength: 25,
                        textEditingController: nameController,
                        enabled: true,
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      myTextFormField(
                        hintText: 'Enter Your Email Address',
                        icon: Icons.account_circle,
                        textInputType: TextInputType.emailAddress,
                        maxLines: 1,
                        maxLength: 25,
                        textEditingController: gmailController,
                        enabled: authProvider.isGoogleSignedIn ? false : true,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      myTextFormField(
                        hintText: 'Enter your phone number',
                        icon: Icons.phone,
                        textInputType: TextInputType.number,
                        maxLines: 1,
                        maxLength: 13,
                        textEditingController: phoneController,
                        enabled: authProvider.isGoogleSignedIn ? true : false,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      onPressed:
                          saveUserDataToFireStore, // Correctly call the sendPhoneNumber function

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myTextFormField({
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    required int maxLines,
    required int maxLength,
    required TextEditingController textEditingController,
    required bool enabled,
  }) {
    return TextFormField(
      enabled: enabled,
      cursorColor: Colors.grey,
      controller: textEditingController,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), color: Colors.black),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        hintText: hintText,
        alignLabelWithHint: true,
        border: InputBorder.none,
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  // store user data to fireStore
  void saveUserDataToFireStore() async {
    //final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
        id: authProvider.uid!,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: gmailController.text.trim(),
        blockStatus: "no");

    if (nameController.text.length >= 3) {
      authProvider.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        onSuccess: () async {
          // save user data locally
          //await authProvider.saveUserDataToSharedPref();

          // set signed in
          //await authProvider.setSignedIn();

          // go to home screen
          navigateToHomeScreen();
        },
      );
    } else {
      commonMethods.displaySnackBar(
          'Name must be atleast 3 characters', context);
    }
  }

  void navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false);
  }
}
