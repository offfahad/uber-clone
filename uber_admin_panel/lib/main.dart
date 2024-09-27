import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_admin_panel/dashboard/side_navigation_drawer.dart';
import 'package:uber_admin_panel/firebase_options.dart';
import 'package:uber_admin_panel/provider/driver_provider.dart';
import 'package:uber_admin_panel/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DriverProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uber Admin Panel',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const SideNavigationDrawer(),
      ),
    );
  }
}
