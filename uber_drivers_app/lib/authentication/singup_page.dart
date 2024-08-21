import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:uber_drivers_app/authentication/controllers/signupController.dart';
import 'package:uber_drivers_app/authentication/login_page.dart';
import 'package:uber_drivers_app/const.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    // Use Get.put to create a new instance of the controller
    final SignUpController controller = Get.put(SignUpController());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: height * 0.06),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Create an account as a DRIVER,',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Let’s help you set up your account, \nit won’t take long.",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Obx(() {
                return GestureDetector(
                  onTap: () async {
                    await controller.pickImageFromCamera();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        controller.profileImagePath.value.isNotEmpty
                            ? FileImage(File(controller.profileImagePath.value))
                            : AssetImage('assets/images/avatarman.png')
                                as ImageProvider,
                  ),
                );
              }),
              TextButton(
                onPressed: () async {
                  await controller.pickImageFromGallery(context);
                },
                child: Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Form(
                key: controller.signUpFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      " Name",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    TextFormField(
                      controller: controller.nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 3) {
                          return "Enter Your Name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusColor: Colors.greenAccent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        hintText: 'Enter your Name',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    const Text(
                      " Email",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    TextFormField(
                      controller: controller.emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 7 ||
                            !value.contains("@") ||
                            !value.contains(".com")) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusColor: Colors.greenAccent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        hintText: 'Enter Email',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    const Text(
                      " Password",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    Obx(() => TextFormField(
                          obscureText: !controller.isVisible.value,
                          controller: controller.passwordController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.length < 5) {
                              return "Enter a valid Password";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              iconSize: 15,
                              onPressed: () {
                                controller.isVisible.value =
                                    !controller.isVisible.value;
                              },
                              icon: controller.isVisible.value
                                  ? const Icon(FontAwesomeIcons.solidEyeSlash)
                                  : const Icon(FontAwesomeIcons.solidEye),
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusColor: Colors.greenAccent,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 25),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'poppins',
                          ),
                        )),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    const Text(
                      " Car Model",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    TextFormField(
                      controller: controller.carModelController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Your Car Model";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusColor: Colors.greenAccent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        hintText: 'Enter your Car Model',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    const Text(
                      " Car Color",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    TextFormField(
                      controller: controller.carColorController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Your Car Color";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusColor: Colors.greenAccent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        hintText: 'Enter your Car Color',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    const Text(
                      " Car Number",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.009,
                    ),
                    TextFormField(
                      controller: controller.carNumberController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Your Car Number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusColor: Colors.greenAccent,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        hintText: 'Enter your Car Number',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Obx(() => Checkbox(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: primaryColor,
                            side: const BorderSide(
                              color: secondaryColor,
                            ),
                            value: controller.agreement.value,
                            onChanged: (value) {
                              controller.agreement.value = value!;
                            },
                          )),
                      const Text(
                        'Accept terms & Condition ?',
                        style: TextStyle(color: secondaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Obx(() => ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.registerNow();
                            },
                      icon: const Icon(
                        IconlyBold.arrowRight3,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a member? ",
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginPage());
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
