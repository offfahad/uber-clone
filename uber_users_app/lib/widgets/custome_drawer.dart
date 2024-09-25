import 'package:flutter/material.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/pages/about_page.dart';
import 'package:uber_users_app/pages/profile_page.dart';
import 'package:uber_users_app/pages/trips_history_page.dart';
import 'package:uber_users_app/widgets/sign_out_dialog.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final AuthenticationProvider authProvider; // Pass the auth provider for sign out

  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.authProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          const Divider(
            height: 1,
            color: Colors.grey,
            thickness: 1,
          ),

          //header
          Container(
            color: Colors.black54,
            height: 160,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white70,
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/avatarman.png",
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Profile",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(
            height: 1,
            color: Colors.black,
            thickness: 1,
          ),
          const SizedBox(height: 10),

          //body
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Colors.black,
            ),
            title: const Text(
              "History",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TripsHistoryPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.black,
            ),
            title: const Text(
              "About",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SignOutDialog(
                    title: 'Logout',
                    description: 'Are you sure you want to logout?',
                    onSignOut: () async {
                      await authProvider.signOut(context);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
