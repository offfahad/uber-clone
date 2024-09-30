import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_drivers_app/pages/earnings/earning_page.dart';
import 'package:uber_drivers_app/pages/home/home_page.dart';
import 'package:uber_drivers_app/pages/profile/profile_page.dart';
import 'package:uber_drivers_app/pages/trips/trips_page.dart';
import '../providers/dashboard_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            const HomePage(),
            const EarningsPage(),
            TripsPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.credit_card), label: "Earnings"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_tree), label: "Trips"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          currentIndex: dashboardProvider.selectedIndex,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.black,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            dashboardProvider.setIndex(index);
            controller!.index = index;
          },
        ),
      ),
    );
  }
}
