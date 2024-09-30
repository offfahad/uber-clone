import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/profileUpdation/driver_main_info.dart';
import 'package:uber_drivers_app/providers/auth_provider.dart';
import 'package:uber_drivers_app/providers/registration_provider.dart';

import '../../global/global.dart';
import '../../widgets/ratting_stars.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<RegistrationProvider>(context, listen: false)
        .retrieveCurrentDriverInfo();
  }

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
                padding: const EdgeInsets.only(top: 40, bottom: 20),
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
                            width: 100.0,
                            height: 70.0,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: CachedNetworkImage(
                              imageUrl: driverPhoto,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
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
                                  Flexible(
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        driverPhone,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.visible,
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
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 4, 4, 4),
                                        child: Text(
                                          driverEmail,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow
                                              .visible, // Allow text to wrap
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (address.isNotEmpty)
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.location_city,
                                      size: 12.0,
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 4, 4, 4),
                                        child: Text(
                                          address,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow
                                              .visible, // Allow text to wrap
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 5,
                              ),
                              RatingStars(ratting: ratting),
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
            const SizedBox(
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
            const SizedBox(
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
