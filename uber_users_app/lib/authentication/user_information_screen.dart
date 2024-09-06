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
  CommonMethods commonMethods = CommonMethods();
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    phoneController.text = authProvider.phoneNumber;
  }

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        // textFormFields
                        myTextFormField(
                          hintText: 'Enter your full name',
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
                          hintText: 'Enter your phone number',
                          icon: Icons.phone,
                          textInputType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 10,
                          textEditingController: phoneController,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: RoundedLoadingButton(
                      controller: btnController,
                      onPressed: () {
                        saveUserDataToFireStore();
                      },
                      successIcon: Icons.check,
                      successColor: Colors.green,
                      errorColor: Colors.red,
                      color: Colors.deepPurple,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  )
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
      cursorColor: Colors.orangeAccent,
      controller: textEditingController,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.deepPurple),
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
        fillColor: Colors.purple.shade50,
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
        phone: phoneController.text,
        email: "",
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
      btnController.reset();
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
