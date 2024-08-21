import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:uber_drivers_app/authentication/controllers/loginController.dart';
import 'package:uber_drivers_app/authentication/forget_password_mail.dart';
import 'package:uber_drivers_app/authentication/singup_page.dart';
import 'package:uber_drivers_app/const.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hello, Welcome Back!',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Login as a Driver!',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.06,
            ),
            Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    height: height * 0.03,
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
                  Obx(
                    () => TextFormField(
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
                          onPressed: controller.togglePasswordVisibility,
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
                child: InkWell(
                  onTap: () => Get.to(() => const ForgetPasswordMailScreen()),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.04,
            ),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: Obx(
                () => ElevatedButton.icon(
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
                          await controller.signInUser();
                        },
                  icon: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Icon(
                          IconlyBold.arrowRight3,
                          color: Colors.white,
                          size: 16,
                        ),
                  label: Text(
                    controller.isLoading.value ? 'Signing In...' : 'Sign In',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    indent: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Or Sign in With",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade400,
                    endIndent: 50,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/Google.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Image.asset(
                          'assets/images/Facebook.png',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don’t have an account? ",
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => SignupPage());
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
