import 'package:flutter/material.dart';
import 'package:googleapis/analytics/v3.dart';
import 'package:uber_users_app/appInfo/auth_provider.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/pages/about_page.dart';
import 'package:uber_users_app/pages/profile_page.dart';
import 'package:uber_users_app/pages/trips_history_page.dart';
import 'package:uber_users_app/widgets/sign_out_dialog.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final AuthenticationProvider
      authProvider; // Pass the auth provider for sign out

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
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/avatarman.png"),
            ),
            
            accountName: Text(userName, style: const TextStyle(color: Colors.black),),
            accountEmail: Text(userEmail, style: const TextStyle(color: Colors.black),),
          ),

          ListTile(
            leading: const Icon(
              Icons.account_box,
              color: Colors.black,
            ),
            title: const Text(
              "Account",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

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
                MaterialPageRoute(
                    builder: (context) => const TripsHistoryPage()),
              );
            },
          ),
          ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                ;
              }),
          ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              onTap: () {
                ;
              }),
          ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                ;
              }),
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
              leading: const Icon(Icons.star_rate),
              title: const Text('Rate Us'),
              onTap: () {
                ;
              }),

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
