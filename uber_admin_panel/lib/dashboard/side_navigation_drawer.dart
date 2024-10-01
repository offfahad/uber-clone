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
      
      //backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Color.fromARGB(221, 39, 57, 99),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
        
        ),
      ),
      sideBar: SideBar(
        backgroundColor: Color.fromARGB(221, 39, 57, 99),
        textStyle: TextStyle(color: Colors.white),
        activeBackgroundColor: Color.fromARGB(221, 39, 57, 99),
        activeTextStyle: TextStyle(color: Colors.white),
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
          AdminMenuItem(
            title: "Earnings",
            route: TripsPage.id,
            icon: CupertinoIcons.money_dollar,
          ),

        ],
        selectedRoute: DriverPage.id,
        onSelected: (itemSelected) {
          sendAdminTo(itemSelected);
        },
      ),
      body: chosenScreen,
    );
  }
}
