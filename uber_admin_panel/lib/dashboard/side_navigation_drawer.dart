import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:uber_admin_panel/dashboard/dashboard.dart';
import 'package:uber_admin_panel/pages/driver_page.dart';
import 'package:uber_admin_panel/pages/trips_page.dart';
import 'package:uber_admin_panel/pages/user_page.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = Dashboard();

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case DriverPage.id:
        setState(() {
          chosenScreen = DriverPage();
        });
        break;
      case UserPage.id:
        setState(() {
          chosenScreen = UserPage();
        });
        break;
      case TripsPage.id:
      setState(() {
        chosenScreen = TripsPage();
      });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(221, 39, 57, 99),
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: "Drivers",
            route: DriverPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          AdminMenuItem(
            title: "Users",
            route: UserPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
        ],
        selectedRoute: DriverPage.id,
        onSelected: (itemSelected) {
          sendAdminTo(itemSelected);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: const Color.fromARGB(221, 39, 57, 99),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              )
            ],
          ),
        ),
        footer: Container(
          
          height: 52,
          width: double.infinity,
          color: const Color.fromARGB(221, 39, 57, 99),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.computer,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
