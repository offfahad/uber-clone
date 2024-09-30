import 'package:flutter/material.dart';
import 'package:uber_users_app/global/global_var.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = userName;
      phoneTextEditingController.text = userPhone;
      emailTextEditingController.text = userEmail;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //image
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: CircleAvatar(
                child: Image.asset("assets/images/avatarman.png"),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            //driver name
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
              child: TextField(
                controller: nameTextEditingController,
                textAlign: TextAlign.start,
                enabled: false,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //driver phone
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
              child: TextField(
                controller: phoneTextEditingController,
                textAlign: TextAlign.start,
                enabled: false,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.phone_android_outlined,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ), 
            //driver email
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
              child: TextField(
                controller: emailTextEditingController,
                textAlign: TextAlign.start,
                enabled: false,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // const SizedBox(
            //   height: 12,
            // ),

            // //logout btn
            // ElevatedButton(
            //   onPressed: () {
            //     FirebaseAuth.instance.signOut();
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (c) => const LoginScreen()));
            //   },
            //   style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.pink,
            //       padding: const EdgeInsets.symmetric(
            //           horizontal: 80, vertical: 18)),
            //   child: const Text("Logout"),
            // ),
          ],
        ),
      ),
    );
  }
}
