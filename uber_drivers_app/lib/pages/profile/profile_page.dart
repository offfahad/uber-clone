import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uber_drivers_app/pages/profileUpdation/driver_main_info.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';

import '../../authentication/login_screen.dart';
import '../../global/global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //image
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: CircleAvatar(
                              radius: 36.0,
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(driverPhoto),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                child: Text(
                                  "$driverName $driverSecondName",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.phone,
                                    size: 12.0,
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                    child: Text(
                                      driverPhone,
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (driverEmail.isNotEmpty)
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.email,
                                      size: 12.0,
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        driverEmail,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DriverMainInfo()));
                },
                child: const ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text(
                    "Your Profile",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                    "Setting",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(Icons.help_center),
                  title: Text(
                    "Help Center",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              await authProvider.signOut(context);
            },
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }
}
